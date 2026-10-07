import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/providers/api_provider.dart';
import '../../features/notifications/controllers/notifications_controller.dart';
import '../routes/app_routes.dart';
import '../utils/open_series.dart';

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class PushService {
  static const channelId = 'tarixiy_filmlar_notifications_v4';

  static final _local = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase ishga tushmadi: $e');
      return;
    }
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

    const channel = AndroidNotificationChannel(
      channelId,
      'Tarixiy Kinolar',
      description: 'Yangi qismlar, obuna va to\'lov haqida xabarlar',
      importance: Importance.high,
    );
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    await _local.initialize(
      const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
      onDidReceiveNotificationResponse: (r) => _openFromPush(r.payload),
    );

    FirebaseMessaging.onMessage.listen((m) {
      final n = m.notification;
      if (n != null) {
        _local.show(
          m.hashCode,
          n.title,
          n.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(channelId, 'Tarixiy Kinolar',
                importance: Importance.high, priority: Priority.high),
          ),
          payload: m.data['seriesId'],
        );
      }
      if (Get.isRegistered<NotificationsController>()) {
        Get.find<NotificationsController>().refreshUnread();
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((m) => _openFromPush(m.data['seriesId']));
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      Future.delayed(const Duration(milliseconds: 800), () => _openFromPush(initial.data['seriesId']));
    }

    FirebaseMessaging.instance.onTokenRefresh.listen(_sendToken);
    _ready = true;
  }

  static Future<void> registerToken() async {
    if (!_ready) return;
    try {
      await FirebaseMessaging.instance.requestPermission();
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _sendToken(token);
    } catch (e) {
      debugPrint('FCM token olinmadi: $e');
    }
  }

  static Future<void> _sendToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    if ((prefs.getString('access_token') ?? '').isEmpty) return;
    try {
      await ApiProvider().updateFcmToken(token);
    } catch (e) {
      debugPrint('FCM token serverga yuborilmadi: $e');
    }
  }

  static void _openFromPush(String? seriesId) {
    final id = int.tryParse(seriesId ?? '');
    if (Get.isRegistered<NotificationsController>()) {
      Get.find<NotificationsController>().refreshUnread();
    }
    if (id != null) {
      openSeriesById(id);
    } else {
      _openNotifications();
    }
  }

  static void _openNotifications() {
    if (Get.currentRoute != Routes.NOTIFICATIONS) Get.toNamed(Routes.NOTIFICATIONS);
  }
}
