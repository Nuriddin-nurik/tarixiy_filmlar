import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/episode.dart';
import '../../domain/entities/series_detail.dart';
import '../providers/series_providers.dart';
import '../widgets/episode_card.dart';
import '../widgets/episode_section_tabs.dart';
import '../widgets/series_metadata_section.dart';
import '../widgets/video_player_header.dart';

class EpisodeListPage extends ConsumerWidget {
  const EpisodeListPage({super.key});

  List<Episode> _filterEpisodes(List<Episode> episodes, EpisodeTab tab) {
    switch (tab) {
      case EpisodeTab.all:
        return episodes;
      case EpisodeTab.watched:
        return episodes.where((e) => e.isActive).toList();
      case EpisodeTab.downloaded:
        return episodes
            .where((e) => e.downloadStatus == EpisodeDownloadStatus.downloaded)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesAsync = ref.watch(seriesDetailProvider);
    final selectedTab = ref.watch(selectedEpisodeTabProvider);

    return seriesAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (error, stackTrace) => Center(
        child: Text(
          "Ma'lumotni yuklashda xatolik yuz berdi",
          style: AppTextStyles.subtitle,
        ),
      ),
      data: (series) => _EpisodeListContent(
        series: series,
        episodes: _filterEpisodes(series.episodes, selectedTab),
      ),
    );
  }
}

class _EpisodeListContent extends StatelessWidget {
  final SeriesDetail series;
  final List<Episode> episodes;

  const _EpisodeListContent({required this.series, required this.episodes});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          VideoPlayerHeader(series: series, onBack: () => Navigator.maybePop(context)),
          SeriesMetadataSection(series: series),
          const SizedBox(height: 4),
          EpisodeSectionTabs(totalCount: series.episodes.length),
          Expanded(
            child: episodes.isEmpty
                ? Center(
                    child: Text("Hozircha bo'sh", style: AppTextStyles.subtitle),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: episodes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        EpisodeCard(episode: episodes[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
