import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

class ConnectivityWatcher extends GetxService {
  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _offline = false;

  static bool _isOffline(List<ConnectivityResult> results) =>
      results.isEmpty || results.every((r) => r == ConnectivityResult.none);

  static Future<bool> checkOffline() async => _isOffline(await Connectivity().checkConnectivity());

  @override
  void onInit() {
    super.onInit();
    _start();
  }

  Future<void> _start() async {
    _offline = await checkOffline();
    _sub = _connectivity.onConnectivityChanged.listen(_onChanged);
  }

  void _onChanged(List<ConnectivityResult> results) {
    final offline = _isOffline(results);
    if (offline == _offline) return;
    _offline = offline;
    if (offline) {
      _showOfflineSnack();
    } else if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
  }

  void _showOfflineSnack() {
    if (Get.currentRoute == Routes.DOWNLOADS) return;
    Get.snackbar(
      "Internet o'chdi".tr,
      "Siz oflayn rejimdasiz. Yuklanganlar bo'limiga o'tishni xohlaysizmi?".tr,
      snackPosition: SnackPosition.BOTTOM,
      colorText: Colors.white,
      backgroundColor: AppColors.surfaceLight.withValues(alpha: 0.97),
      borderColor: AppColors.border,
      borderWidth: 1,
      margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 96.h),
      duration: const Duration(seconds: 10),
      icon: const Icon(Icons.wifi_off_rounded, color: AppColors.gold),
      mainButton: TextButton(
        onPressed: openDownloads,
        child: Text(
          "O'tish".tr,
          style: TextStyle(color: AppColors.gold, fontSize: 13.sp, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static void openDownloads() {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    if (Get.currentRoute != Routes.DOWNLOADS) Get.toNamed(Routes.DOWNLOADS);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
