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
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '428242414058-voehuh35ufk65lu8t8cuqbrn57h042vk.apps.googleusercontent.com',
  );

  var isLoading = false.obs;

  // Google bilan kirish
  Future<void> signInWithGoogle() async {
    try {
      isLoading(true);
      
      // 1. Google akkauntini tanlash
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading(false);
        return; // Foydalanuvchi bekor qildi
      }

      // 2. Google ID tokenini olish
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        appSnack('Xato'.tr, 'Google token olishda xatolik'.tr);
        isLoading(false);
        return;
      }

      // 3. Tokenni Backend ga yuborish → /auth/google
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
        // 4. JWT tokenni saqlash
        await prefs.setString('access_token', data['token'] ?? '');
        await prefs.setString('refresh_token', data['refreshToken'] ?? '');
        
        Get.offAllNamed(Routes.MAIN);
        // Push bildirishnomalar uchun qurilma tokenini serverga yuboramiz.
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
