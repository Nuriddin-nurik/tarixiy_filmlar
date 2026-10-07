import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/views/home_view.dart';
import '../../main/views/main_view.dart';

class CatalogView extends StatefulWidget {
  const CatalogView({super.key});

  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView> {
  final home = Get.find<HomeController>();
  String query = '';
  String? genre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          final all = home.series;
          final genres = home.seriesByGenre.keys.toList();
          final filtered = all.where((s) {
            final matchQuery = query.isEmpty || (s.title ?? '').toLowerCase().contains(query.toLowerCase());
            final matchGenre = genre == null || s.genreNames.contains(genre);
            return matchQuery && matchGenre;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                child: Text(
                  'Seriallar'.tr,
                  style: TextStyle(color: AppColors.gold, fontSize: 22.sp, fontWeight: FontWeight.w800, letterSpacing: 1),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TextField(
                  onChanged: (v) => setState(() => query = v),
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  cursorColor: AppColors.green,
                  decoration: InputDecoration(
                    hintText: 'Serial nomini qidiring...'.tr,
                    hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14.sp),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppColors.green),
                    ),
                  ),
                ),
              ),
              if (genres.isNotEmpty) ...[
                SizedBox(height: 12.h),
                SizedBox(
                  height: 34.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    children: [
                      _filterChip('Barchasi'.tr, genre == null, () => setState(() => genre = null)),
                      for (final g in genres) _filterChip(g, genre == g, () => setState(() => genre = g)),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 12.h),
              Expanded(
                child: filtered.isEmpty
                    ? EmptyState(icon: Icons.search_off_rounded, title: 'Hech narsa topilmadi'.tr)
                    : RefreshIndicator(
                        color: AppColors.green,
                        backgroundColor: AppColors.surface,
                        onRefresh: home.fetchHomeData,
                        child: GridView.builder(
                          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, kFloatingNavSpace),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 16.h,
                            childAspectRatio: 0.54,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => SeriesPosterCard(series: filtered[i], width: double.infinity),
                        ),
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.green,
        side: BorderSide(color: selected ? AppColors.green : AppColors.border),
        labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontSize: 12.sp),
      ),
    );
  }
}
