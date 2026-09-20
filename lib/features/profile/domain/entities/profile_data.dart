import 'profile_menu_item.dart';
import 'user_profile.dart';

class ProfileData {
  final UserProfile user;
  final List<ProfileMenuItem> menuItems;
  final String appVersionLabel;

  const ProfileData({
    required this.user,
    required this.menuItems,
    required this.appVersionLabel,
  });
}
