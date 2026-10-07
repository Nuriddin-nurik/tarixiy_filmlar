import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/models/series_model.dart';
import '../../../data/models/subscription_models.dart';
import '../../../data/providers/api_provider.dart';
import 'purchase_sheet.dart';

Future<void> showUnlockSheet(SeriesModel series, List<SubscriptionPlanModel> plans) async {
  if (series.monthlyPrice != null || series.quarterlyPrice != null) {
    await showPurchaseSheet(
      seriesId: series.id,
      title: series.title ?? '',
      monthlyPrice: series.monthlyPrice,
      quarterlyPrice: series.quarterlyPrice,
    );
    return;
  }
  final plan = series.subscriptionBased == true ? plans.firstWhereOrNull((p) => p.monthlyPrice != null) : null;
  if (plan != null) {
    await showPurchaseSheet(
      planId: plan.id,
      title: plan.name,
      monthlyPrice: plan.monthlyPrice,
      quarterlyPrice: plan.quarterlyPrice,
    );
    return;
  }
  await Get.toNamed(Routes.SUBSCRIPTION);
}

Future<void> showUnlockSheetFor(int seriesId) async {
  final api = ApiProvider();
  try {
    final results = await Future.wait([api.getAllSeries(), api.getSubscriptionPlans()]);
    final series = (results[0] as List<SeriesModel>).firstWhereOrNull((s) => s.id == seriesId);
    if (series == null) {
      await Get.toNamed(Routes.SUBSCRIPTION);
      return;
    }
    await showUnlockSheet(series, results[1] as List<SubscriptionPlanModel>);
  } catch (_) {
    appSnack('Xato'.tr, "Internetni tekshirib, qayta urinib ko'ring".tr);
  }
}
