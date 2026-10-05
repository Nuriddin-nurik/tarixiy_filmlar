import 'package:get/get.dart';

import '../../favorites/controllers/favorites_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class MainController extends GetxController {
  var currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
    if (index == 2) {
      // Sevimlilar har ochilganda yangilanadi (serial sahifasida like bosilgan bo'lishi mumkin).
      Get.find<FavoritesController>().load();
    } else if (index == 3) {
      Get.find<ProfileController>().loadSubscription();
    }
  }
}
