import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/device_id.dart';
import '../../auth/controllers/auth_controller.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/subscription_models.dart';
import '../../../data/providers/api_provider.dart';
import '../../home/controllers/home_controller.dart';
import '../../player/controllers/download_controller.dart';
import '../../notifications/controllers/notifications_controller.dart';
import '../../../core/widgets/app_widgets.dart';

class ProfileController extends GetxController with WidgetsBindingObserver {
  final ApiProvider _apiProvider = ApiProvider();
  Dio get _dio => DioClient().dio;
  var isLoggingOut = false.obs;
  var isDeleting = false.obs;
  var subscription = Rxn<MySubscriptionModel>();
  var hasActivePlans = false.obs;

  UserModel? get user => Get.find<HomeController>().homeData.value?.user;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadSubscription();
  }

  @override
  void onClose() {
    _linkTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) loadSubscription();
  }

  Future<void> loadSubscription() async {
    try {
      subscription.value = await _apiProvider.getMySubscription();
    } catch (_) {
    }
    try {
      hasActivePlans.value = (await _apiProvider.getSubscriptionPlans()).isNotEmpty;
    } catch (_) {
    }
  }

  Future<void> logout() async {
    isLoggingOut(true);
    try {
      final email = user?.email;
      if (email != null) await _apiProvider.logout(email);
    } catch (_) {
    }
    await _clearSession();
    isLoggingOut(false);
  }

  Future<void> deleteAccount() async {
    isDeleting(true);
    try {
      await _apiProvider.deleteAccount();
      await _clearSession();
      appSnack("Akkaunt o'chirildi".tr, "Ma'lumotlaringiz o'chirildi".tr);
    } catch (_) {
      appSnack('Xato'.tr, "Akkauntni o'chirib bo'lmadi. Keyinroq urinib ko'ring.".tr);
    } finally {
      isDeleting(false);
    }
  }

  Future<void> _clearSession() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await Get.find<DownloadController>().deleteAll();
    Get.find<NotificationsController>().clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    Get.offAllNamed(Routes.AUTH);
  }

  var isLinkingTelegram = false.obs;
  var isLinkingGoogle = false.obs;
  Timer? _linkTimer;
  String? _linkCode;
  bool _linkChecking = false;

  Future<void> linkTelegram() async {
    if (isLinkingTelegram.value) return;
    try {
      isLinkingTelegram(true);
      final res = await _dio.post(ApiConstants.telegramLinkStart);
      final data = res.data;
      final code = data is Map ? data['code'] as String? : null;
      final authUrl = data is Map ? data['authUrl'] as String? : null;
      if (code == null || authUrl == null) {
        appSnack('Xato'.tr, "Telegram'ni ulab bo'lmadi".tr);
        cancelTelegramLink();
        return;
      }
      _linkCode = code;
      final opened = await launchUrl(Uri.parse(authUrl), mode: LaunchMode.inAppBrowserView);
      if (!opened) {
        appSnack('Xato'.tr, 'Telegram ochilmadi'.tr);
        cancelTelegramLink();
        return;
      }
      var ticks = 0;
      _linkTimer?.cancel();
      _linkTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        ticks++;
        if (ticks > 300) {
          cancelTelegramLink();
          appSnack('Xato'.tr, "Vaqt tugadi, qaytadan urinib ko'ring".tr);
          return;
        }
        _checkTelegramLink();
      });
    } catch (_) {
      appSnack('Xato'.tr, "Telegram'ni ulab bo'lmadi".tr);
      cancelTelegramLink();
    }
  }

  Future<void> _checkTelegramLink() async {
    final code = _linkCode;
    if (code == null || _linkChecking) return;
    _linkChecking = true;
    try {
      final res = await _dio.get(
        ApiConstants.telegramLinkCheck,
        queryParameters: {'code': code},
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (_linkCode != code) return;
      final status = res.statusCode;
      if (status == 202) return;
      cancelTelegramLink();
      try {
        await closeInAppWebView();
      } catch (_) {}
      if (status == 200) {
        await Get.find<HomeController>().fetchHomeData();
        await loadSubscription();
        appSnack('Tayyor'.tr, "Telegram hisobingizga ulandi".tr);
      } else if (status == 409) {
        appSnack('Xato'.tr, _linkError(res.data));
      } else {
        appSnack('Xato'.tr, "Vaqt tugadi, qaytadan urinib ko'ring".tr);
      }
    } catch (_) {
    } finally {
      _linkChecking = false;
    }
  }

  void cancelTelegramLink() {
    _linkTimer?.cancel();
    _linkTimer = null;
    _linkCode = null;
    isLinkingTelegram(false);
  }

  Future<void> linkGoogle() async {
    if (isLinkingGoogle.value) return;
    try {
      isLinkingGoogle(true);
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
      final account = await AuthController.googleAccount();
      if (account == null) return;
      final idToken = (await account.authentication).idToken;
      if (idToken == null) {
        appSnack('Xato'.tr, 'Google token olishda xatolik'.tr);
        return;
      }
      final res = await _dio.post(
        ApiConstants.googleLink,
        data: {'credential': idToken, 'deviceId': await DeviceId.get()},
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      final data = res.data;
      if (res.statusCode == 200 && data is Map && data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['token'] ?? '');
        await prefs.setString('refresh_token', data['refreshToken'] ?? '');
        await Get.find<HomeController>().fetchHomeData();
        await loadSubscription();
        appSnack('Tayyor'.tr, 'Google hisobingizga ulandi'.tr);
      } else {
        appSnack('Xato'.tr, _linkError(data));
      }
    } catch (_) {
      appSnack('Xato'.tr, "Google'ni ulab bo'lmadi".tr);
    } finally {
      isLinkingGoogle(false);
    }
  }

  String _linkError(dynamic data) {
    final status = data is Map ? data['status'] : null;
    switch (status) {
      case 'TELEGRAM_IN_USE':
        return 'Bu Telegram akkaunt boshqa hisobga ulangan'.tr;
      case 'GOOGLE_IN_USE':
        return 'Bu Google akkauntga boshqa Telegram ulangan'.tr;
      case 'ALREADY_LINKED':
        return 'Hisobingizga allaqachon boshqa akkaunt ulangan'.tr;
      default:
        return "Ulab bo'lmadi, qaytadan urinib ko'ring".tr;
    }
  }
}
