import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/secure_video/secure_hls_downloader.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/models/episode_model.dart';
import '../controllers/download_controller.dart';

/// Qism yonidagi yuklab olish tugmasi:
/// yuklanmagan → sifat tanlash, yuklanmoqda → foiz (bosilsa bekor qilish),
/// to'xtagan → davom ettirish, yuklangan → o'chirish.
class DownloadButton extends StatelessWidget {
  const DownloadButton({
    super.key,
    required this.episode,
    required this.seriesId,
    required this.seriesTitle,
  });

  final EpisodeModel episode;
  final int seriesId;
  final String seriesTitle;

  DownloadController get _dc => Get.find<DownloadController>();

  @override
  Widget build(BuildContext context) {
    final id = episode.id!;
    return Obx(() {
      final progress = _dc.downloadProgress[id];
      // downloads ni o'qish Obx ni ro'yxat o'zgarishlariga bog'laydi.
      _dc.downloads.length;

      if (_dc.isComplete(id)) {
        return IconButton(
          icon: const Icon(Icons.offline_pin_rounded, color: AppColors.greenLight),
          onPressed: () => _confirm(
            title: "Yuklanmani o'chirish".tr,
            message: "Bu qism telefondan o'chiriladi.".tr,
            action: "O'chirish".tr,
            onConfirm: () => _dc.delete(id),
          ),
        );
      }
      if (progress != null) {
        return InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _confirm(
            title: 'Yuklashni bekor qilish'.tr,
            message: "Yuklangan qismi o'chiriladi.".tr,
            action: 'Bekor qilish'.tr,
            onConfirm: () => _dc.cancel(id),
          ),
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: SizedBox(
              width: 30.w,
              height: 30.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress == 0 ? null : progress,
                    color: AppColors.green,
                    backgroundColor: AppColors.border,
                    strokeWidth: 2.5,
                  ),
                  Text('${(progress * 100).floor()}',
                      style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        );
      }
      if (_dc.isPaused(id)) {
        return IconButton(
          tooltip: 'Davom ettirish'.tr,
          icon: const Icon(Icons.play_for_work_rounded, color: AppColors.gold),
          onPressed: () => _dc.resume(id),
        );
      }
      return IconButton(
        icon: Icon(Icons.download_rounded, color: AppColors.greenLight, size: 22.sp),
        onPressed: _pickQuality,
      );
    });
  }

  Future<void> _pickQuality() async {
    final url = episode.videoUrl;
    if (url == null) {
      appSnack('Xato'.tr, 'Video havolasi mavjud emas'.tr);
      return;
    }
    List<HlsVariant> variants;
    try {
      Get.dialog(const Center(child: CircularProgressIndicator(color: AppColors.green)),
          barrierDismissible: false);
      try {
        variants = await _dc.variants(url);
      } finally {
        Get.back();
      }
    } catch (_) {
      appSnack('Xato'.tr, "Internetni tekshiring".tr);
      return;
    }
    if (variants.isEmpty) {
      appSnack('Xato'.tr, 'Video havolasi mavjud emas'.tr);
      return;
    }
    final duration = episode.durationSeconds ?? 0;

    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Yuklab olish sifati'.tr,
                  style: TextStyle(color: AppColors.gold, fontSize: 16.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  "Qism faqat shu ilova ichida ko'riladi, boshqa joyga ko'chirib bo'lmaydi.".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp),
                ),
              ),
              SizedBox(height: 8.h),
              for (final v in variants)
                ListTile(
                  leading: Icon(Icons.hd_outlined,
                      color: v.height >= 720 ? AppColors.gold : AppColors.textSecondary),
                  title: Text('${v.height}p', style: TextStyle(color: Colors.white, fontSize: 15.sp)),
                  subtitle: v.sampledBytes != null || (duration > 0 && v.bandwidth > 0)
                      ? Text('~${_size(v.estimateMb(duration))}',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp))
                      : null,
                  trailing: const Icon(Icons.download_rounded, color: AppColors.greenLight),
                  onTap: () async {
                    Get.back();
                    final needMb = v.sampledBytes != null || duration > 0 ? v.estimateMb(duration) : 0.0;
                    if (!await _checksPass(needMb)) return;
                    _dc.startDownload(
                      DownloadedEpisode(
                        episodeId: episode.id!,
                        seriesId: seriesId,
                        title: episode.title ?? '${episode.episodeNumber}',
                        seriesTitle: seriesTitle,
                        thumbnail: episode.thumbnail,
                      ),
                      v,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
    );
  }

  /// Yuklashdan oldin: telefonda joy yetarlimi va mobil internet bo'lsa ogohlantirish.
  Future<bool> _checksPass(double needMb) async {
    try {
      final free = await const MethodChannel('tarixiy/storage').invokeMethod<int>('freeBytes');
      if (free != null && needMb > 0) {
        final freeMb = free / 1024 / 1024;
        if (freeMb < needMb * 1.1 + 200) {
          appSnack('Joy yetarli emas'.tr,
              '@need kerak, telefonda @free bo\'sh'.trParams({'need': _size(needMb), 'free': _size(freeMb)}));
          return false;
        }
      }
    } catch (_) {}

    final net = await Connectivity().checkConnectivity();
    if (!net.contains(ConnectivityResult.wifi) && net.contains(ConnectivityResult.mobile)) {
      final ok = await Get.dialog<bool>(AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Mobil internet'.tr, style: const TextStyle(color: Colors.white)),
        content: Text(
          'Wi-Fi ulanmagan. Yuklash ~@size mobil trafik sarflaydi. Davom etasizmi?'
              .trParams({'size': _size(needMb)}),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Bekor qilish'.tr, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Davom etish'.tr, style: const TextStyle(color: AppColors.greenLight)),
          ),
        ],
      ));
      return ok == true;
    }
    return true;
  }

  static String _size(double mb) => mb >= 1024 ? '${(mb / 1024).toStringAsFixed(1)} GB' : '${mb.round()} MB';

  void _confirm({
    required String title,
    required String message,
    required String action,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      content: Text(message, style: const TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('Yopish'.tr, style: const TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () {
            Get.back();
            onConfirm();
          },
          child: Text(action, style: const TextStyle(color: AppColors.danger)),
        ),
      ],
    ));
  }
}
