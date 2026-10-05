import 'user_model.dart';
import 'series_model.dart';

class HomeResponseModel {
  final UserModel? user;
  final List<BannerModel>? banners;
  final List<SeriesModel>? series;

  HomeResponseModel({this.user, this.banners, this.series});

  factory HomeResponseModel.fromJson(Map<String, dynamic> json) {
    return HomeResponseModel(
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      banners: json['banners'] != null 
          ? (json['banners'] as List).map((i) => BannerModel.fromJson(i)).toList()
          : null,
      series: json['series'] != null
          ? (json['series'] as List).map((i) => SeriesModel.fromJson(i)).toList()
          : null,
    );
  }
}
