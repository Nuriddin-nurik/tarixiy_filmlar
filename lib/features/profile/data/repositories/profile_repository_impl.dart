import '../../domain/entities/profile_data.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  const ProfileRepositoryImpl(this.localDataSource);

  @override
  Future<ProfileData> getProfile() {
    return localDataSource.fetchProfile();
  }
}
