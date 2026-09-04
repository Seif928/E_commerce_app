part of 'profile_cubit.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final AppUser user;
  const ProfileLoaded({required this.user});

  @override
  List<Object> get props => [user];
}

final class ProfileLoadedError extends ProfileState {
  final String error;
  const ProfileLoadedError({required this.error});

  @override
  List<Object> get props => [error];
}

final class ProfileUpdating extends ProfileState {}

final class ProfileUpdatedSuccess extends ProfileState {
  final AppUser user;
  const ProfileUpdatedSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

final class ProfileUpdatingFailed extends ProfileState {
  final String error;
  const ProfileUpdatingFailed({required this.error});

  @override
  List<Object> get props => [error];
}
