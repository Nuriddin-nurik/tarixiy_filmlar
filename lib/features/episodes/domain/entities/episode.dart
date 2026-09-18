enum EpisodeDownloadStatus { downloaded, available, locked }

class Episode {
  final String id;
  final String title;
  final String thumbnailAsset;
  final String duration;
  final String quality;
  final String sizeLabel;
  final EpisodeDownloadStatus downloadStatus;
  final bool isActive;

  const Episode({
    required this.id,
    required this.title,
    required this.thumbnailAsset,
    required this.duration,
    required this.quality,
    required this.sizeLabel,
    required this.downloadStatus,
    this.isActive = false,
  });
}
