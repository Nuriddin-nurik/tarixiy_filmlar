import '../entities/favorite_item.dart';
import '../repositories/favorites_repository.dart';

class GetFavorites {
  final FavoritesRepository repository;

  const GetFavorites(this.repository);

  Future<List<FavoriteItem>> call() {
    return repository.getFavorites();
  }
}
