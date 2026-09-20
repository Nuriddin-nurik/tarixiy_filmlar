import '../../domain/entities/favorite_item.dart';

/// Stand-in for a future remote/local data source. Holds an in-memory
/// fixture until a real API and persistence layer are wired up.
class FavoritesLocalDataSource {
  final List<FavoriteItem> _items = [
    const FavoriteItem(
      id: 'usmonli',
      title: 'Usmonli: Buyuk Saltanat',
      subtitle: '6-fasl • 32-qism',
      imageAsset: '',
    ),
    const FavoriteItem(
      id: 'mehmed-fotih',
      title: 'Mehmed Fotih',
      subtitle: 'HD 1080p',
      imageAsset: '',
    ),
    const FavoriteItem(
      id: 'salohiddin-ayyubiy',
      title: 'Salohiddin Ayyubiy',
      subtitle: '1-mavsum',
      imageAsset: '',
    ),
    const FavoriteItem(
      id: 'kok-sulton',
      title: "Ko'k Sulton",
      subtitle: '1-mavsum',
      imageAsset: '',
    ),
  ];

  Future<List<FavoriteItem>> fetchFavorites() async {
    return List.unmodifiable(_items);
  }

  Future<void> removeFavorite(String id) async {
    _items.removeWhere((item) => item.id == id);
  }
}
