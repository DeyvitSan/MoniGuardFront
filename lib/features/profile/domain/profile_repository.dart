import 'entities/profile_user.dart';

abstract interface class ProfileRepository {
  Future<ProfileUser> getProfile();
  Future<ProfileUser> updateName({required String name});
  Future<ProfileUser> updatePassword({required String currentPassword, required String newPassword});
}

class ProfileException implements Exception {
  final String message;
  const ProfileException(this.message);

  @override
  String toString() => 'ProfileException: $message';
}
