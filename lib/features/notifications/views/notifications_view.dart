import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/models/notification_model.dart';
import '../../../core/utils/open_series.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final controller = Get.find<NotificationsController>();

  @override
  void initState() {
    super.initState();
    controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Bildirishnomalar'.tr),
        actions: [
          Obx(() => controller.unreadCount.value > 0
              ? TextButton(
                  onPressed: controller.markAllRead,
                  child: Text("Hammasini o'qish".tr, style: const TextStyle(color: AppColors.greenLight)),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.items.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.green));
        }
        if (controller.hasError.value && controller.items.isEmpty) {
          return EmptyState(
            icon: Icons.wifi_off_rounded,
            title: 'Xatolik'.tr,
            message: "Ma'lumotlarni yuklab bo'lmadi.".tr,
            action: TextButton(
              onPressed: controller.load,
              child: Text('Qayta urinish'.tr, style: const TextStyle(color: AppColors.greenLight)),
            ),
          );
        }
        if (controller.items.isEmpty) {
          return RefreshIndicator(
            color: AppColors.green,
            onRefresh: controller.load,
            child: ListView(
              children: [
                SizedBox(height: 140.h),
                EmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: "Hozircha yangi bildirishnoma yo'q".tr,
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: AppColors.green,
          backgroundColor: AppColors.surface,
          onRefresh: controller.load,
          child: ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.items.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (_, i) => _tile(controller.items[i]),
          ),
        );
      }),
    );
  }

  Widget _tile(NotificationModel n) {
    return Material(
      color: n.read ? AppColors.surface : AppColors.green.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: n.read ? AppColors.border : AppColors.green.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          controller.markRead(n);
          if (n.seriesId != null) openSeriesById(n.seriesId!);
        },
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(color: AppColors.surfaceLight, shape: BoxShape.circle),
                child: Icon(_icon(n.type), color: AppColors.gold, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(n.title,
                              style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                        ),
                        if (!n.read)
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(color: AppColors.greenLight, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(n.body, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp, height: 1.4)),
                    if (n.imageUrl != null && n.imageUrl!.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: AppNetworkImage(n.imageUrl, height: 140.h, width: double.infinity),
                      ),
                    ],
                    if (n.createdAt != null) ...[
                      SizedBox(height: 6.h),
                      Text(_date(n.createdAt!), style: TextStyle(color: AppColors.textMuted, fontSize: 10.sp)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(String? type) {
    final t = (type ?? '').toUpperCase();
    if (t.contains('PAYMENT') || t.contains('PURCHASE')) return Icons.receipt_long_rounded;
    if (t.contains('SUBSCRIPTION') || t.contains('EXPIR')) return Icons.workspace_premium_rounded;
    if (t.contains('EPISODE') || t.contains('SERIES')) return Icons.movie_outlined;
    return Icons.notifications_rounded;
  }

  String _date(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    final l = d.toLocal();
    return '${two(l.day)}.${two(l.month)}.${l.year} ${two(l.hour)}:${two(l.minute)}';
  }
}
