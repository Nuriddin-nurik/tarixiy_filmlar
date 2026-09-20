import '../../domain/entities/episode.dart';
import '../../domain/entities/series_detail.dart';

/// Stand-in for a future remote/local data source. Serves the fixture that
/// mirrors the Figma design until a real API is wired up.
class SeriesLocalDataSource {
  Future<SeriesDetail> fetchSeriesDetail(String seriesId) async {
    return SeriesDetail(
      id: seriesId,
      coverAsset: 'assets/images/episodes/video_still.png',
      seasonLabel: "6-FASL • 1-QISM",
      audioType: 'Dublyaj',
      title: 'Usmonli: Buyuk Saltanat',
      currentEpisodeTitle: "1. Mehmed: Fathlar Sultoni 83-Bo'lim",
      currentPosition: const Duration(minutes: 32, seconds: 15),
      totalDuration: const Duration(hours: 1, minutes: 24, seconds: 10),
      videoQualityLabel: '1080P FHD',
      likeCount: 24500,
      viewCount: 148000,
      episodes: const [
        Episode(
          id: 'ep-1',
          title: '1. Mehmed: Fathlar Sultoni',
          thumbnailAsset: 'assets/images/episodes/thumbnail_1.png',
          duration: '45:12',
          quality: '1080P FHD',
          sizeLabel: '640 MB',
          downloadStatus: EpisodeDownloadStatus.downloaded,
          isActive: true,
        ),
        Episode(
          id: 'ep-2',
          title: '2. Yangi dushmanlar',
          thumbnailAsset: 'assets/images/episodes/thumbnail_2.png',
          duration: '46:03',
          quality: '1080P FHD',
          sizeLabel: '655 MB',
          downloadStatus: EpisodeDownloadStatus.available,
        ),
        Episode(
          id: 'ep-3',
          title: "3. Qal'a fathi",
          thumbnailAsset: 'assets/images/episodes/thumbnail_3.png',
          duration: '44:58',
          quality: '1080P FHD',
          sizeLabel: '610 MB',
          downloadStatus: EpisodeDownloadStatus.locked,
        ),
      ],
    );
  }
}
