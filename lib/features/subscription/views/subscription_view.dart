import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/models/subscription_models.dart';
import '../../../data/providers/api_provider.dart';
import '../widgets/purchase_sheet.dart';

class SubscriptionView extends StatefulWidget {
  const SubscriptionView({super.key});

  @override
  State<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<SubscriptionView> {
  late Future<List<SubscriptionPlanModel>> _plans = ApiProvider().getSubscriptionPlans();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Obuna'.tr)),
      body: FutureBuilder<List<SubscriptionPlanModel>>(
        future: _plans,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: AppColors.green));
          }
          if (snap.hasError) {
            return EmptyState(
              icon: Icons.wifi_off_rounded,
              title: 'Xatolik'.tr,
              message: "Tariflarni yuklab bo'lmadi".tr,
              action: TextButton(
                onPressed: () => setState(() => _plans = ApiProvider().getSubscriptionPlans()),
                child: Text('Qayta urinish'.tr, style: const TextStyle(color: AppColors.greenLight)),
              ),
            );
          }
          final plans = snap.data ?? const [];
          if (plans.isEmpty) {
            return EmptyState(icon: Icons.workspace_premium_outlined, title: "Hozircha tariflar yo'q".tr);
          }
          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 56.sp),
              SizedBox(height: 12.h),
              Text(
                'Premium obuna'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.gold, fontSize: 22.sp, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 6.h),
              Text(
                "Obuna tarifidagi barcha seriallarni cheklovsiz ko'ring".tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
              ),
              SizedBox(height: 24.h),
              ...plans.map(_planCard),
              SizedBox(height: 8.h),
              Text(
                "To'lov Pixy orqali amalga oshiriladi. Narxga 4% komissiya qo'shiladi.".tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _planCard(SubscriptionPlanModel plan) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.green.withValues(alpha: 0.2), AppColors.surface]),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(plan.name, style: TextStyle(color: Colors.white, fontSize: 17.sp, fontWeight: FontWeight.w700)),
          if (plan.description != null) ...[
            SizedBox(height: 4.h),
            Text(plan.description!, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp, height: 1.4)),
          ],
          SizedBox(height: 14.h),
          if (plan.monthlyPrice != null) _priceLine('1 oylik'.tr, plan.monthlyPrice!),
          if (plan.quarterlyPrice != null) _priceLine('3 oylik'.tr, plan.quarterlyPrice!),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: ElevatedButton(
              onPressed: () => showPurchaseSheet(
                planId: plan.id,
                title: plan.name,
                monthlyPrice: plan.monthlyPrice,
                quarterlyPrice: plan.quarterlyPrice,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text("Obuna bo'lish".tr,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceLine(String label, int price) => Padding(
        padding: EdgeInsets.symmetric(vertical: 3.h),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.greenLight, size: 16.sp),
            SizedBox(width: 8.w),
            Expanded(child: Text(label, style: TextStyle(color: Colors.white, fontSize: 13.sp))),
            Text(formatSom(price), style: TextStyle(color: AppColors.gold, fontSize: 14.sp, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
