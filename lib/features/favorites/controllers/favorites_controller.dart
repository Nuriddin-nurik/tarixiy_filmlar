import 'package:get/get.dart';

import '../../../data/models/series_model.dart';
import '../../../data/providers/api_provider.dart';

class FavoritesController extends GetxController {
  final ApiProvider _apiProvider = ApiProvider();

  var favorites = <SeriesModel>[].obs;
  var isLoading = false.obs;

  Future<void> load() async {
    if (isLoading.value) return;
    try {
      isLoading(true);
      favorites.value = await _apiProvider.getLikedSeries();
    } catch (_) {
    } finally {
      isLoading(false);
    }
  }
}
