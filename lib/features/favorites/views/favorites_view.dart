import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../home/views/home_view.dart';
import '../controllers/favorites_controller.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
              child: Text(
                'Sevimlilar'.tr,
                style: TextStyle(color: AppColors.gold, fontSize: 22.sp, fontWeight: FontWeight.w800, letterSpacing: 1),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.favorites.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.green));
                }
                if (controller.favorites.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.green,
                    onRefresh: () => controller.load(),
                    child: ListView(
                      children: [
                        SizedBox(height: 120.h),
                        EmptyState(
                          icon: Icons.favorite_border_rounded,
                          title: "Sevimlilar ro'yxati bo'sh".tr,
                          message: "Serial sahifasida 👍 tugmasini bosing, u shu yerda paydo bo'ladi.".tr,
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  color: AppColors.green,
                  backgroundColor: AppColors.surface,
                  onRefresh: () => controller.load(),
                  child: GridView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 0.52,
                    ),
                    itemCount: controller.favorites.length,
                    itemBuilder: (_, i) => SeriesPosterCard(series: controller.favorites[i], width: double.infinity),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
