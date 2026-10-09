import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_widgets.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/providers/api_provider.dart';

class CommentsController extends GetxController {
  CommentsController(this.seriesId, {int initialTotal = 0}) : total = initialTotal.obs;

  final int seriesId;
  final ApiProvider _api = ApiProvider();

  final items = <CommentModel>[].obs;
  final RxInt total;
  final isLoading = false.obs;
  final isSending = false.obs;
  final hasMore = true.obs;
  int _page = 0;

  @override
  void onInit() {
    super.onInit();
    refreshComments();
  }

  Future<void> refreshComments() async {
    _page = 0;
    hasMore.value = true;
    await _load(reset: true);
  }

  Future<void> loadMore() async {
    if (isLoading.value || !hasMore.value) return;
    await _load(reset: false);
  }

  Future<void> _load({required bool reset}) async {
    isLoading.value = true;
    try {
      final page = await _api.getComments(seriesId, page: _page);
      if (reset) {
        items.assignAll(page.items);
      } else {
        items.addAll(page.items.where((c) => items.every((e) => e.id != c.id)));
      }
      hasMore.value = page.hasMore;
      total.value = page.total;
      _page++;
    } catch (_) {
      if (reset) appSnack('Xato'.tr, "Izohlarni yuklab bo'lmadi".tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> send(String text) async {
    final value = text.trim();
    if (value.isEmpty || isSending.value) return false;
    isSending.value = true;
    try {
      final comment = await _api.addComment(seriesId, value);
      items.insert(0, comment);
      total.value++;
      return true;
    } on DioException catch (e) {
      appSnack('Xato'.tr, _message(e) ?? "Izohni yuborib bo'lmadi".tr);
      return false;
    } catch (_) {
      appSnack('Xato'.tr, "Izohni yuborib bo'lmadi".tr);
      return false;
    } finally {
      isSending.value = false;
    }
  }

  Future<void> delete(CommentModel comment) async {
    final index = items.indexWhere((c) => c.id == comment.id);
    if (index < 0) return;
    items.removeAt(index);
    total.value = (total.value - 1).clamp(0, 1 << 30);
    try {
      await _api.deleteComment(comment.id);
    } catch (_) {
      items.insert(index, comment);
      total.value++;
      appSnack('Xato'.tr, "Izohni o'chirib bo'lmadi".tr);
    }
  }

  Future<void> report(CommentModel comment) async {
    try {
      await _api.reportComment(comment.id);
      appSnack('Rahmat'.tr, "Shikoyatingiz qabul qilindi, admin ko'rib chiqadi".tr);
    } catch (_) {
      appSnack('Xato'.tr, "Shikoyatni yuborib bo'lmadi".tr);
    }
  }

  static String? _message(DioException e) {
    final data = e.response?.data;
    if (data is! Map) return null;
    switch (data['code']) {
      case 13002:
        return "Izoh bo'sh yoki juda uzun (1000 belgigacha)".tr;
      case 13003:
        return "Juda tez yozyapsiz, birozdan so'ng qayta urinib ko'ring".tr;
    }
    return data['message'] is String ? data['message'] as String : null;
  }
}
