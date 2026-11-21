import 'package:get/get.dart';

import '../../data/models/series_model.dart';
import '../../data/providers/api_provider.dart';
import '../../features/home/controllers/home_controller.dart';
import '../../features/series/controllers/series_detail_controller.dart';
import '../routes/app_routes.dart';
import '../widgets/app_widgets.dart';

Future<void> openSeriesById(int seriesId) async {
  SeriesModel? series;
  if (Get.isRegistered<HomeController>()) {
    series = Get.find<HomeController>().series.firstWhereOrNull((s) => s.id == seriesId);
  }
  if (series == null) {
    try {
      final all = await ApiProvider().getAllSeries();
      series = all.firstWhereOrNull((s) => s.id == seriesId);
    } catch (_) {}
  }
  if (series == null) {
    appSnack('Xato'.tr, "Serial topilmadi".tr);
    return;
  }

  if (Get.isRegistered<SeriesDetailController>()) {
    final current = Get.find<SeriesDetailController>();
    if (current.series.id == seriesId && Get.currentRoute == Routes.SERIES_DETAIL) {
      current.fetchDetails(silent: true);
      return;
    }
    Get.until((r) => r.settings.name != Routes.SERIES_DETAIL && r.settings.name != Routes.PLAYER);
    for (var i = 0; i < 30 && Get.isRegistered<SeriesDetailController>(); i++) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }
  Get.toNamed(Routes.SERIES_DETAIL, arguments: series);
}
