import 'package:e_commerce_app/data/repositories/auth_repository_impl.dart';
import 'package:e_commerce_app/data/repositories/profile_repository_impl.dart';
import 'package:e_commerce_app/domain/entities/app_user.dart';
import 'package:e_commerce_app/domain/repositories/auth_repository.dart';
import 'package:e_commerce_app/domain/repositories/profile_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    ProfileRepository? profileRepository,
    AuthRepository? authRepository,
  }) : _profileRepository = profileRepository ?? ProfileRepositoryImpl(),
       _authRepository = authRepository ?? AuthRepositoryImpl(),
       super(ProfileInitial());

  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;

  Future<void> getUserData() async {
    final currentUserId = _authRepository.currentUserId;
    if (currentUserId == null) {
      emit(ProfileInitial());
      return;
    }
    emit(ProfileLoading());
    try {
      final data = await _profileRepository.getUserData(currentUserId);
      if (isClosed) return;
      emit(ProfileLoaded(user: data));
    } catch (e) {
      if (isClosed) return;
      emit(ProfileLoadedError(error: e.toString()));
    }
  }

  Future<void> updateUserName({required String name}) async {
    emit(ProfileUpdating());
    try {
      final currentUserId = _authRepository.currentUserId;
      if (currentUserId == null) {
        emit(const ProfileUpdatingFailed(error: 'User is not logged in'));
        return;
      }
      await _profileRepository.changeUserName(currentUserId, name);
      final data = await _profileRepository.getUserData(currentUserId);
      if (isClosed) return;
      emit(ProfileUpdatedSuccess(user: data));
      emit(ProfileLoaded(user: data));
    } catch (e) {
      if (isClosed) return;
      emit(ProfileUpdatingFailed(error: e.toString()));
    }
  }

  Future<void> updateEmail({required String newEmail}) async {
    emit(ProfileUpdating());
    try {
      final currentUserId = _authRepository.currentUserId;
      if (currentUserId == null) {
        emit(const ProfileUpdatingFailed(error: 'User is not logged in'));
        return;
      }
      await _profileRepository.changeUserEmail(currentUserId, newEmail);
      final data = await _profileRepository.getUserData(currentUserId);
      if (isClosed) return;
      emit(ProfileUpdatedSuccess(user: data));
      emit(ProfileLoaded(user: data));
    } catch (e) {
      if (isClosed) return;
      emit(ProfileUpdatingFailed(error: e.toString()));
    }
  }

  Future<void> updatePassword({required String newPassword}) async {
    emit(ProfileUpdating());
    try {
      final currentUserId = _authRepository.currentUserId;
      if (currentUserId == null) {
        emit(const ProfileUpdatingFailed(error: 'User is not logged in'));
        return;
      }
      await _profileRepository.changeUserPassword(currentUserId, newPassword);
      final data = await _profileRepository.getUserData(currentUserId);
      if (isClosed) return;
      emit(ProfileUpdatedSuccess(user: data));
      emit(ProfileLoaded(user: data));
    } catch (e) {
      if (isClosed) return;
      emit(ProfileUpdatingFailed(error: e.toString()));
    }
  }

  Future<void> updateProfilePhoto({required String photoUrl}) async {
    emit(ProfileUpdating());
    try {
      final currentUserId = _authRepository.currentUserId;
      if (currentUserId == null) {
        emit(const ProfileUpdatingFailed(error: 'User is not logged in'));
        return;
      }
      await _profileRepository.updateUserPhoto(currentUserId, photoUrl);
      final data = await _profileRepository.getUserData(currentUserId);
      if (isClosed) return;
      emit(ProfileUpdatedSuccess(user: data));
      emit(ProfileLoaded(user: data));
    } catch (e) {
      if (isClosed) return;
      emit(ProfileUpdatingFailed(error: e.toString()));
    }
  }
}
