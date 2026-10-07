import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
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
  var isLoggingOut = false.obs;
  var isDeleting = false.obs;
  var subscription = Rxn<MySubscriptionModel>();

  UserModel? get user => Get.find<HomeController>().homeData.value?.user;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadSubscription();
  }

  @override
  void onClose() {
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
}
