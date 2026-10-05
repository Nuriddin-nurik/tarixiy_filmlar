import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/main_controller.dart';
import '../../home/views/home_view.dart';
import '../../catalog/views/catalog_view.dart';
import '../../favorites/views/favorites_view.dart';
import '../../profile/views/profile_view.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        return IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            HomeView(),
            CatalogView(),
            FavoritesView(),
            ProfileView(),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_rounded, 'Bosh sahifa'),
                  _buildNavItem(1, Icons.grid_view_rounded, 'Epizodlar'),
                  _buildNavItem(2, Icons.favorite_border_rounded, 'Sevimlilar'),
                  _buildNavItem(3, Icons.person_outline_rounded, 'Profil'),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = controller.currentIndex.value == index;
    final color = isSelected ? AppColors.greenLight : AppColors.textSecondary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.changePage(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.green.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22.sp),
            SizedBox(height: 3.h),
            Text(
              label.tr,
              style: TextStyle(
                color: color,
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
