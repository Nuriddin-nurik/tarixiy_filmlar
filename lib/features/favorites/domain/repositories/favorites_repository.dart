import '../entities/favorite_item.dart';

abstract class FavoritesRepository {
  Future<List<FavoriteItem>> getFavorites();

  Future<void> removeFavorite(String id);
}
