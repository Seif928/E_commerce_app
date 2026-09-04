import 'package:e_commerce_app/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<bool> loginWithEmailAndPassword(String email, String password);
  Future<bool> registerWithEmailAndPassword(String email, String password);
  Future<bool> authenticateWithGoogle();
  Future<bool> authenticateWithFacebook();
  Future<void> logout();
  Future<void> saveUserData(AppUser user);
  String? get currentUserId;
}