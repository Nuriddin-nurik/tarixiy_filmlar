import '../../domain/entities/favorite_item.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;

  const FavoritesRepositoryImpl(this.localDataSource);

  @override
  Future<List<FavoriteItem>> getFavorites() {
    return localDataSource.fetchFavorites();
  }

  @override
  Future<void> removeFavorite(String id) {
    return localDataSource.removeFavorite(id);
  }
}
