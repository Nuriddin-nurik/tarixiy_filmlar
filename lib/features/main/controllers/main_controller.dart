import 'package:get/get.dart';

import '../../../core/update/update_service.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class MainController extends GetxController {
  var currentIndex = 0.obs;

  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(seconds: 2), UpdateService.check);
  }

  void changePage(int index) {
    currentIndex.value = index;
    if (index == 2) {
      Get.find<FavoritesController>().load();
    } else if (index == 3) {
      Get.find<ProfileController>().loadSubscription();
    }
  }
}
