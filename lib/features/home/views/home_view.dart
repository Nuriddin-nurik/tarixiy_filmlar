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
import '../../main/views/main_view.dart';
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
        final genres = controller.seriesByGenre.entries.toList();
        final all = controller.series;
        void openCatalog() => Get.find<MainController>().changePage(1);

        Widget genreSection(MapEntry<String, List<SeriesModel>> e, String icon, {double top = 0}) => Padding(
              padding: EdgeInsets.only(top: top, bottom: 28.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: e.key,
                    subtitle: '@n ta serial'.trParams({'n': '${e.value.length}'}),
                    icon: icon,
                    onSeeAll: openCatalog,
                  ),
                  SizedBox(height: 14.h),
                  _PosterRow(series: e.value),
                ],
              ),
            );

        return Stack(
          children: [
            RefreshIndicator(
              color: AppColors.green,
              backgroundColor: AppColors.surface,
              onRefresh: controller.fetchHomeData,
              child: ListView(
                padding: EdgeInsets.only(top: _TopBar.heightOf(context), bottom: kFloatingNavSpace),
                children: [
                  if (banners.isNotEmpty) _HeroCarousel(banners: banners),

                  if (controller.continueWatching.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 16.h, bottom: 28.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: "Ko'rishni davom etish".tr,
                            accentBar: true,
                            onSeeAll: openCatalog,
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            height: 128.h + 8.h + 18.h + 4.h + 16.h + 4.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              itemCount: controller.continueWatching.length,
                              separatorBuilder: (_, __) => SizedBox(width: 14.w),
                              itemBuilder: (_, i) => _ContinueCard(item: controller.continueWatching[i]),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (all.isNotEmpty)
                    genreSection(MapEntry('Barcha seriallar'.tr, all), 'crown_small',
                        top: controller.continueWatching.isEmpty ? 16.h : 0),

                  for (var i = 0; i < genres.length; i++) genreSection(genres[i], 'gold_dot'),

                  if (genres.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 40.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: 'Janrlar'.tr,
                            subtitle: "Kategoriyalar bo'yicha saralash".tr,
                            icon: 'genres_small',
                            onSeeAll: openCatalog,
                          ),
                          SizedBox(height: 16.h),
                          SizedBox(
                            height: 64.h + 8.h + 16.h + 12.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              itemCount: genres.length,
                              separatorBuilder: (_, __) => SizedBox(width: 14.w),
                              itemBuilder: (_, i) => _GenreChip(
                                name: genres[i].key,
                                highlighted: i == 0,
                                onTap: openCatalog,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

  static double heightOf(BuildContext context) => MediaQuery.of(context).padding.top + 8.h + 36.h + 16.h;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, top + 8.h, 20.w, 16.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.85),
                Colors.black.withValues(alpha: 0.4),
                Colors.black.withValues(alpha: 0),
              ],
            ),
          ),
          child: Row(
            children: [
              Image.asset('assets/logo.png', width: 90.w, height: 36.h, fit: BoxFit.contain),
              const Spacer(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Get.find<MainController>().changePage(1),
                child: Padding(padding: EdgeInsets.all(4.w), child: AppIcon('search', size: 18.w)),
              ),
              SizedBox(width: 12.w),
              Obx(() {
                final unread = Get.find<NotificationsController>().unreadCount.value;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Get.toNamed(Routes.NOTIFICATIONS),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AppIcon('bell', size: 18.w),
                        if (unread > 0)
                          Positioned(
                            right: -4.w,
                            top: -4.w,
                            child: Container(
                              width: 10.w,
                              height: 10.w,
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
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
    final height = 470.h;
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
              bottom: 26.h,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: widget.banners.length,
                  effect: ExpandingDotsEffect(
                    dotWidth: 6.w,
                    dotHeight: 6.w,
                    spacing: 6.w,
                    radius: 3.w,
                    expansionFactor: 20 / 6,
                    dotColor: Colors.white.withValues(alpha: 0.3),
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
    final words = (movie?.title ?? banner.seriesTitle ?? '').trim().split(RegExp(r'\s+'));
    final title = words.first;
    final subtitle = words.skip(1).join(' ');

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
                stops: const [0, 0.3, 0.6, 0.85, 1],
                colors: [
                  AppColors.background.withValues(alpha: 0.15),
                  AppColors.background.withValues(alpha: 0.05),
                  AppColors.background.withValues(alpha: 0.45),
                  AppColors.background.withValues(alpha: 0.88),
                  AppColors.background,
                ],
              ),
            ),
          ),
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 48.h,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.2),
                        border: Border.all(color: AppColors.green.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'TAVSIYA ETILADI'.tr,
                        style: TextStyle(
                          color: AppColors.green,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          height: 16.5 / 11,
                        ),
                      ),
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
                    fontFamily: AppFonts.cinzel,
                    color: AppColors.gold,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    height: 36 / 30,
                    shadows: [Shadow(blurRadius: 10, offset: const Offset(0, 2), color: Colors.black.withValues(alpha: 0.8))],
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.cinzel,
                      color: AppColors.goldDark,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                      height: 16 / 12,
                    ),
                  ),
                ],
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
    final w = 225.w;
    final left = item.durationSeconds - item.positionSeconds;
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.PLAYER, arguments: {
        'seriesId': item.seriesId,
        'episodeId': item.episodeId,
        'title': item.seriesTitle,
      }),
      child: SizedBox(
        width: w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: w,
              height: 128.h,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 4))],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(item.episodeThumbnail ?? item.seriesImagePath),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 4,
                      color: Colors.white.withValues(alpha: 0.2),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: item.progress,
                        child: Container(
                          decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.seriesTitle ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600, height: 17.5 / 14),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '@n-qism • @t qoldi'.trParams({'n': '${item.episodeNumber ?? ''}', 't': formatDuration(left)}),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp, height: 16 / 12),
                  ),
                ],
              ),
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
    return SizedBox(
      height: 175.h + 8.h + 34.sp + 4.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: series.length,
        separatorBuilder: (_, __) => SizedBox(width: 14.w),
        itemBuilder: (_, i) => SeriesPosterCard(series: series[i]),
      ),
    );
  }
}

class SeriesPosterCard extends StatelessWidget {
  const SeriesPosterCard({super.key, required this.series, this.width});
  final SeriesModel series;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final w = width ?? 125.w;
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.SERIES_DETAIL, arguments: series),
      child: SizedBox(
        width: w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 125 / 175,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 4))],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(series.imagePath),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    series.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600, height: 15 / 12),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    series.genreNames.join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 10.sp, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.name, required this.onTap, this.highlighted = false});
  final String name;
  final VoidCallback onTap;
  final bool highlighted;

  static String _iconFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('sulton') || n.contains('saltanat')) return 'genre_sultonlar';
    if (n.contains('jang')) return 'genre_jangari';
    if (n.contains('din') || n.contains('ibrat')) return 'genre_diniy';
    if (n.contains('drama')) return 'genre_drama';
    if (n.contains('sarguzasht')) return 'genre_sarguzasht';
    return 'genre_tarixiy';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72.w,
        child: Column(
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: highlighted ? AppColors.green.withValues(alpha: 0.2) : AppColors.surface,
                border: Border.all(color: highlighted ? AppColors.green : AppColors.border),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: highlighted
                    ? [BoxShadow(color: AppColors.green.withValues(alpha: 0.35), blurRadius: 12)]
                    : null,
              ),
              child: AppIcon(_iconFor(name), size: 24.w),
            ),
            SizedBox(height: 8.h),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: highlighted ? AppColors.green : AppColors.textSecondary,
                fontSize: 12.sp,
                fontWeight: highlighted ? FontWeight.w600 : FontWeight.w500,
                height: 16 / 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
