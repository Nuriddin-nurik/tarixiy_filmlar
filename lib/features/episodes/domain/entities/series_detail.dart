import 'episode.dart';

class SeriesDetail {
  final String id;
  final String coverAsset;
  final String seasonLabel;
  final String audioType;
  final String title;
  final String currentEpisodeTitle;
  final Duration currentPosition;
  final Duration totalDuration;
  final String videoQualityLabel;
  final int likeCount;
  final int viewCount;
  final List<Episode> episodes;

  const SeriesDetail({
    required this.id,
    required this.coverAsset,
    required this.seasonLabel,
    required this.audioType,
    required this.title,
    required this.currentEpisodeTitle,
    required this.currentPosition,
    required this.totalDuration,
    required this.videoQualityLabel,
    required this.likeCount,
    required this.viewCount,
    required this.episodes,
  });

  double get progress =>
      totalDuration.inSeconds == 0
          ? 0
          : currentPosition.inSeconds / totalDuration.inSeconds;
}
