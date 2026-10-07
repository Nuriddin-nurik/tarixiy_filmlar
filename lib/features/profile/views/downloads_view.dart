import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../player/controllers/download_controller.dart';

class DownloadsView extends GetView<DownloadController> {
  const DownloadsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Yuklanmalar'.tr)),
      body: Obx(() {
        final items = controller.downloads;
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.download_outlined,
            title: "Yuklanmalar yo'q".tr,
            message: "Qismni oflayn ko'rish uchun pleyer sahifasidagi yuklab olish tugmasini bosing.".tr,
          );
        }
        return ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: items.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (_, i) {
            final d = items[i];
            return Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Get.toNamed(Routes.PLAYER, arguments: {
                  'seriesId': d.seriesId,
                  'episodeId': d.episodeId,
                  'title': d.seriesTitle,
                }),
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: AppNetworkImage(d.thumbnail, width: 110.w, height: 62.h),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w600)),
                            if (d.seriesTitle != null && d.seriesTitle!.isNotEmpty)
                              Text(d.seriesTitle!,
                                  maxLines: 1,
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp)),
                            SizedBox(height: 2.h),
                            _status(d),
                          ],
                        ),
                      ),
                      if (controller.isPaused(d.episodeId))
                        IconButton(
                          icon: const Icon(Icons.play_for_work_rounded, color: AppColors.gold),
                          onPressed: () => controller.resume(d.episodeId),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                        onPressed: () => controller.delete(d.episodeId),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _status(DownloadedEpisode d) {
    final progress = controller.downloadProgress[d.episodeId];
    final quality = d.quality > 0 ? '${d.quality}p' : '';
    String text;
    Color color;
    if (d.complete) {
      text = [quality, 'Yuklangan'.tr].where((s) => s.isNotEmpty).join(' • ');
      color = AppColors.greenLight;
    } else if (progress != null) {
      text = '${'Yuklanmoqda'.tr} ${(progress * 100).floor()}%';
      color = AppColors.gold;
    } else {
      text = "To'xtatilgan".tr;
      color = AppColors.textMuted;
    }
    return Text(text, style: TextStyle(color: color, fontSize: 11.sp));
  }
}
