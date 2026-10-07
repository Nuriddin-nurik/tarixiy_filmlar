import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../controllers/main_controller.dart';
import '../../home/views/home_view.dart';
import '../../catalog/views/catalog_view.dart';
import '../../favorites/views/favorites_view.dart';
import '../../profile/views/profile_view.dart';

double get kFloatingNavSpace => 67.h + 32.h + MediaQueryData.fromView(
        WidgetsBinding.instance.platformDispatcher.views.first)
    .padding
    .bottom;

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Obx(() => Row(
                      children: [
                        _buildNavItem(0, 'nav_home', 'Bosh sahifa'),
                        _buildNavItem(1, 'nav_episodes', 'Epizodlar'),
                        _buildNavItem(2, 'nav_favorites', 'Sevimlilar'),
                        _buildNavItem(3, 'nav_profile', 'Profil'),
                      ],
                    )),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String icon, String label) {
    final isSelected = controller.currentIndex.value == index;
    final color = isSelected ? AppColors.green : Colors.white.withValues(alpha: 0.8);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.changePage(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
            border: Border.all(color: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(icon, size: 18.w, color: color),
              SizedBox(height: 2.h),
              Text(
                label.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
