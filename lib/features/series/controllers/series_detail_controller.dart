import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../data/models/series_details_model.dart';
import '../../../data/models/series_model.dart';
import '../../../data/models/subscription_models.dart';
import '../../../data/providers/api_provider.dart';
import '../../../core/widgets/app_widgets.dart';
import 'comments_controller.dart';

class SeriesDetailController extends GetxController with WidgetsBindingObserver {
  final ApiProvider _apiProvider = ApiProvider();

  late final SeriesModel series;
  var details = Rxn<SeriesDetailsModel>();
  var isLoading = true.obs;
  var liked = false.obs;
  var likeCount = 0.obs;
  var reminded = false.obs;
  final remindedEpisodes = <int>{}.obs;
  var plans = <SubscriptionPlanModel>[].obs;
  late final CommentsController comments;

  @override
  void onInit() {
    super.onInit();
    series = Get.arguments as SeriesModel;
    comments = Get.put(CommentsController(series.id!), tag: 'comments_${series.id}');
    WidgetsBinding.instance.addObserver(this);
    fetchDetails();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      plans.value = await _apiProvider.getSubscriptionPlans();
    } catch (_) {
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    Get.delete<CommentsController>(tag: 'comments_${series.id}');
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) fetchDetails(silent: true);
  }

  Future<void> fetchDetails({bool silent = false}) async {
    final prev = details.value;
    try {
      if (!silent) isLoading(true);
      final d = await _apiProvider.getSeriesDetails(series.id!);
      details.value = d;
      liked.value = d.liked;
      likeCount.value = d.likeCount;
      reminded.value = d.reminded;
      remindedEpisodes
        ..clear()
        ..addAll(d.parts.where((p) => p.reminded && p.episodeId != null).map((p) => p.episodeId!));
      if (silent && prev != null && !prev.hasAccess && d.hasAccess) {
        appSnack("To'lov qabul qilindi".tr, 'Barcha qismlar ochildi. Yoqimli tomosha!'.tr);
      }
    } catch (_) {
      if (silent) return;
      appSnack('Xato'.tr, "Serial ma'lumotlarini yuklab bo'lmadi".tr);
    } finally {
      isLoading(false);
    }
  }

  Future<void> toggleReminder() async {
    reminded.toggle();
    try {
      reminded.value = await _apiProvider.toggleReminder(series.id!);
      if (reminded.value) {
        appSnack('Eslatma yoqildi'.tr, 'Serial efirga chiqishi bilan sizga xabar beramiz'.tr);
      }
    } catch (_) {
      reminded.toggle();
      appSnack('Xato'.tr, "Eslatmani yoqib bo'lmadi".tr);
    }
  }

  Future<void> toggleEpisodeReminder(EpisodePartModel part) async {
    final id = part.episodeId;
    if (id == null) return;
    final wasOn = remindedEpisodes.contains(id);
    wasOn ? remindedEpisodes.remove(id) : remindedEpisodes.add(id);
    try {
      final on = await _apiProvider.toggleEpisodeReminder(series.id!, id);
      on ? remindedEpisodes.add(id) : remindedEpisodes.remove(id);
      if (on) {
        appSnack('Eslatma yoqildi'.tr, 'Qism chiqishi bilan sizga xabar beramiz'.tr);
      }
    } catch (_) {
      wasOn ? remindedEpisodes.add(id) : remindedEpisodes.remove(id);
      appSnack('Xato'.tr, "Eslatmani yoqib bo'lmadi".tr);
    }
  }

  Future<void> toggleLike() async {
    liked.toggle();
    likeCount.value += liked.value ? 1 : -1;
    try {
      final (l, c) = await _apiProvider.toggleLike(series.id!);
      liked.value = l;
      likeCount.value = c;
    } catch (_) {
      liked.toggle();
      likeCount.value += liked.value ? 1 : -1;
    }
  }

  int? get resumeEpisodeId {
    final parts = [...?details.value?.releasedParts]
      ..sort((a, b) {
        final s = (a.seasonNumber ?? 1).compareTo(b.seasonNumber ?? 1);
        return s != 0 ? s : (a.episodeNumber ?? 0).compareTo(b.episodeNumber ?? 0);
      });
    if (parts.isEmpty) return null;
    final watchable = parts.where((p) => p.hasAccess || p.free).toList();
    if (watchable.isEmpty) return parts.first.episodeId;
    final started = watchable.where((p) => p.watchedSeconds > 0).toList();
    return (started.isNotEmpty ? started.last : watchable.first).episodeId;
  }
}
