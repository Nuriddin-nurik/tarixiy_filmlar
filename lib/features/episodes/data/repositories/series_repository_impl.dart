import '../../domain/entities/series_detail.dart';
import '../../domain/repositories/series_repository.dart';
import '../datasources/series_local_data_source.dart';

class SeriesRepositoryImpl implements SeriesRepository {
  final SeriesLocalDataSource localDataSource;

  const SeriesRepositoryImpl(this.localDataSource);

  @override
  Future<SeriesDetail> getSeriesDetail(String seriesId) {
    return localDataSource.fetchSeriesDetail(seriesId);
  }
}
