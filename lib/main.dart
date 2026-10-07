import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/i18n/app_translations.dart';
import 'core/i18n/locale_service.dart';
import 'core/theme/app_colors.dart';
import 'core/notifications/push_service.dart';
import 'features/notifications/controllers/notifications_controller.dart';
import 'features/player/controllers/download_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MediaKit.ensureInitialized();

  await ScreenUtil.ensureScreenSize();

  final prefs = await SharedPreferences.getInstance();
  final loggedIn = (prefs.getString('access_token') ?? '').isNotEmpty;

  final locale = await LocaleService.load();

  DownloadController.initService();
  Get.put(DownloadController(), permanent: true);
  final notifications = Get.put(NotificationsController(), permanent: true);

  await PushService.init();
  if (loggedIn) {
    PushService.registerToken();
    notifications.refreshUnread();
  }

  runApp(MyApp(initialRoute: loggedIn ? Routes.MAIN : Routes.AUTH, locale: locale));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialRoute, required this.locale});

  final String initialRoute;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Tarixiy Kinolar',
          theme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: AppFonts.inter,
            scaffoldBackgroundColor: AppColors.background,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.green,
              secondary: AppColors.gold,
              surface: AppColors.surface,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Colors.white,
            ),
            snackBarTheme: const SnackBarThemeData(backgroundColor: AppColors.surface),
          ),
          translations: AppTranslations(),
          locale: locale,
          fallbackLocale: LocaleService.uz,
          initialRoute: initialRoute,
          getPages: AppPages.pages,
        );
      },
    );
  }
}
