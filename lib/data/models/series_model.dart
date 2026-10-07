class GenreModel {
  final int? id;
  final String? name;

  GenreModel({this.id, this.name});

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(id: json['id'], name: json['name']);
  }
}

class SeriesModel {
  final int? id;
  final String? title;
  final String? status;
  final String? imagePath;
  final bool? hasAccess;
  final bool? hasEpisode;
  final int? viewCount;
  final List<GenreModel> genres;
  final String? telegramFreeUrl;
  final int? telegramFreeCount;
  final int? monthlyPrice;
  final int? quarterlyPrice;
  final bool? subscriptionBased;

  SeriesModel({
    this.id,
    this.title,
    this.status,
    this.imagePath,
    this.hasAccess,
    this.hasEpisode,
    this.viewCount,
    this.genres = const [],
    this.telegramFreeUrl,
    this.telegramFreeCount,
    this.monthlyPrice,
    this.quarterlyPrice,
    this.subscriptionBased,
  });

  factory SeriesModel.fromJson(Map<String, dynamic> json) {
    return SeriesModel(
      id: json['id'],
      title: (json['title'] as String?)?.trim(),
      status: json['status'],
      imagePath: json['imagePath'],
      hasAccess: json['hasAccess'],
      hasEpisode: json['hasEpisode'],
      viewCount: json['viewCount'],
      genres: json['genres'] != null
          ? (json['genres'] as List).map((g) => GenreModel.fromJson(g)).toList()
          : const [],
      telegramFreeUrl: json['telegramFreeUrl'],
      telegramFreeCount: json['telegramFreeCount'],
      monthlyPrice: json['monthlyPrice'],
      quarterlyPrice: json['quarterlyPrice'],
      subscriptionBased: json['subscriptionBased'],
    );
  }

  List<String> get genreNames {
    final names = <String>{};
    for (final g in genres) {
      for (final part in (g.name ?? '').split(',')) {
        final n = part.trim();
        if (n.isNotEmpty) names.add(n);
      }
    }
    return names.toList();
  }
}

class BannerModel {
  final String? image;
  final SeriesModel? movie;
  final int? id;
  final int? seriesId;
  final String? seriesTitle;

  BannerModel({this.image, this.movie, this.id, this.seriesId, this.seriesTitle});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      image: json['image'],
      movie: json['movie'] != null ? SeriesModel.fromJson(json['movie']) : null,
      id: json['id'],
      seriesId: json['seriesId'],
      seriesTitle: json['seriesTitle'],
    );
  }
}
