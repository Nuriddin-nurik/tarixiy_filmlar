import '../../domain/entities/profile_data.dart';
import '../../domain/entities/profile_menu_item.dart';
import '../../domain/entities/user_profile.dart';

/// Stand-in for a future remote/local data source. Serves the fixture that
/// mirrors the Figma "Profil - Mobile" design until a real API is wired up.
class ProfileLocalDataSource {
  Future<ProfileData> fetchProfile() async {
    return const ProfileData(
      user: UserProfile(
        name: 'Muhammad Amin',
        email: 'muhammadamin@gmail.com',
        avatarAsset: '',
        isPremium: true,
        premiumRenewalLabel: '15 Okt, 2024',
      ),
      menuItems: [
        ProfileMenuItem(
          id: 'account',
          title: "Hisob ma'lumotlari",
          subtitle: 'Ism, email va parol',
          icon: ProfileMenuIconKind.account,
        ),
        ProfileMenuItem(
          id: 'settings',
          title: 'Ilova sozlamalari',
          subtitle: 'Til, bildirishnomalar',
          icon: ProfileMenuIconKind.settings,
        ),
        ProfileMenuItem(
          id: 'devices',
          title: 'Faol qurilmalar',
          subtitle: 'Hozirda 2 ta qurilma ulangan',
          icon: ProfileMenuIconKind.devices,
        ),
        ProfileMenuItem(
          id: 'help',
          title: "Yordam va qo'llab-quvvatlash",
          subtitle: 'FAQ, aloqa',
          icon: ProfileMenuIconKind.help,
        ),
      ],
      appVersionLabel: 'Versiya 1.0.5 (Build 42)',
    );
  }
}
