import 'package:get/get.dart';
import 'app_routes.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/views/home_view.dart';
import '../../features/main/bindings/main_binding.dart';
import '../../features/main/views/main_view.dart';
import '../../features/player/bindings/player_binding.dart';
import '../../features/player/views/player_view.dart';
import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/views/auth_view.dart';
import '../../features/series/bindings/series_detail_binding.dart';
import '../../features/series/views/series_detail_view.dart';
import '../../features/subscription/views/subscription_view.dart';
import '../../features/profile/views/account_view.dart';
import '../../features/profile/views/settings_view.dart';
import '../../features/profile/views/downloads_view.dart';
import '../../features/profile/views/faq_view.dart';
import '../../features/notifications/views/notifications_view.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.MAIN,
      page: () => const MainView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.PLAYER,
      page: () => const PlayerView(),
      binding: PlayerBinding(),
    ),
    GetPage(
      name: Routes.SERIES_DETAIL,
      page: () => const SeriesDetailView(),
      binding: SeriesDetailBinding(),
    ),
    GetPage(name: Routes.SUBSCRIPTION, page: () => const SubscriptionView()),
    // Profil ichki sahifalari ProfileController/DownloadController dan foydalanadi (MainBinding/main.dart).
    GetPage(name: Routes.ACCOUNT, page: () => const AccountView()),
    GetPage(name: Routes.SETTINGS, page: () => const SettingsView()),
    GetPage(name: Routes.DOWNLOADS, page: () => const DownloadsView()),
    GetPage(name: Routes.FAQ, page: () => const FaqView()),
    GetPage(name: Routes.NOTIFICATIONS, page: () => const NotificationsView()),
    // Qolgan sahifalar shu yerga qo'shiladi
  ];
}
