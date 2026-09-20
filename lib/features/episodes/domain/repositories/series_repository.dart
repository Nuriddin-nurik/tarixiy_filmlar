import '../entities/series_detail.dart';

abstract class SeriesRepository {
  Future<SeriesDetail> getSeriesDetail(String seriesId);
}
