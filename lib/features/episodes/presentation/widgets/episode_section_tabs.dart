import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/series_providers.dart';

class EpisodeSectionTabs extends ConsumerWidget {
  final int totalCount;

  const EpisodeSectionTabs({super.key, required this.totalCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedEpisodeTabProvider);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _Tab(
            label: 'Barcha qism',
            badge: totalCount.toString(),
            isActive: selected == EpisodeTab.all,
            onTap: () => ref.read(selectedEpisodeTabProvider.notifier).state =
                EpisodeTab.all,
          ),
          Expanded(
            child: _Tab(
              label: "Ko'rilganlar",
              isActive: selected == EpisodeTab.watched,
              align: Alignment.center,
              onTap: () =>
                  ref.read(selectedEpisodeTabProvider.notifier).state =
                      EpisodeTab.watched,
            ),
          ),
          _Tab(
            label: 'Yuklanganlar',
            isActive: selected == EpisodeTab.downloaded,
            align: Alignment.centerRight,
            onTap: () => ref.read(selectedEpisodeTabProvider.notifier).state =
                EpisodeTab.downloaded,
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final String? badge;
  final bool isActive;
  final Alignment align;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badge,
    this.align = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.only(bottom: badge != null ? 10 : 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: isActive ? AppTextStyles.tabActive : AppTextStyles.tabInactive,
          ),
          if (badge != null) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.primarySofter,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(badge!, style: AppTextStyles.tabBadge),
            ),
          ],
        ],
      ),
    );

    final decorated = isActive
        ? Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            child: content,
          )
        : content;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Align(alignment: align, child: decorated),
    );
  }
}
