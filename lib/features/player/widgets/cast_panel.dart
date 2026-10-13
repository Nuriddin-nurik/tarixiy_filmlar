import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/cast/cast_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../controllers/player_controller.dart';

TextStyle _st(double size, FontWeight w, Color c) =>
    TextStyle(fontFamily: AppFonts.notoSerif, fontSize: size, fontWeight: w, color: c, height: 1.3);

const _muted = Color(0xFF9CA3AF);

String _clock(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = d.inSeconds % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}

void showCastSheet(PlayerController controller) {
  final cast = CastService.to;
  if (!controller.canCast && !cast.connected.value) {
    appSnack('Televizorga uzatish'.tr, "Bu qismni televizorga uzatib bo'lmaydi".tr);
    return;
  }
  cast.startDiscovery();

  Widget deviceTile(IconData icon, String title, {String? subtitle, VoidCallback? onTap, Widget? trailing}) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: AppColors.playerAccentText, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: _st(14, FontWeight.w500, Colors.white)),
                    if (subtitle != null) Text(subtitle, style: _st(11, FontWeight.w400, _muted)),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      );

  final content = Obx(() {
    final connected = cast.connected.value;
    final devices = cast.devices.toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Televizorga uzatish'.tr, textAlign: TextAlign.center, style: _st(15, FontWeight.w700, AppColors.gold)),
          const SizedBox(height: 8),
          if (connected) ...[
            deviceTile(Icons.cast_connected_rounded, cast.deviceName.value,
                subtitle: 'Ulangan'.tr,
                trailing: const Icon(Icons.check_circle, color: AppColors.playerAccentText, size: 20)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.back();
                  controller.stopCasting();
                },
                icon: const Icon(Icons.stop_circle_outlined, size: 18),
                label: Text("Uzatishni to'xtatish".tr),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: _st(13, FontWeight.w600, Colors.white),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ] else if (devices.isEmpty) ...[
            const SizedBox(height: 12),
            const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.playerAccent),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Qurilmalar qidirilmoqda... Telefon va televizor bitta Wi-Fi tarmog'iga ulangan bo'lishi kerak".tr,
                textAlign: TextAlign.center,
                style: _st(12, FontWeight.w400, _muted),
              ),
            ),
            const SizedBox(height: 8),
          ] else
            for (final d in devices)
              deviceTile(
                Icons.tv_rounded,
                d.friendlyName,
                subtitle: d.modelName,
                onTap: () async {
                  Get.back();
                  final ok = await cast.connect(d);
                  if (!ok) appSnack('Xato'.tr, "Qurilmaga ulanib bo'lmadi".tr);
                },
              ),
          const SizedBox(height: 4),
        ],
      ),
    );
  });

  Get.bottomSheet(
    SafeArea(child: content),
    backgroundColor: AppColors.playerCard,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
  );
}

class CastPanel extends StatefulWidget {
  const CastPanel({super.key, required this.controller});

  final PlayerController controller;

  @override
  State<CastPanel> createState() => _CastPanelState();
}

class _CastPanelState extends State<CastPanel> {
  double? _drag;

  PlayerController get c => widget.controller;

  Widget _round(IconData icon, double size, VoidCallback onTap, {Color? color}) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color ?? Colors.black.withValues(alpha: 0.45), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: size * 0.55),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final thumb = c.currentEpisode.value?.thumbnail;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (thumb != null) AppNetworkImage(thumb),
        ColoredBox(color: Colors.black.withValues(alpha: 0.78)),
        Positioned(
          top: 8,
          left: 14,
          right: 14,
          child: Row(
            children: [
              _round(Icons.arrow_back_rounded, 36, Get.back),
              const Spacer(),
              _round(Icons.cast_connected_rounded, 36, () => showCastSheet(c)),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text('Televizorda ijro etilmoqda'.tr, style: _st(12, FontWeight.w500, _muted)),
            const SizedBox(height: 2),
            Obx(() => Text(
                  CastService.to.deviceName.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _st(14, FontWeight.w700, AppColors.playerAccentText),
                )),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _round(Icons.replay_10_rounded, 40, () => c.castSeekBy(-10)),
                const SizedBox(width: 28),
                Obx(() => GestureDetector(
                      onTap: c.castPlayPause,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(color: AppColors.playerGreen, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: c.castBuffering.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Icon(c.castPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white, size: 28),
                      ),
                    )),
                const SizedBox(width: 28),
                _round(Icons.forward_10_rounded, 40, () => c.castSeekBy(10)),
              ],
            ),
          ],
        ),
        Positioned(
          left: 6,
          right: 6,
          bottom: 0,
          child: Obx(() {
            final total = c.castDuration.value.inSeconds.toDouble();
            final pos = c.castPosition.value.inSeconds.toDouble();
            final value = (_drag ?? pos).clamp(0.0, total > 0 ? total : 1.0);
            return Row(
              children: [
                const SizedBox(width: 8),
                Text(_clock(Duration(seconds: value.round())), style: _st(10, FontWeight.w500, const Color(0xFFD1D5DB))),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      activeTrackColor: AppColors.playerAccent,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: value,
                      max: total > 0 ? total : 1.0,
                      onChanged: total > 0 ? (v) => setState(() => _drag = v) : null,
                      onChangeEnd: (v) {
                        setState(() => _drag = null);
                        c.castSeekTo(Duration(seconds: v.round()));
                      },
                    ),
                  ),
                ),
                Text(_clock(c.castDuration.value), style: _st(10, FontWeight.w500, const Color(0xFFD1D5DB))),
                const SizedBox(width: 8),
              ],
            );
          }),
        ),
      ],
    );
  }
}
