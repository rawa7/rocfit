import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../services/therocfit_api.dart';
import '../providers/language_provider.dart';
import 'full_screen_image_viewer.dart';

class GameItemDetailScreen extends StatefulWidget {
  final GameItem gameItem;
  
  const GameItemDetailScreen({
    super.key,
    required this.gameItem,
  });

  @override
  State<GameItemDetailScreen> createState() => _GameItemDetailScreenState();
}

class _GameItemDetailScreenState extends State<GameItemDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.gameItem.allImageUrls;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLanguage = languageProvider.locale.languageCode;
    
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Hero Image Carousel
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppColors.white,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Main Image Carousel
                  if (images.isNotEmpty) ...[
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemCount: images.length,
                                             itemBuilder: (context, index) {
                         return GestureDetector(
                           onTap: () {
                             Navigator.push(
                               context,
                               PageRouteBuilder(
                                 pageBuilder: (context, animation, secondaryAnimation) =>
                                     FullScreenImageViewer(
                                   imageUrls: images,
                                   initialIndex: index,
                                   heroTag: 'game_item_${widget.gameItem.id}_$index',
                                 ),
                                 transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                   return FadeTransition(opacity: animation, child: child);
                                 },
                                 transitionDuration: const Duration(milliseconds: 300),
                               ),
                             );
                           },
                           child: Hero(
                             tag: 'game_item_${widget.gameItem.id}_$index',
                             child: CachedNetworkImage(
                               imageUrl: images[index],
                               fit: BoxFit.cover,
                               placeholder: (context, url) => Container(
                                 color: AppColors.greyLight,
                                 child: const Center(
                                   child: CircularProgressIndicator(
                                     color: AppColors.primary,
                                   ),
                                 ),
                               ),
                               errorWidget: (context, url, error) => Container(
                                 color: AppColors.greyLight,
                                 child: const Center(
                                   child: Icon(
                                     Icons.image_not_supported,
                                     color: AppColors.grey,
                                     size: 48,
                                   ),
                                 ),
                               ),
                             ),
                           ),
                         );
                       },
                    ),
                    
                    // Gradient overlay for better text/icon visibility
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Image indicators
                    if (images.length > 1)
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            images.length,
                            (index) => GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: index == _currentImageIndex ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: index == _currentImageIndex 
                                      ? Colors.white 
                                      : Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    // Image counter
                    if (images.length > 1)
                      Positioned(
                        top: 60,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${_currentImageIndex + 1}/${images.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    
                    // Fullscreen icon indicator
                    Positioned(
                      bottom: 20,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Placeholder when no images
                    Container(
                      color: AppColors.greyLight,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              color: AppColors.grey,
                              size: 64,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No images available',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.grey,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Category
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.gameItem.getLocalizedName(currentLanguage),
                                style: AppTextStyles.headline2.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  widget.gameItem.getLocalizedCategory(currentLanguage).toUpperCase(),
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.gameItem.price != '0') ...[
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              '${widget.gameItem.price} IQD',
                              style: AppTextStyles.bodyText1.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: AppConstants.paddingLarge),
                    
                    // Short Description
                    if (widget.gameItem.getLocalizedDescription(currentLanguage).isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.greyLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.gameItem.getLocalizedDescription(currentLanguage),
                          style: AppTextStyles.bodyText1.copyWith(
                            color: AppColors.greyDark,
                            height: 1.4,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.paddingLarge),
                    ],
                    
                    // Long Description Section
                    if (widget.gameItem.getLocalizedLongDescription(currentLanguage).isNotEmpty) ...[
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Details',
                            style: AppTextStyles.headline3.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.gameItem.getLocalizedLongDescription(currentLanguage),
                          style: AppTextStyles.bodyText1.copyWith(
                            color: AppColors.greyDark,
                            height: 1.6,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: AppConstants.paddingLarge),
                    
                    // Item Info Cards
                    Row(
                      children: [
                        if (widget.gameItem.getLocalizedCategory(currentLanguage).isNotEmpty) ...[
                          Expanded(
                            child: _buildInfoCard(
                              'Category',
                              widget.gameItem.getLocalizedCategory(currentLanguage).toUpperCase(),
                              Icons.category_outlined,
                            ),
                          ),
                        ],
                        if (widget.gameItem.itemType.isNotEmpty && 
                            widget.gameItem.getLocalizedCategory(currentLanguage).isNotEmpty) ...[
                          const SizedBox(width: 12),
                        ],
                        if (widget.gameItem.itemType.isNotEmpty) ...[
                          Expanded(
                            child: _buildInfoCard(
                              'Type',
                              widget.gameItem.itemType.toUpperCase(),
                              Icons.fitness_center,
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    // Add some bottom padding for better scroll behavior
                    const SizedBox(height: AppConstants.paddingXLarge),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.greyDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.bodyText2.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
