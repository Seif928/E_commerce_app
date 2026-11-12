import 'dart:convert';
import 'package:e_commerce_app/core/utils/app_route.dart';
import 'package:e_commerce_app/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class InAppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'order', 'promo', 'general'
  final String? payload;

  const InAppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.type = 'general',
    this.payload,
  });

  InAppNotification copyWith({bool? isRead}) {
    return InAppNotification(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      type: type,
      payload: payload,
    );
  }
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description:
        'This channel is used for important notifications such as orders, deals, and delivery updates.',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  final ValueNotifier<List<InAppNotification>> notificationsNotifier =
      ValueNotifier<List<InAppNotification>>([
        InAppNotification(
          id: 'welcome_1',
          title: 'Welcome to Verve Store! 🎉',
          body: 'Explore our latest arrivals, live catalog, and smooth checkout experience.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          type: 'promo',
        ),
        InAppNotification(
          id: 'deal_1',
          title: 'Special Live Offer 🔥',
          body: 'Check out today\'s trending tech and fashion items at discounted rates.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
          type: 'promo',
        ),
      ]);

  int get unreadCount =>
      notificationsNotifier.value.where((n) => !n.isRead).length;

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationPayload(response.payload);
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
      await androidPlugin.requestNotificationsPermission();
    }

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Foreground FCM listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final title = notification?.title ?? message.data['title'] ?? 'New Notification';
      final body = notification?.body ?? message.data['body'] ?? '';
      final payload = jsonEncode(message.data);

      showNotification(
        title: title,
        body: body,
        payload: payload,
        type: message.data['type'] ?? 'general',
      );
    });

    // App opened via notification listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageData(message.data);
    });

    // Check for initial message that launched the app
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageData(initialMessage.data);
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String type = 'general',
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _localNotifications.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error displaying local notification: $e');
    }

    // Add to in-app history
    final newEntry = InAppNotification(
      id: id.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
      payload: payload,
    );
    notificationsNotifier.value = [newEntry, ...notificationsNotifier.value];
  }

  Future<void> showOrderPlacedNotification({
    required String orderId,
    required double totalAmount,
  }) async {
    await showNotification(
      title: 'Order Confirmed! 🎉',
      body:
          'Your order #$orderId for \$${totalAmount.toStringAsFixed(2)} has been confirmed and is being prepared.',
      type: 'order',
      payload: jsonEncode({'route': AppRoute.profileRoute}),
    );
  }

  Future<void> sendTestNotification() async {
    await showNotification(
      title: 'Live Notification Test 🔔',
      body: 'Notifications are active and working smoothly in Verve Store!',
      type: 'general',
    );
  }

  void markAllAsRead() {
    notificationsNotifier.value =
        notificationsNotifier.value
            .map((item) => item.copyWith(isRead: true))
            .toList();
  }

  void clearAll() {
    notificationsNotifier.value = [];
  }

  void _handleNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final data = jsonDecode(payload);
      if (data is Map<String, dynamic>) {
        _handleMessageData(data);
      }
    } catch (_) {}
  }

  void _handleMessageData(Map<String, dynamic> data) {
    final navContext = navigtorKey.currentContext;
    if (navContext == null || !navContext.mounted) return;

    final productId = data['product_id'];
    if (productId is String && productId.isNotEmpty) {
      Navigator.of(navContext).pushNamed(
        AppRoute.productDetailsRoute,
        arguments: productId,
      );
    } else if (data['route'] == AppRoute.cartRoute) {
      Navigator.of(navContext).pushNamed(AppRoute.cartRoute);
    }
  }
}

