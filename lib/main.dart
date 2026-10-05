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

  // MediaKit ni ishga tushirish (Video player uchun)
  MediaKit.ensureInitialized();

  // Android'da birinchi kadrda ekran o'lchami 0 bo'ladi, shunda .sp ham 0 chiqib
  // TextField yiqiladi. O'lcham aniq bo'lguncha kutamiz.
  await ScreenUtil.ensureScreenSize();

  // Oldin kirgan foydalanuvchini to'g'ridan-to'g'ri bosh sahifaga olib o'tamiz.
  final prefs = await SharedPreferences.getInstance();
  final loggedIn = (prefs.getString('access_token') ?? '').isNotEmpty;

  final locale = await LocaleService.load();

  // Yuklanmalar butun ilova bo'ylab (pleyer, profil, sozlamalar) ishlatiladi.
  // Ilova yopilganda ham yuklashni davom ettiruvchi foreground service sozlamalari.
  DownloadController.initService();
  Get.put(DownloadController(), permanent: true);
  final notifications = Get.put(NotificationsController(), permanent: true);

  // Push bildirishnomalar (Firebase). Login qilingan bo'lsa token serverga yuboriladi.
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
      designSize: const Size(390, 844), // Figma o'lchami
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Tarixiy Kinolar',
          // Butun ilova qorong'i: standart matn va ikonka ranglari oq bo'ladi.
          theme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: AppFonts.inter, // Figma: butun ilova Inter shriftida
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
