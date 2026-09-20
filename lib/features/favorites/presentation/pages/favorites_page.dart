import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/app_nav_tab.dart';
import '../../../../core/navigation/app_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/favorites_providers.dart';
import '../widgets/favorite_card.dart';
import '../widgets/favorites_top_bar.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesControllerProvider);

    return SafeArea(
      bottom: false,
      child: favoritesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, stackTrace) => Center(
          child: Text(
            "Ma'lumotni yuklashda xatolik yuz berdi",
            style: AppTextStyles.subtitle,
          ),
        ),
        data: (favorites) => Column(
          children: [
            FavoritesTopBar(count: favorites.length),
            Expanded(
              child: favorites.isEmpty
                  ? const _EmptyFavorites()
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: favorites.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 12,
                            childAspectRatio: 2 / 3,
                          ),
                      itemBuilder: (context, index) {
                        final item = favorites[index];
                        return FavoriteCard(
                          key: ValueKey(item.id),
                          item: item,
                          onRemoveTap: () => ref
                              .read(favoritesControllerProvider.notifier)
                              .remove(item.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavorites extends ConsumerWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: AppColors.primarySofter,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                size: 34,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Sevimlilar ro'yxati bo'sh",
              style: AppTextStyles.title.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              "Yoqtirgan kino va seriallaringizni shu yerga qo'shing",
              style: AppTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () =>
                  ref.read(currentNavTabProvider.notifier).state = AppNavTab.home,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Bosh sahifani ko\'rish',
                  style: AppTextStyles.episodeCardTitle.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
