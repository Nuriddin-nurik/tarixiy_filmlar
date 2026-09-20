enum ProfileMenuIconKind { account, settings, devices, help }

class ProfileMenuItem {
  final String id;
  final String title;
  final String subtitle;
  final ProfileMenuIconKind icon;

  const ProfileMenuItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
