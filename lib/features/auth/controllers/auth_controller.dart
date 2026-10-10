import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/device_id.dart';
import '../../../core/notifications/push_service.dart';
import '../../notifications/controllers/notifications_controller.dart';
import '../../../core/widgets/app_widgets.dart';

class AuthController extends GetxController {
  static const _serverClientIds = [
    '490587248988-5smen6r7i94f2mnc0h5aunmuu1jopk03.apps.googleusercontent.com',
    '490587248988-bfl9t0t4nu3gipk2ojn6iiv76i10ffhk.apps.googleusercontent.com',
    '428242414058-voehuh35ufk65lu8t8cuqbrn57h042vk.apps.googleusercontent.com',
  ];
  static const _clientPrefsKey = 'google_client_index';

  Future<GoogleSignInAccount?> _signInAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_clientPrefsKey) ?? 0;
    final order = [saved, ...List.generate(_serverClientIds.length, (i) => i).where((i) => i != saved)];
    PlatformException? lastError;
    for (final i in order) {
      final client = GoogleSignIn(scopes: const ['email', 'profile'], serverClientId: _serverClientIds[i]);
      try {
        final account = await client.signIn();
        if (account != null) await prefs.setInt(_clientPrefsKey, i);
        return account;
      } on PlatformException catch (e) {
        lastError = e;
        await client.signOut().catchError((_) => null);
      }
    }
    throw lastError ?? PlatformException(code: 'sign_in_failed');
  }

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

      final prefs = await SharedPreferences.getInstance();
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
        final data = response.data;
        await prefs.setString('access_token', data['token'] ?? '');
        await prefs.setString('refresh_token', data['refreshToken'] ?? '');

        Get.offAllNamed(Routes.MAIN);
        PushService.registerToken();
        Get.find<NotificationsController>().refreshUnread();
      } else {
        appSnack('Xato'.tr, 'Kirish amalga oshmadi'.tr);
      }
    } catch (e) {
      appSnack('Xato'.tr, 'Google orqali kirishda muammo: $e');
    } finally {
      isLoading(false);
    }
  }
}
