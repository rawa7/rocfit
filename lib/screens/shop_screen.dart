import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../constants/app_theme.dart';
import '../services/therocfit_api.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<ShopItem> _allItems = [];
  List<ShopItem> _filteredItems = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, int> _selectedImageIndex = {}; // Track selected image for each item

  @override
  void initState() {
    super.initState();
    _loadShopItems();
  }

  Future<void> _loadShopItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await authProvider.apiClient.getShopItems();

      if (response.success && response.data != null) {
        final allItems = response.data!;
        final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
        final currentLanguage = languageProvider.locale.languageCode;
        
        // Get unique localized categories
        final categoriesSet = allItems
            .map((item) => item.getLocalizedCategory(currentLanguage))
            .where((category) => category.isNotEmpty)
            .toSet();
        
        setState(() {
          _allItems = allItems;
          _filteredItems = allItems;
          _categories = ['All', ...categoriesSet.toList()..sort()];
          _selectedCategory = 'All';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load shop items: ${response.message}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Exception loading shop items: $e');
      setState(() {
        _errorMessage = 'Failed to load shop items. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _filterByCategory(String category) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentLanguage = languageProvider.locale.languageCode;
    
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems.where((item) => 
          item.getLocalizedCategory(currentLanguage) == category
        ).toList();
      }
    });
  }

  Widget _buildCategoryTabs() {
    if (_categories.isEmpty || _categories.length == 1) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () => _filterByCategory(category),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(
                  vertical: 12, 
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.greyLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Text(
                  category,
                  style: AppTextStyles.bodyText2.copyWith(
                    color: isSelected ? AppColors.white : AppColors.greyDark,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildShopItem(ShopItem item) {
    final imageUrls = item.allImageUrls;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLanguage = languageProvider.locale.languageCode;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with thumbnails and main image
            _buildImageSection(item),

            const SizedBox(height: AppConstants.paddingLarge),

            // Product name
            Center(
              child: Text(
                item.getLocalizedName(currentLanguage).toUpperCase(),
                style: AppTextStyles.headline2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppConstants.paddingSmall),

            // Product description
            Center(
              child: Text(
                item.getLocalizedDescription(currentLanguage).isNotEmpty 
                    ? item.getLocalizedDescription(currentLanguage)
                    : 'PRODUCT DESCRIPTION',
                style: AppTextStyles.bodyText1.copyWith(
                  color: AppColors.grey,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Price
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  '${item.price} IQD',
                  style: AppTextStyles.headline4.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(ShopItem item) {
    final imageUrls = item.allImageUrls;
    
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          // Thumbnail images on the left
          SizedBox(
            width: 80,
            child: Column(
              children: [
                // First 3 thumbnails
                for (int i = 0; i < 3; i++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImageIndex[item.itemId] = i;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: i < 2 ? AppConstants.paddingSmall : 0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.greyLight,
                          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                          border: (_selectedImageIndex[item.itemId] ?? 0) == i
                              ? Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: _buildThumbnailImage(item, i),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: AppConstants.paddingMedium),

          // Main large image on the right
          Expanded(
            child: GestureDetector(
              onTap: () => _showFullScreenImages(item),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: _buildMainImage(item),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailImage(ShopItem item, int index) {
    final imageUrls = item.allImageUrls;
    
    if (index >= imageUrls.length) {
      return const Center(
        child: Text(
          'Image',
          style: TextStyle(
            color: AppColors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      child: Image.network(
        imageUrls[index],
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Text(
              'Image',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainImage(ShopItem item) {
    final imageUrls = item.allImageUrls;
    final selectedIndex = _selectedImageIndex[item.itemId] ?? 0;
    
    if (imageUrls.isEmpty) {
      return const Center(
        child: Text(
          'Image',
          style: TextStyle(
            color: AppColors.grey,
            fontSize: 24,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    final imageToShow = selectedIndex < imageUrls.length 
        ? imageUrls[selectedIndex] 
        : imageUrls.first;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      child: Image.network(
        imageToShow,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Text(
              'Image',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 24,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFullScreenImages(ShopItem item) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: _ShopItemDetailsModal(item: item),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: AppConstants.paddingMedium),
            Text('Loading shop items...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.grey,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              _errorMessage!,
              style: AppTextStyles.headline3.copyWith(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            ElevatedButton(
              onPressed: _loadShopItems,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: AppColors.grey,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'No shop items found',
              style: AppTextStyles.headline3.copyWith(color: AppColors.grey),
            ),
            if (_selectedCategory != 'All')
              Text(
                'in $_selectedCategory category',
                style: AppTextStyles.bodyText2.copyWith(color: AppColors.grey),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        return _buildShopItem(_filteredItems[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.black,
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  
                  const Spacer(),
                  
                  Text(
                    'SHOP',
                    style: AppTextStyles.headline3.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.black,
                      size: 24,
                    ),
                    onPressed: () {
                      // Handle notifications
                    },
                  ),
                ],
              ),
            ),
            
            // Category tabs
            _buildCategoryTabs(),
            
            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopItemDetailsModal extends StatefulWidget {
  final ShopItem item;
  
  const _ShopItemDetailsModal({required this.item});

  @override
  State<_ShopItemDetailsModal> createState() => _ShopItemDetailsModalState();
}

class _ShopItemDetailsModalState extends State<_ShopItemDetailsModal> {
  late PageController _pageController;
  int _currentImageIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = widget.item.allImageUrls;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLanguage = languageProvider.locale.languageCode;
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background tap to close
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.transparent,
          ),
        ),
        
        // Content
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image carousel
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    child: imageUrls.isNotEmpty 
                        ? _buildImageCarousel(imageUrls)
                        : _buildNoImagePlaceholder(),
                  ),
                ),
              ),
              
              // Item details
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Item name
                    Text(
                      widget.item.getLocalizedName(currentLanguage).toUpperCase(),
                      style: AppTextStyles.headline3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Category and type
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                          ),
                          child: Text(
                            widget.item.getLocalizedCategory(currentLanguage),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                          ),
                          child: Text(
                            'Shop Item',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.purple[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Price:',
                          style: AppTextStyles.bodyText1.copyWith(
                            color: AppColors.greyDark,
                          ),
                        ),
                        Text(
                          '${widget.item.price} IQD',
                          style: AppTextStyles.headline4.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    // Description section
                    if (widget.item.getLocalizedDescription(currentLanguage).isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: AppTextStyles.bodyText1.copyWith(
                              color: AppColors.greyDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.greyLight,
                              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                              border: Border.all(
                                color: AppColors.grey.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.item.getLocalizedDescription(currentLanguage),
                              style: AppTextStyles.bodyText2.copyWith(
                                color: AppColors.black,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                        ),
                        child: Text(
                          'No description available for this item.',
                          style: AppTextStyles.bodyText2.copyWith(
                            color: AppColors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
        
        // Close button
        Positioned(
          top: 60,
          right: 20,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: AppColors.white,
                size: 24,
              ),
            ),
          ),
        ),
        
        // Image counter (if multiple images)
        if (imageUrls.length > 1)
          Positioned(
            top: 80,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentImageIndex + 1} / ${imageUrls.length}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildImageCarousel(List<String> imageUrls) {
    if (imageUrls.length == 1) {
      return InteractiveViewer(
        panEnabled: true,
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 0.5,
        maxScale: 3.0,
        child: Image.network(
          imageUrls.first,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingIndicator(loadingProgress);
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorPlaceholder();
          },
        ),
      );
    }
    
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentImageIndex = index;
        });
      },
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.network(
            imageUrls[index],
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingIndicator(loadingProgress);
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorPlaceholder();
            },
          ),
        );
      },
    );
  }
  
  Widget _buildNoImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.greyLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag,
            size: 64,
            color: AppColors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No Image Available',
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingIndicator(ImageChunkEvent loadingProgress) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.greyLight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading image...',
              style: AppTextStyles.bodyText2.copyWith(
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.greyLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 64,
            color: AppColors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load image',
            style: AppTextStyles.bodyText1.copyWith(
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
