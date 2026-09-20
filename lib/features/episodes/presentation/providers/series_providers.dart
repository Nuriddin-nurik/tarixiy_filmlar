import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/series_local_data_source.dart';
import '../../data/repositories/series_repository_impl.dart';
import '../../domain/entities/series_detail.dart';
import '../../domain/repositories/series_repository.dart';
import '../../domain/usecases/get_series_detail.dart';

enum EpisodeTab { all, watched, downloaded }

const currentSeriesId = 'usmonli-buyuk-saltanat';

final seriesLocalDataSourceProvider = Provider<SeriesLocalDataSource>((ref) {
  return SeriesLocalDataSource();
});

final seriesRepositoryProvider = Provider<SeriesRepository>((ref) {
  return SeriesRepositoryImpl(ref.watch(seriesLocalDataSourceProvider));
});

final getSeriesDetailProvider = Provider<GetSeriesDetail>((ref) {
  return GetSeriesDetail(ref.watch(seriesRepositoryProvider));
});

final seriesDetailProvider = FutureProvider<SeriesDetail>((ref) {
  return ref.watch(getSeriesDetailProvider).call(currentSeriesId);
});

final selectedEpisodeTabProvider = StateProvider<EpisodeTab>((ref) {
  return EpisodeTab.all;
});
