import 'entities/profile_user.dart';

abstract interface class ProfileRepository {
  Future<ProfileUser> getProfile();
  Future<ProfileUser> updateName({required String name});
}

class ProfileException implements Exception {
  final String message;
  const ProfileException(this.message);

  @override
  String toString() => 'ProfileException: $message';
}
