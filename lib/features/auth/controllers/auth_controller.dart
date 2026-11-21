import 'dart:async';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/device_id.dart';
import '../../../core/notifications/push_service.dart';
import '../../notifications/controllers/notifications_controller.dart';
import '../../../core/widgets/app_widgets.dart';

class AuthController extends GetxController {
  static const _serverClientId =
      '428242414058-voehuh35ufk65lu8t8cuqbrn57h042vk.apps.googleusercontent.com';
  static const _iosClientId =
      '428242414058-apqe487egpu74uspvrdbmecp4t2pclu5.apps.googleusercontent.com';

  Future<GoogleSignInAccount?> _signInAccount() => googleAccount();

  static Future<GoogleSignInAccount?> googleAccount() => GoogleSignIn(
        scopes: const ['email', 'profile'],
        clientId: GetPlatform.isIOS ? _iosClientId : null,
        serverClientId: _serverClientId,
      ).signIn();

  var isLoading = false.obs;

  Future<void> signInWithGoogle() async {
    try {
      isLoading(true);

      final googleUser = await _signInAccount();
      if (googleUser == null) {
        isLoading(false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        appSnack('Xato'.tr, 'Google token olishda xatolik'.tr);
        isLoading(false);
        return;
      }

      final deviceId = await DeviceId.get();

      final dio = Dio();
      final response = await dio.post(
        '${ApiConstants.baseUrl}/auth/google',
        data: {
          'credential': idToken,
          'deviceId': deviceId,
        },
      );

      if (response.statusCode == 200) {
        await _finishLogin(response.data);
      } else {
        appSnack('Xato'.tr, 'Kirish amalga oshmadi'.tr);
      }
    } catch (e) {
      appSnack('Xato'.tr, 'Kirish amalga oshmadi'.tr);
    } finally {
      isLoading(false);
    }
  }

  var isTelegramLoading = false.obs;
  Timer? _tgTimer;
  String? _tgCode;
  bool _tgChecking = false;

  Future<void> _finishLogin(dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', data['token'] ?? '');
    await prefs.setString('refresh_token', data['refreshToken'] ?? '');

    Get.offAllNamed(Routes.MAIN);
    PushService.registerToken();
    Get.find<NotificationsController>().refreshUnread();
  }

  Future<void> signInWithTelegram() async {
    if (isTelegramLoading.value) return;
    try {
      isTelegramLoading(true);
      final deviceId = await DeviceId.get();

      final res = await Dio().get(
        '${ApiConstants.baseUrl}${ApiConstants.telegramStart}',
        queryParameters: {'deviceId': deviceId},
      );

      final data = res.data;
      final code = data is Map ? data['code'] as String? : null;
      final authUrl = data is Map ? data['authUrl'] as String? : null;
      if (code == null || authUrl == null) {
        appSnack('Xato'.tr, 'Kirish amalga oshmadi'.tr);
        cancelTelegram();
        return;
      }

      _tgCode = code;
      final opened = await launchUrl(
        Uri.parse(authUrl),
        mode: LaunchMode.inAppBrowserView,
      );
      if (!opened) {
        appSnack('Xato'.tr, 'Telegram ochilmadi'.tr);
        cancelTelegram();
        return;
      }

      _startTelegramPolling(deviceId);
    } catch (e) {
      appSnack('Xato'.tr, 'Telegram orqali kirishda muammo'.tr);
      cancelTelegram();
    }
  }

  void _startTelegramPolling(String deviceId) {
    var ticks = 0;
    _tgTimer?.cancel();
    _tgTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      ticks++;
      if (ticks > 300) {
        cancelTelegram();
        appSnack('Xato'.tr, "Vaqt tugadi, qaytadan urinib ko'ring".tr);
        return;
      }
      _checkTelegram(deviceId);
    });
  }

  Future<void> _checkTelegram(String deviceId) async {
    final code = _tgCode;
    if (code == null || _tgChecking) return;
    _tgChecking = true;
    try {
      final res = await Dio().get(
        '${ApiConstants.baseUrl}${ApiConstants.telegramCheck}',
        queryParameters: {'code': code, 'deviceId': deviceId},
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (_tgCode != code) return;

      final data = res.data;
      if (res.statusCode == 200 && data is Map && data['token'] != null) {
        cancelTelegram();
        try {
          await closeInAppWebView();
        } catch (_) {}
        await _finishLogin(data);
      } else if (res.statusCode == 404 || res.statusCode == 410) {
        cancelTelegram();
        appSnack('Xato'.tr, "Vaqt tugadi, qaytadan urinib ko'ring".tr);
      }
    } catch (_) {
    } finally {
      _tgChecking = false;
    }
  }

  void cancelTelegram() {
    _tgTimer?.cancel();
    _tgTimer = null;
    _tgCode = null;
    isTelegramLoading(false);
  }

  @override
  void onClose() {
    _tgTimer?.cancel();
    super.onClose();
  }
}
