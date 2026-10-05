import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/home_response_model.dart';
import '../models/episode_model.dart';
import '../models/series_model.dart';
import '../models/series_details_model.dart';
import '../models/continue_watching_model.dart';
import '../models/subscription_models.dart';
import '../models/notification_model.dart';

class ApiProvider {
  final DioClient _dioClient = DioClient();

  Future<HomeResponseModel?> getHomeData() async {
    final response = await _dioClient.dio.get(ApiConstants.home);
    if (response.statusCode == 200) {
      return HomeResponseModel.fromJson(response.data);
    }
    return null;
  }

  Future<List<SeriesModel>> getAllSeries() async {
    final response = await _dioClient.dio.get(ApiConstants.seriesAll);
    return (response.data as List).map((i) => SeriesModel.fromJson(i)).toList();
  }

  Future<List<SeriesModel>> getLikedSeries() async {
    final response = await _dioClient.dio.get(ApiConstants.seriesLiked);
    return (response.data as List).map((i) => SeriesModel.fromJson(i)).toList();
  }

  Future<MySubscriptionModel> getMySubscription() async {
    final response = await _dioClient.dio.get(ApiConstants.mySubscription);
    return MySubscriptionModel.fromJson(response.data);
  }

  Future<List<ContinueWatchingModel>> getContinueWatching() async {
    final response = await _dioClient.dio.get(ApiConstants.continueWatching);
    return (response.data as List).map((i) => ContinueWatchingModel.fromJson(i)).toList();
  }

  Future<SeriesDetailsModel> getSeriesDetails(int seriesId) async {
    final response = await _dioClient.dio.get(ApiConstants.seriesDetails(seriesId));
    return SeriesDetailsModel.fromJson(response.data);
  }

  /// Like ni almashtiradi. Qaytaradi: (liked, likeCount)
  Future<(bool, int)> toggleLike(int seriesId) async {
    final response = await _dioClient.dio.post(ApiConstants.toggleLike(seriesId));
    final data = response.data as Map<String, dynamic>;
    return (data['liked'] as bool? ?? false, (data['likeCount'] as num?)?.toInt() ?? 0);
  }

  Future<List<EpisodeModel>> getEpisodes(int seriesId) async {
    final response = await _dioClient.dio.get(ApiConstants.getEpisodes(seriesId));
    if (response.statusCode == 200) {
      return (response.data as List).map((i) => EpisodeModel.fromJson(i)).toList();
    }
    return [];
  }

  Future<void> saveProgress(int seriesId, int episodeId, int positionSeconds) async {
    await _dioClient.dio.post(
      ApiConstants.saveProgress(seriesId, episodeId),
      data: {'positionSeconds': positionSeconds},
    );
  }

  Future<List<SubscriptionPlanModel>> getSubscriptionPlans() async {
    final response = await _dioClient.dio.get(ApiConstants.subscriptionPlans);
    return (response.data as List).map((i) => SubscriptionPlanModel.fromJson(i)).toList();
  }

  /// To'lov order yaratadi. Obuna uchun [planId], alohida serial uchun [seriesId] beriladi.
  Future<PaymentOrderModel> createPaymentOrder({int? planId, int? seriesId, required int months}) async {
    final response = await _dioClient.dio.post(ApiConstants.createPayment, data: {
      'subscriptionPlanId': planId,
      'seriesId': seriesId,
      'durationMonths': months,
    });
    return PaymentOrderModel.fromJson(response.data);
  }

  // ───────────── Bildirishnomalar ─────────────

  Future<void> updateFcmToken(String token) async {
    await _dioClient.dio.put(ApiConstants.fcmToken, data: {'fcmToken': token});
  }

  Future<List<NotificationModel>> getNotifications({int days = 30}) async {
    final response = await _dioClient.dio.get(ApiConstants.notifications, queryParameters: {'days': days});
    return (response.data as List).map((i) => NotificationModel.fromJson(i)).toList();
  }

  Future<int> getUnreadNotificationCount() async {
    final response = await _dioClient.dio.get(ApiConstants.notificationsUnread);
    return ((response.data as Map)['count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markNotificationRead(int id) async {
    await _dioClient.dio.put(ApiConstants.notificationRead(id));
  }

  Future<void> markAllNotificationsRead() async {
    await _dioClient.dio.put(ApiConstants.notificationsReadAll);
  }

  Future<void> deleteAccount() async {
    await _dioClient.dio.delete(ApiConstants.deleteAccount);
  }

  Future<void> logout(String email) async {
    await _dioClient.dio.post(ApiConstants.logout, data: {'email': email});
  }

  // Avtorizatsiya uchun
  Future<Map<String, dynamic>?> signIn(String email, String password, String deviceId) async {
    final response = await _dioClient.dio.post(
      ApiConstants.signIn,
      data: {
        'email': email,
        'password': password,
        'deviceId': deviceId
      },
    );
    if (response.statusCode == 200) {
      return response.data;
    }
    return null;
  }
}
