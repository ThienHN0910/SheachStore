import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'sheach_store_channel';
  static const _channelName = 'SheachStore Notifications';
  static const _channelDesc = 'Notifications for orders and account activity';

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    // v22: initialize uses named parameter `settings:`
    await _plugin.initialize(settings: initSettings);

    // Request notification permission (Android 13+)
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  NotificationDetails get _defaultDetails => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  /// Show notification when an order is created successfully.
  Future<void> showOrderCreated({
    required int orderId,
    required double totalAmount,
  }) async {
    final amount = totalAmount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    // v22: show() uses named parameters
    await _plugin.show(
      id: orderId,
      title: '🛒 Order Placed Successfully!',
      body: 'Order #$orderId has been created. Total: $amount VND',
      notificationDetails: _defaultDetails,
    );
  }

  /// Show notification when an order status changes.
  Future<void> showOrderStatusChanged({
    required int orderId,
    required String newStatus,
  }) async {
    await _plugin.show(
      id: orderId + 1000,
      title: '📦 Order Status Updated',
      body: 'Order #$orderId status changed to: ${newStatus.toUpperCase()}',
      notificationDetails: _defaultDetails,
    );
  }

  /// Show welcome notification after login or registration.
  Future<void> showWelcome({
    required String userName,
    required bool isRegistering,
  }) async {
    final title =
        isRegistering ? '🎉 Welcome to SheachStore!' : '👋 Welcome back!';
    final body = isRegistering
        ? 'Hi $userName, your account has been created successfully.'
        : 'Good to see you again, $userName!';

    await _plugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: _defaultDetails,
    );
  }
}
