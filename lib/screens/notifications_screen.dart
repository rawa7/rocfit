import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/therocfit_api.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationResponse? _notificationResponse;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id ?? 2; // Default to player ID 2 if not logged in
      
      final apiClient = TheRocFitApiClient();
      final response = await apiClient.getNotifications(userId);
      
      if (response.success && response.data != null) {
        setState(() {
          _notificationResponse = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshNotifications() async {
    await _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.black,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: AppTextStyles.headline3.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_notificationResponse != null && _notificationResponse!.notifications.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.refresh,
                color: AppColors.primary,
                size: 24,
              ),
              onPressed: _refreshNotifications,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_notificationResponse == null || _notificationResponse!.notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      color: AppColors.primary,
      child: _buildNotificationsList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.grey,
              size: 64,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Failed to load notifications',
              style: AppTextStyles.headline4.copyWith(
                color: AppColors.greyDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: AppTextStyles.bodyText2.copyWith(
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge,
                  vertical: AppConstants.paddingMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_none,
              color: AppColors.grey,
              size: 64,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'No Notifications',
              style: AppTextStyles.headline4.copyWith(
                color: AppColors.greyDark,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              'You\'re all caught up! No new notifications to display.',
              style: AppTextStyles.bodyText2.copyWith(
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Check Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge,
                  vertical: AppConstants.paddingMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    final notifications = _notificationResponse!.notifications;
    final pagination = _notificationResponse!.pagination;
    
    return Column(
      children: [
        // Summary header
        Container(
          margin: const EdgeInsets.all(AppConstants.paddingMedium),
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Notifications',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${pagination.totalInt}',
                      style: AppTextStyles.headline3.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (_notificationResponse!.unreadCount > 0) ...[
                const SizedBox(width: AppConstants.paddingMedium),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_notificationResponse!.unreadCount} New',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Notifications list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationItem(notification, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(NotificationItem notification, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: notification.isUnread 
            ? AppColors.primary.withOpacity(0.05)
            : AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: notification.isUnread 
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.greyLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showNotificationDetails(notification);
          },
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.notitype).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.notitype),
                    color: _getNotificationColor(notification.notitype),
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: AppConstants.paddingMedium),
                
                // Notification content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type badge and date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getNotificationColor(notification.notitype).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              notification.notificationTypeDescription,
                              style: AppTextStyles.caption.copyWith(
                                color: _getNotificationColor(notification.notitype),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            notification.formattedDate,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppConstants.paddingSmall),
                      
                      // Title
                      Text(
                        notification.displayTitle,
                        style: AppTextStyles.bodyText1.copyWith(
                          color: AppColors.black,
                          fontWeight: notification.isUnread 
                              ? FontWeight.w600 
                              : FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Unread indicator
                      if (notification.isUnread) ...[
                        const SizedBox(height: AppConstants.paddingSmall),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'New',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Arrow icon
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.grey,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationDetails(NotificationItem notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildNotificationDetailsSheet(notification),
    );
  }

  Widget _buildNotificationDetailsSheet(NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.notitype).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.notitype),
                    color: _getNotificationColor(notification.notitype),
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: AppConstants.paddingMedium),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.notificationTypeDescription,
                        style: AppTextStyles.headline4.copyWith(
                          color: _getNotificationColor(notification.notitype),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        notification.formattedDate,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Message',
                    style: AppTextStyles.headline4.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    notification.displayTitle,
                    style: AppTextStyles.bodyText1.copyWith(
                      color: AppColors.greyDark,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.paddingLarge),
                  
                  // Details
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.greyLight,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Notification ID', notification.id),
                        const Divider(height: AppConstants.paddingMedium),
                        _buildDetailRow('Date & Time', notification.date),
                        const Divider(height: AppConstants.paddingMedium),
                        _buildDetailRow('Type', notification.notificationTypeDescription),
                        const Divider(height: AppConstants.paddingMedium),
                        _buildDetailRow('Status', notification.isRead ? 'Read' : 'Unread'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.paddingLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyText2.copyWith(
              color: AppColors.greyDark,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case "1":
        return Icons.schedule;
      case "2":
        return Icons.sports_gymnastics;
      case "3":
        return Icons.account_balance_wallet;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case "1":
        return Colors.orange;
      case "2":
        return Colors.green;
      case "3":
        return Colors.blue;
      default:
        return AppColors.primary;
    }
  }
}
