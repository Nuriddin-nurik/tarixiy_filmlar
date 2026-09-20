import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/profile_providers.dart';
import '../widgets/logout_button.dart';
import '../widgets/premium_card.dart';
import '../widgets/profile_menu_section.dart';
import '../widgets/profile_top_bar.dart';
import '../widgets/profile_user_card.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileDataProvider);

    return SafeArea(
      child: profileAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, stackTrace) => Center(
          child: Text(
            "Ma'lumotni yuklashda xatolik yuz berdi",
            style: AppTextStyles.subtitle,
          ),
        ),
        data: (profile) => ListView(
          children: [
            const ProfileTopBar(),
            const SizedBox(height: 8),
            ProfileUserCard(user: profile.user),
            PremiumCard(user: profile.user),
            ProfileMenuSection(title: 'Sozlamalar', items: profile.menuItems),
            LogoutButton(onTap: () {}),
            const SizedBox(height: 16),
            Center(
              child: Text(
                profile.appVersionLabel,
                style: AppTextStyles.episodeCardMeta,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
