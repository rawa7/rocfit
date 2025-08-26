import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../constants/app_theme.dart';
import '../services/therocfit_api.dart';
import '../l10n/app_localizations.dart';

class MenuScreen extends StatefulWidget {
  final String itemType; // "Food" or "Suppliment"
  
  const MenuScreen({
    super.key,
    required this.itemType,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<MenuItem> _allItems = [];
  List<MenuItem> _filteredItems = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await authProvider.apiClient.getMenuItems();

      if (response.success && response.data != null) {
        final allItems = response.data!;
        
        // Filter items by type (Food or Suppliment)
        final itemsOfType = allItems.where((item) => 
          item.itemType.toLowerCase() == widget.itemType.toLowerCase()
        ).toList();
        
        // Get unique categories for this item type (using localized categories)
        final localizations = AppLocalizations.of(context)!;
        final languageCode = localizations.localeName;
        
        final categoriesSet = itemsOfType
            .map((item) => item.getLocalizedCategory(languageCode))
            .where((category) => category.isNotEmpty)
            .toSet();
        
        setState(() {
          _allItems = itemsOfType;
          _filteredItems = itemsOfType;
          _categories = [localizations.all, ...categoriesSet.toList()..sort()];
          _selectedCategory = localizations.all;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = '${AppLocalizations.of(context)?.failedToLoadMenuItems ?? 'Failed to load menu items'}: ${response.message}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Exception loading menu items: $e');
              setState(() {
        final localizations = AppLocalizations.of(context);
        _errorMessage = '${localizations?.failedToLoadMenuItems ?? 'Failed to load menu items'}. ${localizations?.pleaseTryAgain ?? 'Please try again.'}';
        _isLoading = false;
      });
    }
  }

  void _filterByCategory(String category) {
    final localizations = AppLocalizations.of(context)!;
    final languageCode = localizations.localeName;
    
    setState(() {
      _selectedCategory = category;
      if (category == localizations.all) {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems.where((item) => 
          item.getLocalizedCategory(languageCode) == category
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

  Widget _buildMenuItem(MenuItem item) {
    return Container(
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
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Item image
            GestureDetector(
              onTap: () => _showFullScreenImage(item),
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: _buildItemImage(item),
              ),
            ),

            const SizedBox(height: AppConstants.paddingSmall),

            // Item name
            Text(
              item.itemName.toUpperCase(),
              style: AppTextStyles.bodyText1.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Price
            Text(
              '${item.price} IQD',
              style: AppTextStyles.bodyText2.copyWith(
                color: AppColors.greyDark,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemImage(MenuItem item) {
    // Handle null or empty image paths
    if (item.imagePath == null || item.imagePath!.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)?.image ?? 'Image',
          style: const TextStyle(
            color: AppColors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    // Clean up the image URL - remove escaped slashes and resolve relative paths
    String cleanImageUrl = item.imagePath!.replaceAll(r'\/', '/');
    
    // Handle relative paths in the URL
    if (cleanImageUrl.contains('../uploads/')) {
      // Extract the filename and create a direct URL
      final filename = cleanImageUrl.split('/uploads/').last;
      cleanImageUrl = 'https://therocfit.com/uploads/$filename';
    }

    print('Loading image: $cleanImageUrl'); // Debug print

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      child: Image.network(
        cleanImageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Image load error for $cleanImageUrl: $error'); // Debug print
          return Center(
            child: Text(
              AppLocalizations.of(context)?.image ?? 'Image',
              style: const TextStyle(
                color: AppColors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    final localizations = AppLocalizations.of(context)!;
    
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(localizations.loadingMenuItems),
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
              onPressed: _loadMenuItems,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: Text(localizations.retry),
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
              Icons.restaurant_menu,
              size: 64,
              color: AppColors.grey,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              localizations.noItemsFound(widget.itemType.toLowerCase()),
              style: AppTextStyles.headline3.copyWith(color: AppColors.grey),
            ),
            if (_selectedCategory != localizations.all)
              Text(
                localizations.inCategory(_selectedCategory),
                style: AppTextStyles.bodyText2.copyWith(color: AppColors.grey),
              ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: AppConstants.paddingMedium,
        mainAxisSpacing: AppConstants.paddingMedium,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        return _buildMenuItem(_filteredItems[index]);
      },
    );
  }

  void _showFullScreenImage(MenuItem item) {
    final localizations = AppLocalizations.of(context)!;
    final languageCode = localizations.localeName;
    
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
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
                    // Image container
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
                          child: _buildFullScreenImage(item),
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
                            item.getLocalizedName(languageCode).toUpperCase(),
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
                                  item.getLocalizedCategory(languageCode),
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
                                  color: widget.itemType == 'Food' 
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                                ),
                                child: Text(
                                  widget.itemType == 'Food' ? localizations.food : localizations.suppliment,
                                  style: AppTextStyles.caption.copyWith(
                                    color: widget.itemType == 'Food' 
                                        ? Colors.green[700]
                                        : Colors.blue[700],
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
                                localizations.price,
                                style: AppTextStyles.bodyText1.copyWith(
                                  color: AppColors.greyDark,
                                ),
                              ),
                              Text(
                                '${item.price} IQD',
                                style: AppTextStyles.headline4.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          
                          // Description section
                          if (item.getLocalizedDescription(languageCode).isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizations.description,
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
                                    item.getLocalizedDescription(languageCode),
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
                                localizations.noDescriptionAvailable,
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildFullScreenImage(MenuItem item) {
    final localizations = AppLocalizations.of(context)!;
    
    if (item.imagePath == null || item.imagePath!.isEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.greyLight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.restaurant,
              size: 64,
              color: AppColors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              localizations.noImageAvailable,
              style: AppTextStyles.headline4.copyWith(
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Clean up the image URL - remove escaped slashes and resolve relative paths
    String cleanImageUrl = item.imagePath!.replaceAll(r'\/', '/');
    
    // Handle relative paths in the URL
    if (cleanImageUrl.contains('../uploads/')) {
      // Extract the filename and create a direct URL
      final filename = cleanImageUrl.split('/uploads/').last;
      cleanImageUrl = 'https://therocfit.com/uploads/$filename';
    }

    return InteractiveViewer(
      panEnabled: true,
      boundaryMargin: const EdgeInsets.all(20),
      minScale: 0.5,
      maxScale: 3.0,
      child: Image.network(
        cleanImageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
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
                    localizations.loadingImage,
                    style: AppTextStyles.bodyText2.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
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
                  localizations.unableToLoadImage,
                  style: AppTextStyles.bodyText1.copyWith(
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
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
                    (widget.itemType == 'Food' ? localizations.food : localizations.suppliment).toUpperCase(),
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
