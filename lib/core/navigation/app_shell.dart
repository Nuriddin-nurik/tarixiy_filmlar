import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/episodes/presentation/pages/episode_list_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../pages/home/home.dart';
import '../theme/app_colors.dart';
import 'app_bottom_nav_bar.dart';
import 'app_nav_tab.dart';

final currentNavTabProvider = StateProvider<AppNavTab>((ref) => AppNavTab.home);

/// Hosts the four bottom-nav tabs behind a single Scaffold, so each page owns
/// only its content and the navigation chrome lives in one place.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentNavTabProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: currentTab.index,
        children: const [
          Home(),
          EpisodeListPage(),
          FavoritesPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        current: currentTab,
        onChanged: (tab) => ref.read(currentNavTabProvider.notifier).state = tab,
      ),
    );
  }
}
