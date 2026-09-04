import 'package:e_commerce_app/data/repositories/auth_repository_impl.dart';
import 'package:e_commerce_app/domain/entities/app_user.dart';
import 'package:e_commerce_app/domain/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepositoryImpl(),
      super(AuthInitial());

  final AuthRepository _authRepository;

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.loginWithEmailAndPassword(
        email,
        password,
      );
      if (result) {
        emit(const AuthDone());
      } else {
        emit(const AuthError('Login failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> registerWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.registerWithEmailAndPassword(
        email,
        password,
      );
      if (result) {
        await _saveUserData(email, username, password);
        emit(const AuthDone());
      } else {
        emit(const AuthError('Register failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _saveUserData(
    String email,
    String username,
    String password,
  ) async {
    final userId = _authRepository.currentUserId;
    if (userId == null) return;
    final userData = AppUser(
      id: userId,
      username: username,
      password: password,
      email: email,
      createdAt: DateTime.now().toIso8601String(),
    );
    await _authRepository.saveUserData(userData);
  }

  void checkAuth() {
    final userId = _authRepository.currentUserId;
    if (userId != null) {
      emit(const AuthDone());
    }
  }

  Future<void> logout() async {
    emit(const AuthLoggingOut());
    try {
      await _authRepository.logout();
      emit(const AuthLoggedOut());
    } catch (e) {
      emit(AuthLogOutError(e.toString()));
    }
  }

  Future<void> authenticateWithGoogle() async {
    emit(const GoogleAuthenticating());
    try {
      final result = await _authRepository.authenticateWithGoogle();
      if (result) {
        emit(const GoogleAuthDone());
      } else {
        emit(const GoogleAuthError('Google authentication failed'));
      }
    } catch (e) {
      emit(GoogleAuthError(e.toString()));
    }
  }

  Future<void> authenticateWithFacebook() async {
    emit(const FacebookAuthenticating());
    try {
      final result = await _authRepository.authenticateWithFacebook();
      if (result) {
        emit(const FacebookAuthDone());
      } else {
        emit(const FacebookAuthError('Facebook authentication failed'));
      }
    } catch (e) {
      emit(FacebookAuthError(e.toString()));
    }
  }
}