import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/i18n/locale_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../player/controllers/download_controller.dart';
import 'language_sheet.dart';
import '../../../core/widgets/app_widgets.dart';

/// Ilova sozlamalari: til, kesh, yuklanmalarni tozalash.
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final downloads = Get.find<DownloadController>();
  double? downloadsMb;

  @override
  void initState() {
    super.initState();
    _refreshSize();
  }

  Future<void> _refreshSize() async {
    final mb = await downloads.totalSizeMb();
    if (mounted) setState(() => downloadsMb = mb);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Ilova sozlamalari'.tr)),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _tile(
            icon: Icons.language,
            title: 'Til'.tr,
            trailing: LocaleService.currentName,
            onTap: () async {
              await showLanguageSheet();
              setState(() {});
            },
          ),
          _tile(
            icon: Icons.image_outlined,
            title: 'Rasmlar keshini tozalash'.tr,
            onTap: () async {
              await DefaultCacheManager().emptyCache();
              PaintingBinding.instance.imageCache.clear();
              appSnack('Tayyor'.tr, 'Kesh tozalandi'.tr);
            },
          ),
          _tile(
            icon: Icons.delete_sweep_outlined,
            title: "Barcha yuklanmalarni o'chirish".tr,
            trailing: downloadsMb == null ? null : '${downloadsMb!.toStringAsFixed(0)} MB',
            onTap: () => Get.dialog(AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text("Barcha yuklanmalarni o'chirish".tr, style: const TextStyle(color: Colors.white)),
              content: Text("Yuklab olingan barcha qismlar telefondan o'chiriladi.".tr,
                  style: const TextStyle(color: AppColors.textSecondary)),
              actions: [
                TextButton(
                  onPressed: Get.back,
                  child: Text('Bekor qilish'.tr, style: const TextStyle(color: AppColors.textSecondary)),
                ),
                TextButton(
                  onPressed: () async {
                    Get.back();
                    await downloads.deleteAll();
                    _refreshSize();
                  },
                  child: Text("O'chirish".tr, style: const TextStyle(color: AppColors.danger)),
                ),
              ],
            )),
          ),
          SizedBox(height: 24.h),
          Center(
            child: Text('${'Versiya'.tr} ${AppConfig.appVersion}',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp)),
          ),
        ],
      ),
    );
  }

  Widget _tile({required IconData icon, required String title, String? trailing, required VoidCallback onTap}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(12.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: Colors.white, size: 22.sp),
          title: Text(title, style: TextStyle(color: Colors.white, fontSize: 14.sp)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailing != null)
                Text(trailing, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
