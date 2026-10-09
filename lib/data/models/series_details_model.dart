class EpisodePartModel {
  final int? episodeId;
  final int? episodeNumber;
  final String? title;
  final String? thumbnail;
  final bool free;
  final bool hasAccess;
  final int? seasonNumber;
  final int watchedSeconds;
  final int durationSeconds;

  EpisodePartModel({
    this.episodeId,
    this.episodeNumber,
    this.title,
    this.thumbnail,
    this.free = false,
    this.hasAccess = false,
    this.seasonNumber,
    this.watchedSeconds = 0,
    this.durationSeconds = 0,
  });

  factory EpisodePartModel.fromJson(Map<String, dynamic> json) {
    return EpisodePartModel(
      episodeId: json['episodeId'],
      episodeNumber: json['episodeNumber'],
      title: (json['title'] as String?)?.replaceAll(RegExp(r'\s+'), ' ').trim(),
      thumbnail: json['thumbnail'],
      free: json['free'] ?? false,
      hasAccess: json['hasAccess'] ?? false,
      seasonNumber: json['seasonNumber'],
      watchedSeconds: json['watchedSeconds'] ?? 0,
      durationSeconds: json['durationSeconds'] ?? 0,
    );
  }
}

class SeriesDetailsModel {
  final int? id;
  final String? title;
  final List<EpisodePartModel> parts;
  final bool hasAccess;
  final int likeCount;
  final bool liked;
  final bool reminded;
  final int viewCount;
  final String? telegramFreeUrl;
  final int? telegramFreeCount;
  final int commentCount;

  SeriesDetailsModel({
    this.id,
    this.title,
    this.parts = const [],
    this.hasAccess = false,
    this.likeCount = 0,
    this.liked = false,
    this.reminded = false,
    this.viewCount = 0,
    this.telegramFreeUrl,
    this.telegramFreeCount,
    this.commentCount = 0,
  });

  factory SeriesDetailsModel.fromJson(Map<String, dynamic> json) {
    return SeriesDetailsModel(
      id: json['id'],
      title: (json['title'] as String?)?.trim(),
      parts: json['parts'] != null
          ? (json['parts'] as List).map((p) => EpisodePartModel.fromJson(p)).toList()
          : const [],
      hasAccess: json['hasAccess'] ?? false,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      liked: json['liked'] ?? false,
      reminded: json['reminded'] ?? false,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      telegramFreeUrl: json['telegramFreeUrl'],
      telegramFreeCount: (json['telegramFreeCount'] as num?)?.toInt(),
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
    );
  }

  int get seasonCount => parts.map((p) => p.seasonNumber ?? 1).toSet().length;
}
