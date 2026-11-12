import 'package:e_commerce_app/Presentation/controller/porfile_cubit/cubit/profile_cubit.dart';
import 'package:e_commerce_app/Presentation/views/widgets/profile_body_widget.dart';
import 'package:e_commerce_app/core/localization/app_localizations.dart';
import 'package:e_commerce_app/core/utils/app_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<ProfileCubit>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamedAndRemoveUntil(AppRoute.homeRoute, (route) => false);
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: Text(context.tr('nav_account')),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed(AppRoute.settingsRoute);
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        bloc: cubit,
        listenWhen:
            (previous, current) =>
                current is ProfileLoadedError ||
                current is ProfileUpdatingFailed ||
                current is ProfileUpdatedSuccess,
        listener: (context, state) {
          if (state is ProfileLoadedError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(context.trError(state.error))));
          } else if (state is ProfileUpdatingFailed) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(context.trError(state.error))));
          } else if (state is ProfileUpdatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.tr('profile_updated'))),
            );
          }
        },
        buildWhen:
            (previous, current) =>
                current is ProfileLoading ||
                current is ProfileLoaded ||
                current is ProfileUpdatedSuccess ||
                current is ProfileLoadedError,
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (state is ProfileLoaded) {
            return ProfileBody(
              username: state.user.username,
              email: state.user.email,
              photoUrl: state.user.photoUrl,
              size: size,
              providerId: state.user.providerId,
              onEditPhoto: (url) => cubit.updateProfilePhoto(photoUrl: url),
            );
          } else if (state is ProfileUpdatedSuccess) {
            return ProfileBody(
              username: state.user.username,
              email: state.user.email,
              photoUrl: state.user.photoUrl,
              size: size,
              providerId: state.user.providerId,
              onEditPhoto: (url) => cubit.updateProfilePhoto(photoUrl: url),
            );
          } else if (state is ProfileLoadedError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.trError(state.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => cubit.getUserData(),
                      child: Text(context.tr('retry')),
                    ),
                  ],
                ),
              ),
            );
          }
          return Center(
            child: Text(
              context.isArabic ? 'المستخدم غير موجود' : 'User not found',
            ),
          );
        },
      ),
    );
  }
}
