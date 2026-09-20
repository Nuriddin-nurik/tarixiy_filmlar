import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/favorites_local_data_source.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../domain/entities/favorite_item.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/remove_favorite.dart';

final favoritesLocalDataSourceProvider = Provider<FavoritesLocalDataSource>((
  ref,
) {
  return FavoritesLocalDataSource();
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepositoryImpl(ref.watch(favoritesLocalDataSourceProvider));
});

final getFavoritesProvider = Provider<GetFavorites>((ref) {
  return GetFavorites(ref.watch(favoritesRepositoryProvider));
});

final removeFavoriteProvider = Provider<RemoveFavorite>((ref) {
  return RemoveFavorite(ref.watch(favoritesRepositoryProvider));
});

class FavoritesController extends AsyncNotifier<List<FavoriteItem>> {
  @override
  Future<List<FavoriteItem>> build() {
    return ref.watch(getFavoritesProvider).call();
  }

  Future<void> remove(String id) async {
    final current = state.valueOrNull ?? const [];
    state = AsyncData(current.where((item) => item.id != id).toList());
    await ref.read(removeFavoriteProvider).call(id);
  }
}

final favoritesControllerProvider =
    AsyncNotifierProvider<FavoritesController, List<FavoriteItem>>(
      FavoritesController.new,
    );
