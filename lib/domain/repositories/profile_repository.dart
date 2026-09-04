import 'package:e_commerce_app/domain/entities/app_user.dart';

abstract class ProfileRepository {
  Future<void> changeUserName(String userId, String newName);
  Future<void> changeUserEmail(String userId, String newEmail);
  Future<void> changeUserPassword(String userId, String newPassword);
  Future<void> deleteUser(String userId);
  Future<AppUser> getUserData(String userId);
}