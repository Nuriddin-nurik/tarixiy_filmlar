import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../controllers/profile_controller.dart';

class LinkedAccountsCard extends StatefulWidget {
  const LinkedAccountsCard({super.key, required this.initial});

  final String initial;

  @override
  State<LinkedAccountsCard> createState() => _LinkedAccountsCardState();
}

class _LinkedAccountsCardState extends State<LinkedAccountsCard> with SingleTickerProviderStateMixin {
  static const _google = Color(0xFF4285F4);
  static const _telegram = Color(0xFF2AABEE);
  static const _soft = Color(0xFFC5C6C7);

  late final AnimationController _flow = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
    ..repeat();

  ProfileController get c => Get.find<ProfileController>();

  @override
  void dispose() {
    _flow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = c.user;
      final isTelegram = user?.isTelegramAccount ?? false;
      final googleValue = isTelegram ? null : user?.email;
      final hasTelegram = user?.telegramChatId != null;
      final telegramValue = hasTelegram
          ? (user?.telegramUsername != null ? '@${user!.telegramUsername}' : 'ID: ${user?.telegramChatId}')
          : null;
      final googleLinked = googleValue != null;
      final linkedCount = (googleLinked ? 1 : 0) + (hasTelegram ? 1 : 0);
      final googleLoading = c.isLinkingGoogle.value;
      final telegramLoading = c.isLinkingTelegram.value;

      return Container(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF101A2A), Color(0xFF0C1013), Color(0xFF0B1A1F)],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Bog'langan akkauntlar".tr.toUpperCase(),
                    style: TextStyle(
                      color: _soft,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                _progress(linkedCount),
              ],
            ),
            SizedBox(height: 18.h),
            SizedBox(
              height: 64.w,
              child: AnimatedBuilder(
                animation: _flow,
                builder: (context, _) => Row(
                  children: [
                    _orb('google', _google, googleLinked, googleLoading),
                    Expanded(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _LinkPainter(
                          color: _google,
                          linked: googleLinked,
                          loading: googleLoading,
                          phase: _flow.value,
                          reverse: false,
                        ),
                      ),
                    ),
                    _core(linkedCount),
                    Expanded(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _LinkPainter(
                          color: _telegram,
                          linked: hasTelegram,
                          loading: telegramLoading,
                          phase: _flow.value,
                          reverse: true,
                        ),
                      ),
                    ),
                    _orb('telegram', _telegram, hasTelegram, telegramLoading),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _label(
                    title: 'Google',
                    value: googleValue,
                    color: _google,
                    loading: googleLoading,
                    onLink: c.linkGoogle,
                    align: CrossAxisAlignment.start,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _label(
                    title: 'Telegram',
                    value: telegramValue,
                    color: _telegram,
                    loading: telegramLoading,
                    onLink: c.linkTelegram,
                    onCancel: c.cancelTelegramLink,
                    align: CrossAxisAlignment.end,
                  ),
                ),
              ],
            ),
            if (hasTelegram) ...[
              SizedBox(height: 14.h),
              _syncButton(),
            ],
            if (linkedCount < 2) ...[
              SizedBox(height: 12.h),
              Text(
                "Ikkalasini ulasangiz, Google yoki Telegram bilan kirganda ham bitta hisobga tushasiz va botdagi obunalaringiz shu yerda ochiladi.".tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp, height: 1.4),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _progress(int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 2; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(left: 4.w),
            width: i < count ? 16.w : 8.w,
            height: 4.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.r),
              color: i < count ? AppColors.playerAccentText : Colors.white.withValues(alpha: 0.15),
            ),
          ),
        SizedBox(width: 8.w),
        Text(
          '$count/2',
          style: TextStyle(
            color: count == 2 ? AppColors.playerAccentText : _soft,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _orb(String icon, Color color, bool linked, bool loading) {
    final pulse = loading ? (0.5 + 0.5 * math.sin(_flow.value * math.pi * 8)) : 0.0;
    return SizedBox(
      width: 56.w,
      height: 56.w,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: linked ? color.withValues(alpha: 0.14) : Colors.white.withValues(alpha: 0.04),
              border: Border.all(
                color: linked
                    ? color.withValues(alpha: 0.8)
                    : loading
                        ? color.withValues(alpha: 0.3 + 0.5 * pulse)
                        : Colors.white.withValues(alpha: 0.12),
                width: linked ? 1.5 : 1,
              ),
              boxShadow: [
                if (linked || loading)
                  BoxShadow(
                    color: color.withValues(alpha: linked ? 0.35 : 0.2 * pulse),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
              ],
            ),
            alignment: Alignment.center,
            child: Opacity(
              opacity: linked || loading ? 1 : 0.45,
              child: AppIcon(icon, size: 24.w),
            ),
          ),
          if (linked)
            Positioned(
              right: -1.w,
              bottom: -1.w,
              child: Container(
                width: 18.w,
                height: 18.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.playerAccent,
                  border: Border.all(color: const Color(0xFF0C1013), width: 2),
                ),
                child: Icon(Icons.check_rounded, size: 11.sp, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _core(int count) {
    final full = count == 2;
    return Container(
      width: 46.w,
      height: 46.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: full
              ? [AppColors.green.withValues(alpha: 0.55), AppColors.green.withValues(alpha: 0.12)]
              : [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.02)],
        ),
        border: Border.all(
          color: full ? AppColors.playerAccentText : Colors.white.withValues(alpha: 0.18),
          width: 1.5,
        ),
        boxShadow: [
          if (full) BoxShadow(color: AppColors.green.withValues(alpha: 0.45), blurRadius: 22),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        widget.initial,
        style: TextStyle(
          fontFamily: AppFonts.cinzel,
          color: full ? Colors.white : _soft,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _label({
    required String title,
    required String? value,
    required Color color,
    required bool loading,
    required VoidCallback onLink,
    VoidCallback? onCancel,
    required CrossAxisAlignment align,
  }) {
    final linked = value != null;
    final textAlign = align == CrossAxisAlignment.end ? TextAlign.right : TextAlign.left;
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(title,
            style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w700, height: 1.3)),
        SizedBox(height: 4.h),
        if (linked)
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: textAlign,
            style: TextStyle(color: _soft, fontSize: 12.sp, height: 1.3),
          )
        else if (loading)
          _chip(
            color: color,
            onTap: onCancel,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12.w,
                  height: 12.w,
                  child: CircularProgressIndicator(strokeWidth: 1.6, color: color),
                ),
                if (onCancel != null) ...[
                  SizedBox(width: 6.w),
                  Text('Bekor qilish'.tr, style: TextStyle(color: _soft, fontSize: 12.sp)),
                ],
              ],
            ),
          )
        else
          _chip(
            color: color,
            filled: true,
            onTap: onLink,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_link_rounded, size: 15.sp, color: Colors.white),
                SizedBox(width: 5.w),
                Text('Ulash'.tr,
                    style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _chip({required Color color, required Widget child, VoidCallback? onTap, bool filled = false}) {
    return Material(
      color: filled ? color.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.05),
      shape: StadiumBorder(side: BorderSide(color: color.withValues(alpha: filled ? 0.7 : 0.3))),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          child: child,
        ),
      ),
    );
  }

  Widget _syncButton() {
    final syncing = c.isSyncingBot.value;
    return Material(
      color: Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(12.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: syncing ? null : () => c.syncBotSubscriptions(manual: true),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              syncing
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(strokeWidth: 2, color: _telegram),
                    )
                  : Icon(Icons.sync_rounded, color: _telegram, size: 18.sp),
              SizedBox(width: 8.w),
              Text('Botdagi obunalarni yangilash'.tr, style: TextStyle(color: Colors.white, fontSize: 13.sp)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkPainter extends CustomPainter {
  _LinkPainter({
    required this.color,
    required this.linked,
    required this.loading,
    required this.phase,
    required this.reverse,
  });

  final Color color;
  final bool linked;
  final bool loading;
  final double phase;
  final bool reverse;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final start = Offset(0, y);
    final end = Offset(size.width, y);

    if (linked) {
      final rect = Rect.fromPoints(start, end).inflate(2);
      final gradient = LinearGradient(
        colors: reverse ? [AppColors.green, color] : [color, AppColors.green],
      ).createShader(rect);
      canvas.drawLine(
        start,
        end,
        Paint()
          ..shader = gradient
          ..strokeWidth = 6
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
          ..color = color.withValues(alpha: 0.4),
      );
      canvas.drawLine(
        start,
        end,
        Paint()
          ..shader = gradient
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
      for (var k = 0; k < 2; k++) {
        var p = (phase + k * 0.5) % 1.0;
        if (reverse) p = 1 - p;
        final x = size.width * p;
        final fade = math.sin(p * math.pi);
        canvas.drawCircle(
          Offset(x, y),
          4,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.35 * fade)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
        canvas.drawCircle(Offset(x, y), 1.8, Paint()..color = Colors.white.withValues(alpha: 0.9 * fade));
      }
      return;
    }

    const dash = 5.0;
    const gap = 5.0;
    final paint = Paint()
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = loading ? color.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.16);
    final cycle = phase * 6 % 1.0;
    final shift = loading ? (reverse ? 1 - cycle : cycle) * (dash + gap) : 0.0;
    var x = -(dash + gap) + shift;
    while (x < size.width) {
      final a = x.clamp(0.0, size.width);
      final b = (x + dash).clamp(0.0, size.width);
      if (b > a) canvas.drawLine(Offset(a, y), Offset(b, y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _LinkPainter old) =>
      old.phase != phase || old.linked != linked || old.loading != loading || old.color != color;
}
