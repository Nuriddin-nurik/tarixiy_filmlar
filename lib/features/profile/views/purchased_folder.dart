import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/open_series.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/models/subscription_models.dart';

class PurchasedFolder extends StatefulWidget {
  const PurchasedFolder({super.key, required this.series});

  final List<SeriesAccessModel> series;

  @override
  State<PurchasedFolder> createState() => _PurchasedFolderState();
}

class _PurchasedFolderState extends State<PurchasedFolder> with SingleTickerProviderStateMixin {
  static const _soft = Color(0xFFC5C6C7);
  static const _backTop = Color(0xFF113324);
  static const _backBottom = Color(0xFF09160F);
  static const _frontTop = Color(0xFF16432F);
  static const _frontBottom = Color(0xFF0B1E15);

  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: Curves.easeOutBack, reverseCurve: Curves.easeInCubic);
  late final Animation<double> _reveal = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _toggle() => _c.isCompleted || _c.status == AnimationStatus.forward ? _c.reverse() : _c.forward();

  String _date(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    final list = widget.series;
    final nearest = list.where((s) => s.endDate != null).fold<SeriesAccessModel?>(
          null,
          (a, b) => a == null || b.daysLeft < a.daysLeft ? b : a,
        );
    final urgent = nearest != null && nearest.daysLeft <= 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggle,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => _folder(list, nearest, urgent),
          ),
        ),
        SizeTransition(
          sizeFactor: _reveal,
          alignment: Alignment.topCenter,
          child: FadeTransition(
            opacity: _reveal,
            child: _list(list),
          ),
        ),
      ],
    );
  }

  Widget _folder(List<SeriesAccessModel> list, SeriesAccessModel? nearest, bool urgent) {
    final t = _t.value;
    final height = 156.h;
    final tabH = 28.h;
    final frontTop = 82.h;
    final posters = list.take(3).toList();
    const baseAngles = [0.16, 0.0, -0.16];
    const spreadAngles = [0.30, 0.02, -0.26];

    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _FolderBackPainter(
                tabHeight: tabH,
                tabWidth: 132.w,
                radius: 14.r,
                top: _backTop,
                bottom: _backBottom,
                stroke: AppColors.green.withValues(alpha: 0.35 + 0.25 * t.clamp(0.0, 1.0)),
              ),
            ),
          ),
          Positioned(
            left: 14.w,
            top: 0,
            height: tabH,
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, size: 13.sp, color: AppColors.seriesGold),
                SizedBox(width: 6.w),
                Text(
                  '@n ta serial'.trParams({'n': '${list.length}'}),
                  style: TextStyle(
                    fontFamily: AppFonts.cinzel,
                    color: AppColors.seriesGold,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          for (var i = posters.length - 1; i >= 0; i--)
            _poster(
              posters[i],
              right: (22 + i * 38 + i * 14 * t).w,
              top: tabH + 12.h - 22.h * t - (i == 1 ? 4.h : 0),
              angle: baseAngles[i] + (spreadAngles[i] - baseAngles[i]) * t,
            ),
          Positioned(
            left: 0,
            right: 0,
            top: frontTop,
            bottom: 0,
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0018)
                ..rotateX(-0.42 * t),
              child: _front(list, nearest, urgent, t),
            ),
          ),
        ],
      ),
    );
  }

  Widget _poster(SeriesAccessModel s, {required double right, required double top, required double angle}) {
    return Positioned(
      right: right,
      top: top,
      child: Transform.rotate(
        angle: angle,
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 54.w,
          height: 78.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppNetworkImage(s.imagePath, width: 54.w, height: 78.h),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white.withValues(alpha: 0.18), Colors.transparent, Colors.transparent],
                      stops: const [0, 0.35, 1],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _front(List<SeriesAccessModel> list, SeriesAccessModel? nearest, bool urgent, double t) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 12.w, 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_frontTop, _frontBottom],
        ),
        border: Border(
          top: BorderSide(color: AppColors.seriesGold.withValues(alpha: 0.45), width: 1),
          left: BorderSide(color: AppColors.green.withValues(alpha: 0.25)),
          right: BorderSide(color: AppColors.green.withValues(alpha: 0.25)),
          bottom: BorderSide(color: AppColors.green.withValues(alpha: 0.25)),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 16, offset: const Offset(0, -6)),
          BoxShadow(color: AppColors.green.withValues(alpha: 0.12 + 0.1 * t.clamp(0.0, 1.0)), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sotib olingan seriallar'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700, height: 1.3),
                ),
                SizedBox(height: 4.h),
                if (nearest != null)
                  Row(
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: urgent ? AppColors.danger : AppColors.playerAccentText,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          '@kun kun qoldi • @sana gacha'.trParams({'kun': '${nearest.daysLeft}', 'sana': _date(nearest.endDate!)}),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: urgent ? AppColors.danger : _soft, fontSize: 12.sp, height: 16 / 12),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.green.withValues(alpha: 0.18),
              border: Border.all(color: AppColors.green.withValues(alpha: 0.5)),
            ),
            child: Transform.rotate(
              angle: math.pi * _reveal.value,
              child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 22.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(List<SeriesAccessModel> list) {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1410),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.18)),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            for (var i = 0; i < list.length; i++) ...[
              _row(list[i], i),
              if (i != list.length - 1) Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(SeriesAccessModel s, int index) {
    final urgent = s.daysLeft <= 3;
    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: () => openSeriesById(s.seriesId),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            SizedBox(
              width: 22.w,
              child: Text(
                '${index + 1}'.padLeft(2, '0'),
                style: TextStyle(
                  fontFamily: AppFonts.cinzel,
                  color: AppColors.seriesGold.withValues(alpha: 0.8),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: 6.w),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: AppNetworkImage(s.imagePath, width: 38.w, height: 54.h),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w500, height: 1.4)),
                  if (s.endDate != null)
                    Text(
                      '@kun kun qoldi • @sana gacha'.trParams({'kun': '${s.daysLeft}', 'sana': _date(s.endDate!)}),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: urgent ? AppColors.danger : _soft, fontSize: 12.sp, height: 16 / 12),
                    ),
                ],
              ),
            ),
            AppIcon('menu_chevron', size: 14.w),
          ],
        ),
      ),
    );
  }
}

class _FolderBackPainter extends CustomPainter {
  _FolderBackPainter({
    required this.tabHeight,
    required this.tabWidth,
    required this.radius,
    required this.top,
    required this.bottom,
    required this.stroke,
  });

  final double tabHeight;
  final double tabWidth;
  final double radius;
  final Color top;
  final Color bottom;
  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final r = radius;
    final slope = tabHeight * 0.9;
    final path = Path()
      ..moveTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..lineTo(tabWidth - r * 0.5, 0)
      ..quadraticBezierTo(tabWidth, 0, tabWidth + slope * 0.4, tabHeight * 0.4)
      ..lineTo(tabWidth + slope * 0.7, tabHeight * 0.75)
      ..quadraticBezierTo(tabWidth + slope, tabHeight, tabWidth + slope + r * 0.6, tabHeight)
      ..lineTo(size.width - r, tabHeight)
      ..quadraticBezierTo(size.width, tabHeight, size.width, tabHeight + r)
      ..lineTo(size.width, size.height - r)
      ..quadraticBezierTo(size.width, size.height, size.width - r, size.height)
      ..lineTo(r, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - r)
      ..close();

    canvas.drawShadow(path, Colors.black, 10, false);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _FolderBackPainter old) =>
      old.stroke != stroke || old.top != top || old.bottom != bottom || old.tabWidth != tabWidth;
}
