import 'package:get/get.dart';

import '../../data/models/series_model.dart';
import '../../data/providers/api_provider.dart';
import '../../features/home/controllers/home_controller.dart';
import '../routes/app_routes.dart';
import '../widgets/app_widgets.dart';

/// Serialni faqat id bo'yicha ochadi (push yoki bildirishnoma bosilganda).
/// Avval bosh sahifadagi ro'yxatdan qidiradi, topilmasa serverdan so'raydi.
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
  Get.toNamed(Routes.SERIES_DETAIL, arguments: series);
}
