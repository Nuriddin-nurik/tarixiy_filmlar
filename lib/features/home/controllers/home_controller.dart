import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/models/home_response_model.dart';
import '../../../data/models/series_model.dart';
import '../../../data/models/continue_watching_model.dart';

class HomeController extends GetxController {
  final ApiProvider _apiProvider = ApiProvider();

  var isLoading = true.obs;
  var homeData = Rxn<HomeResponseModel>();
  var continueWatching = <ContinueWatchingModel>[].obs;
  var errorMessage = ''.obs;
  var bannerIndex = 0.obs;
  var needsLogin = false.obs;

  List<SeriesModel> get series => homeData.value?.series ?? const [];

  /// Seriallarni janr bo'yicha guruhlaydi (Bosh sahifadagi bo'limlar uchun).
  Map<String, List<SeriesModel>> get seriesByGenre {
    final map = <String, List<SeriesModel>>{};
    for (final s in series) {
      for (final g in s.genreNames) {
        map.putIfAbsent(g, () => []).add(s);
      }
    }
    return map;
  }

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    try {
      isLoading(true);
      errorMessage.value = '';
      needsLogin.value = false;
      final response = await _apiProvider.getHomeData();
      if (response != null) {
        homeData.value = response;
      } else {
        errorMessage.value = 'Serverdan javob kelmadi'.tr;
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      needsLogin.value = status == 401 || status == 403;
      errorMessage.value = needsLogin.value
          ? "Seriallarni ko'rish uchun tizimga kiring".tr
          : "Ma'lumotlarni yuklab bo'lmadi. Internetni tekshiring.".tr;
    } catch (e) {
      errorMessage.value = "Ma'lumotlarni yuklab bo'lmadi.".tr;
    } finally {
      isLoading(false);
    }
    _fetchContinueWatching();
  }

  Future<void> _fetchContinueWatching() async {
    try {
      continueWatching.value = await _apiProvider.getContinueWatching();
    } catch (_) {
      // Ixtiyoriy bo'lim — xato bo'lsa shunchaki ko'rsatilmaydi.
    }
  }
}
