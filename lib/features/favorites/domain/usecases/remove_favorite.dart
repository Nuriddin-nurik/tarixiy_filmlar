import '../repositories/favorites_repository.dart';

class RemoveFavorite {
  final FavoritesRepository repository;

  const RemoveFavorite(this.repository);

  Future<void> call(String id) {
    return repository.removeFavorite(id);
  }
}
