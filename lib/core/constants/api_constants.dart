class ApiConstants {
  static const String baseUrl = 'https://api.tarixiykinolar.uz';

  // Endpoints
  static const String signIn = '/auth/sign-in';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String home = '/home';
  static const String seriesAll = '/series/all';
  static const String seriesLiked = '/series/liked';
  static const String mySubscription = '/account/subscription';
  static const String continueWatching = '/series/continue-watching';

  static const String subscriptionPlans = '/subscription/plans';
  static const String createPayment = '/api/payment/create';
  static const String deleteAccount = '/account/me';
  static const String fcmToken = '/account/fcm-token';
  static const String notifications = '/api/notifications/me';
  static const String notificationsUnread = '/api/notifications/unread-count';
  static const String notificationsReadAll = '/api/notifications/read-all';
  static String notificationRead(int id) => '/api/notifications/$id/read';

  static String getEpisodes(int seriesId) => '/series/$seriesId/episodes';
  static String seriesDetails(int seriesId) => '/series/$seriesId';
  static String toggleLike(int seriesId) => '/series/$seriesId/like';
  static String saveProgress(int seriesId, int episodeId) =>
      '/series/$seriesId/episode/$episodeId/progress';
}
