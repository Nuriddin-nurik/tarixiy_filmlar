import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/models/continue_watching_model.dart';
import '../../../data/models/series_model.dart';
import '../../main/controllers/main_controller.dart';
import '../controllers/home_controller.dart';
import '../../notifications/controllers/notifications_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value && controller.homeData.value == null) {
          return const Center(child: CircularProgressIndicator(color: AppColors.green));
        }

        if (controller.errorMessage.value.isNotEmpty && controller.homeData.value == null) {
          final needsLogin = controller.needsLogin.value;
          return EmptyState(
            icon: needsLogin ? Icons.lock_outline_rounded : Icons.wifi_off_rounded,
            title: needsLogin ? 'Kirish talab qilinadi'.tr : 'Xatolik'.tr,
            message: controller.errorMessage.value,
            action: ElevatedButton(
              onPressed: needsLogin ? () => Get.offAllNamed(Routes.AUTH) : controller.fetchHomeData,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
              child: Text(needsLogin ? 'Kirish'.tr : 'Qayta urinish'.tr, style: const TextStyle(color: Colors.white)),
            ),
          );
        }

        final data = controller.homeData.value;
        final banners = data?.banners ?? const <BannerModel>[];
        final byGenre = controller.seriesByGenre;

        return Stack(
          children: [
            RefreshIndicator(
              color: AppColors.green,
              backgroundColor: AppColors.surface,
              onRefresh: controller.fetchHomeData,
              child: ListView(
                padding: EdgeInsets.only(bottom: 24.h),
                children: [
                  if (banners.isNotEmpty)
                    _HeroCarousel(banners: banners)
                  else
                    SizedBox(height: MediaQuery.of(context).padding.top + 72.h),

                  if (controller.continueWatching.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    SectionHeader(title: "Ko'rishni davom etish".tr),
                    SizedBox(height: 12.h),
                    SizedBox(
                      height: 150.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: controller.continueWatching.length,
                        separatorBuilder: (_, __) => SizedBox(width: 12.w),
                        itemBuilder: (_, i) => _ContinueCard(item: controller.continueWatching[i]),
                      ),
                    ),
                  ],

                  for (final entry in byGenre.entries) ...[
                    SizedBox(height: 24.h),
                    SectionHeader(
                      title: entry.key,
                      subtitle: '@n ta serial'.trParams({'n': '${entry.value.length}'}),
                      onSeeAll: () => Get.find<MainController>().changePage(1),
                    ),
                    SizedBox(height: 12.h),
                    _PosterRow(series: entry.value),
                  ],

                  if (controller.series.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    SectionHeader(
                      title: 'Barcha seriallar'.tr,
                      onSeeAll: () => Get.find<MainController>().changePage(1),
                    ),
                    SizedBox(height: 12.h),
                    _PosterRow(series: controller.series),
                  ],

                  if (byGenre.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    SectionHeader(title: 'Janrlar'.tr, subtitle: "Kategoriyalar bo'yicha izlash".tr),
                    SizedBox(height: 12.h),
                    SizedBox(
                      height: 84.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: byGenre.length,
                        separatorBuilder: (_, __) => SizedBox(width: 10.w),
                        itemBuilder: (_, i) => _GenreChip(
                          name: byGenre.keys.elementAt(i),
                          onTap: () => Get.find<MainController>().changePage(1),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const _TopBar(),
          ],
        );
      }),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.fromLTRB(12.w, top + 6.h, 4.w, 6.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withValues(alpha: 0.7), Colors.black.withValues(alpha: 0.3)],
            ),
          ),
          child: Row(
            children: [
              Image.asset('assets/logo.png', height: 40.h, fit: BoxFit.contain),
              const Spacer(),
              IconButton(
                onPressed: () => Get.find<MainController>().changePage(1),
                icon: const Icon(Icons.search_rounded, color: Colors.white),
              ),
              Obx(() {
                final unread = Get.find<NotificationsController>().unreadCount.value;
                return IconButton(
                  onPressed: () => Get.toNamed(Routes.NOTIFICATIONS),
                  icon: Badge(
                    isLabelVisible: unread > 0,
                    backgroundColor: AppColors.danger,
                    label: Text(unread > 99 ? '99+' : '$unread'),
                    child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel({required this.banners});
  final List<BannerModel> banners;

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  final _pageController = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.banners.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 6), (_) {
        if (!_pageController.hasClients) return;
        final next = ((_pageController.page?.round() ?? 0) + 1) % widget.banners.length;
        _pageController.animateToPage(next,
            duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = 460.h;
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            itemBuilder: (_, i) => _HeroItem(banner: widget.banners[i], height: height),
          ),
          if (widget.banners.length > 1)
            Positioned(
              bottom: 8.h,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: widget.banners.length,
                  effect: ExpandingDotsEffect(
                    dotWidth: 6.w,
                    dotHeight: 6.w,
                    expansionFactor: 3,
                    dotColor: Colors.white24,
                    activeDotColor: AppColors.gold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroItem extends StatelessWidget {
  const _HeroItem({required this.banner, required this.height});
  final BannerModel banner;
  final double height;

  @override
  Widget build(BuildContext context) {
    final movie = banner.movie;
    final title = movie?.title ?? banner.seriesTitle ?? '';
    final genre = movie?.genreNames.isNotEmpty == true ? movie!.genreNames.first : 'Tarixiy serial'.tr;

    return GestureDetector(
      onTap: movie == null ? null : () => Get.toNamed(Routes.SERIES_DETAIL, arguments: movie),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppNetworkImage(banner.image ?? movie?.imagePath, height: height),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.35, 0.75, 1],
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                  AppColors.background.withValues(alpha: 0.85),
                  AppColors.background,
                ],
              ),
            ),
          ),
          Positioned(
            left: 24.w,
            right: 24.w,
            bottom: 28.h,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.2),
                    border: Border.all(color: AppColors.green),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    genre.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.greenLight,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    height: 1.1,
                    shadows: const [Shadow(blurRadius: 12, color: Colors.black)],
                  ),
                ),
                SizedBox(height: 16.h),
                if (movie != null)
                  SizedBox(
                    height: 42.h,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.toNamed(Routes.SERIES_DETAIL, arguments: movie),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                      label: Text(
                        'Tomosha qilish'.tr,
                        style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.item});
  final ContinueWatchingModel item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.PLAYER, arguments: {
        'seriesId': item.seriesId,
        'episodeId': item.episodeId,
        'title': item.seriesTitle,
      }),
      child: SizedBox(
        width: 190.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: SizedBox(
                height: 105.h,
                width: 190.w,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(item.episodeThumbnail ?? item.seriesImagePath),
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22.sp),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: LinearProgressIndicator(
                        value: item.progress,
                        minHeight: 3,
                        backgroundColor: Colors.white24,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              item.seriesTitle ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
            Text(
              '@n-qism • @t qoldi'.trParams({'n': '${item.episodeNumber ?? ''}', 't': formatDuration(item.durationSeconds - item.positionSeconds)}),
              maxLines: 1,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp),
            ),
          ],
        ),
      ),
    );
  }
}

class _PosterRow extends StatelessWidget {
  const _PosterRow({required this.series});
  final List<SeriesModel> series;

  @override
  Widget build(BuildContext context) {
    // Poster 2:3 nisbatda (120.w * 1.5) + ostidagi ikki qator matn.
    return SizedBox(
      height: 120.w * 1.5 + 50.sp,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: series.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (_, i) => SeriesPosterCard(series: series[i]),
      ),
    );
  }
}

/// Vertikal poster kartochkasi (bosh sahifa va katalogda ishlatiladi).
class SeriesPosterCard extends StatelessWidget {
  const SeriesPosterCard({super.key, required this.series, this.width});
  final SeriesModel series;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final w = width ?? 120.w;
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.SERIES_DETAIL, arguments: series),
      child: SizedBox(
        width: w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(series.imagePath),
                    if ((series.freeEpisodesCount ?? 0) > 0)
                      Positioned(
                        top: 6.h,
                        left: 6.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'BEPUL'.tr,
                            style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              series.title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
            Text(
              series.genreNames.join(', '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 10.sp),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.name, required this.onTap});
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 84.w,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_moon_outlined, color: AppColors.gold, size: 24.sp),
            SizedBox(height: 6.h),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp),
            ),
          ],
        ),
      ),
    );
  }
}
