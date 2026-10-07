class EpisodeModel {
  final int? id;
  final int? seriesId;
  final String? title;
  final int? episodeNumber;
  final String? thumbnail;
  final String? videoUrl;
  final int? durationSeconds;
  final double? fileSizeMb;
  final bool? hasAccess;
  final bool? free;
  final int? seasonNumber;
  final int? watchedSeconds;

  EpisodeModel({
    this.id,
    this.seriesId,
    this.title,
    this.episodeNumber,
    this.thumbnail,
    this.videoUrl,
    this.durationSeconds,
    this.fileSizeMb,
    this.hasAccess,
    this.free,
    this.seasonNumber,
    this.watchedSeconds,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    final h = (json['durationHours'] as num?)?.toInt() ?? 0;
    final m = (json['durationMinutes'] as num?)?.toInt() ?? 0;
    final s = (json['durationSeconds'] as num?)?.toInt() ?? 0;
    return EpisodeModel(
      id: json['id'],
      seriesId: json['seriesId'],
      title: (json['title'] as String?)?.replaceAll(RegExp(r'\s+'), ' ').trim(),
      episodeNumber: json['episodeNumber'],
      thumbnail: json['thumbnail'],
      videoUrl: json['videoUrl'],
      durationSeconds: h * 3600 + m * 60 + s,
      fileSizeMb: (json['fileSizeMb'] as num?)?.toDouble(),
      hasAccess: json['hasAccess'],
      free: json['free'],
      seasonNumber: json['seasonNumber'],
      watchedSeconds: json['watchedSeconds'],
    );
  }

  bool get canWatch => (hasAccess ?? false) || (free ?? false);
}
