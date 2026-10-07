import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/models/subscription_models.dart';
import '../../../data/providers/api_provider.dart';

Future<void> showPurchaseSheet({
  int? planId,
  int? seriesId,
  required String title,
  int? monthlyPrice,
  int? quarterlyPrice,
}) {
  return Get.bottomSheet(
    _PurchaseSheet(
      planId: planId,
      seriesId: seriesId,
      title: title,
      monthlyPrice: monthlyPrice,
      quarterlyPrice: quarterlyPrice,
    ),
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
  );
}

class _PurchaseSheet extends StatefulWidget {
  const _PurchaseSheet({this.planId, this.seriesId, required this.title, this.monthlyPrice, this.quarterlyPrice});

  final int? planId;
  final int? seriesId;
  final String title;
  final int? monthlyPrice;
  final int? quarterlyPrice;

  @override
  State<_PurchaseSheet> createState() => _PurchaseSheetState();
}

class _PurchaseSheetState extends State<_PurchaseSheet> {
  final _api = ApiProvider();
  late int months = widget.quarterlyPrice != null ? 3 : 1;
  PaymentOrderModel? order;
  bool loading = false;

  int? get price => months == 3 ? widget.quarterlyPrice : widget.monthlyPrice;

  Future<void> _createOrder() async {
    setState(() => loading = true);
    try {
      final o = await _api.createPaymentOrder(planId: widget.planId, seriesId: widget.seriesId, months: months);
      setState(() => order = o);
    } on DioException catch (e) {
      final msg = e.response?.data is Map ? (e.response!.data['message'] ?? '') : '';
      appSnack('Xato'.tr, msg.toString().isNotEmpty ? msg.toString() : "To'lovni yaratib bo'lmadi".tr);
    } catch (_) {
      appSnack('Xato'.tr, "To'lovni yaratib bo'lmadi".tr);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _pay() async {
    final url = order?.payUrl;
    if (url == null) return;
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok) {
      appSnack('Xato'.tr, "To'lov sahifasini ochib bo'lmadi".tr);
      return;
    }
    Get.back();
    appSnack(
      "To'lov".tr,
      "To'lovdan so'ng ilovaga qayting va sahifani yangilang".tr,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2.r)),
              ),
            ),
            SizedBox(height: 16.h),
            Text(widget.title,
                style: TextStyle(color: AppColors.gold, fontSize: 18.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 16.h),
            if (order == null) ...[
              Text('Muddatni tanlang'.tr, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
              SizedBox(height: 8.h),
              if (widget.monthlyPrice != null) _option(1, widget.monthlyPrice!),
              if (widget.quarterlyPrice != null) _option(3, widget.quarterlyPrice!),
              SizedBox(height: 16.h),
              _primaryButton(
                label: 'Davom etish'.tr,
                onTap: price == null || loading ? null : _createOrder,
              ),
            ] else ...[
              _row('Narx'.tr, formatSom(order!.baseAmountInSom)),
              _row('Komissiya (4%)'.tr, formatSom(order!.commissionInSom)),
              Divider(color: AppColors.border, height: 24.h),
              _row('Jami'.tr, formatSom(order!.amountInSom), bold: true),
              SizedBox(height: 20.h),
              _primaryButton(label: "To'lash".tr, onTap: _pay),
            ],
          ],
        ),
      ),
    );
  }

  Widget _option(int m, int p) {
    final selected = months == m;
    return GestureDetector(
      onTap: () => setState(() => months = m),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: selected ? AppColors.green.withValues(alpha: 0.12) : AppColors.surfaceLight,
          border: Border.all(color: selected ? AppColors.green : AppColors.border),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.greenLight : AppColors.textMuted, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(m == 3 ? '3 oylik'.tr : '1 oylik'.tr,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600)),
            ),
            Text(formatSom(p), style: TextStyle(color: AppColors.gold, fontSize: 15.sp, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Expanded(child: Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp))),
            Text(value,
                style: TextStyle(
                  color: bold ? AppColors.gold : Colors.white,
                  fontSize: bold ? 17.sp : 13.sp,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                )),
          ],
        ),
      );

  Widget _primaryButton({required String label, VoidCallback? onTap}) => SizedBox(
        height: 50.h,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            disabledBackgroundColor: AppColors.surfaceLight,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
          child: loading
              ? SizedBox(
                  width: 22.w, height: 22.w, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(label, style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600)),
        ),
      );
}
