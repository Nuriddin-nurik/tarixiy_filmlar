class ContinueWatchingModel {
  final int? seriesId;
  final String? seriesTitle;
  final String? seriesImagePath;
  final int? episodeId;
  final int? episodeNumber;
  final String? episodeTitle;
  final String? episodeThumbnail;
  final int positionSeconds;
  final int durationSeconds;

  ContinueWatchingModel({
    this.seriesId,
    this.seriesTitle,
    this.seriesImagePath,
    this.episodeId,
    this.episodeNumber,
    this.episodeTitle,
    this.episodeThumbnail,
    this.positionSeconds = 0,
    this.durationSeconds = 0,
  });

  factory ContinueWatchingModel.fromJson(Map<String, dynamic> json) {
    return ContinueWatchingModel(
      seriesId: json['seriesId'],
      seriesTitle: (json['seriesTitle'] as String?)?.trim(),
      seriesImagePath: json['seriesImagePath'],
      episodeId: json['episodeId'],
      episodeNumber: json['episodeNumber'],
      episodeTitle: json['episodeTitle'],
      episodeThumbnail: json['episodeThumbnail'],
      positionSeconds: json['positionSeconds'] ?? 0,
      durationSeconds: json['durationSeconds'] ?? 0,
    );
  }

  double get progress =>
      durationSeconds > 0 ? (positionSeconds / durationSeconds).clamp(0.0, 1.0) : 0;
}
