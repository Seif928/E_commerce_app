import 'package:e_commerce_app/Presentation/controller/porfile_cubit/cubit/profile_cubit.dart';
import 'package:e_commerce_app/Presentation/views/widgets/profile_body_widget.dart';
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
      size: size,
      onEditUserNameProfile: (newUsername) {
        cubit.updateUserName(name: newUsername);
      },
      onEditEmailProfile: (newEmail) {
        cubit.updateEmail(newEmail: newEmail);
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
        leading: InkWell(
          onTap: () {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamedAndRemoveUntil(AppRoute.settingsRoute, (route) => false);
          },
          child: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        bloc: cubit,
        listener: (context, state) {
          if (state is ProfileUpdatingFailed) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        buildWhen: (previous, current) =>
            current is ProfileLoading ||
            current is ProfileLoaded ||
            current is ProfileUpdating ||
            current is ProfileUpdatedSuccess,
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileUpdating) {
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