import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/profile_local_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile_data.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile.dart';

final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>((ref) {
  return ProfileLocalDataSource();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(profileLocalDataSourceProvider));
});

final getProfileProvider = Provider<GetProfile>((ref) {
  return GetProfile(ref.watch(profileRepositoryProvider));
});

final profileDataProvider = FutureProvider<ProfileData>((ref) {
  return ref.watch(getProfileProvider).call();
});
