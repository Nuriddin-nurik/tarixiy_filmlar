class UserProfile {
  final String name;
  final String email;
  final String avatarAsset;
  final bool isPremium;
  final String premiumRenewalLabel;

  const UserProfile({
    required this.name,
    required this.email,
    required this.avatarAsset,
    required this.isPremium,
    required this.premiumRenewalLabel,
  });
}
