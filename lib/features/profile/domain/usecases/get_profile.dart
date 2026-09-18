import '../entities/profile_data.dart';
import '../repositories/profile_repository.dart';

class GetProfile {
  final ProfileRepository repository;

  const GetProfile(this.repository);

  Future<ProfileData> call() {
    return repository.getProfile();
  }
}
