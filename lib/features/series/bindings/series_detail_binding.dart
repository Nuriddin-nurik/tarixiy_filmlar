import 'package:get/get.dart';
import '../controllers/series_detail_controller.dart';

class SeriesDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SeriesDetailController>(() => SeriesDetailController());
  }
}
