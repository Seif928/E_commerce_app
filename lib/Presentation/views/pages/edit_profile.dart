import 'package:e_commerce_app/Presentation/controller/porfile_cubit/cubit/profile_cubit.dart';
import 'package:e_commerce_app/Presentation/views/widgets/profile_body_widget.dart';
import 'package:e_commerce_app/core/localization/app_localizations.dart';
import 'package:e_commerce_app/core/utils/app_route.dart';
import 'package:e_commerce_app/domain/entities/app_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({super.key});

  Widget _buildBody(AppUser user, ProfileCubit cubit, Size size) {
    return ProfileBody(
      username: user.username,
      email: user.email,
      photoUrl: user.photoUrl,
      size: size,
      onEditUserNameProfile: (newUsername) {
        cubit.updateUserName(name: newUsername);
      },
      onEditEmailProfile: (newEmail) {
        cubit.updateEmail(newEmail: newEmail);
      },
      onEditPhoto: (url) {
        cubit.updateProfilePhoto(photoUrl: url);
      },
      providerId: user.providerId,
    );
  }

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
              ).pushNamedAndRemoveUntil(
                AppRoute.settingsRoute,
                (route) => false,
              );
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: Text(context.tr('settings_edit_profile')),
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        bloc: cubit,
        listener: (context, state) {
          if (state is ProfileUpdatingFailed) {
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
                current is ProfileUpdating ||
                current is ProfileUpdatedSuccess,
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileUpdating) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (state is ProfileLoaded) {
            return _buildBody(state.user, cubit, size);
          } else if (state is ProfileUpdatedSuccess) {
            return _buildBody(state.user, cubit, size);
          }
          return _buildBody(
            const AppUser(
              id: '',
              password: '',
              username: 'No name',
              email: 'No email',
              createdAt: '',
            ),
            cubit,
            size,
          );
        },
      ),
    );
  }
}
