import '../entities/series_detail.dart';
import '../repositories/series_repository.dart';

class GetSeriesDetail {
  final SeriesRepository repository;

  const GetSeriesDetail(this.repository);

  Future<SeriesDetail> call(String seriesId) {
    return repository.getSeriesDetail(seriesId);
  }
}
