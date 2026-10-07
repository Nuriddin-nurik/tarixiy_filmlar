import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/notification_model.dart';
import '../../../data/providers/api_provider.dart';

class NotificationsController extends GetxController with WidgetsBindingObserver {
  final ApiProvider _api = ApiProvider();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshIfLoggedIn();
  }

  Future<void> _refreshIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    if ((prefs.getString('access_token') ?? '').isNotEmpty) await refreshUnread();
  }

  var items = <NotificationModel>[].obs;
  var unreadCount = 0.obs;
  var isLoading = false.obs;
  var hasError = false.obs;

  Future<void> refreshUnread() async {
    try {
      unreadCount.value = await _api.getUnreadNotificationCount();
    } catch (_) {
    }
  }

  Future<void> load() async {
    try {
      isLoading(true);
      hasError(false);
      items.value = await _api.getNotifications();
      unreadCount.value = items.where((n) => !n.read).length;
    } catch (_) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  Future<void> markRead(NotificationModel n) async {
    if (n.read) return;
    final i = items.indexWhere((e) => e.id == n.id);
    if (i >= 0) items[i] = n.markRead();
    if (unreadCount.value > 0) unreadCount.value--;
    try {
      await _api.markNotificationRead(n.id);
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    items.value = items.map((n) => n.markRead()).toList();
    unreadCount.value = 0;
    try {
      await _api.markAllNotificationsRead();
    } catch (_) {}
  }

  void clear() {
    items.clear();
    unreadCount.value = 0;
  }
}
