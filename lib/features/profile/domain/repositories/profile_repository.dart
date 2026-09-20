import '../entities/profile_data.dart';

abstract class ProfileRepository {
  Future<ProfileData> getProfile();
}
