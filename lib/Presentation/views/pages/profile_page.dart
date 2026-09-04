import 'package:e_commerce_app/Presentation/controller/porfile_cubit/cubit/profile_cubit.dart';
import 'package:e_commerce_app/Presentation/views/widgets/profile_body_widget.dart';
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
        leading: InkWell(
          onTap: () {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamedAndRemoveUntil(AppRoute.homeRoute, (route) => false);
          },
          child: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          'Profile',
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamedAndRemoveUntil(
                AppRoute.settingsRoute,
                (route) => false,
              );
            },
            child: Padding(
              padding: EdgeInsets.only(right: size.width * 0.04),
              child: const Icon(Icons.settings),
            ),
          ),
        ],
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        bloc: cubit,
        listenWhen: (previous, current) => current is ProfileLoadedError,
        listener: (context, state) {
          if (state is ProfileLoadedError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        buildWhen:
            (previous, current) =>
                current is ProfileLoading || current is ProfileLoaded,

        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileLoaded) {
            return ProfileBody(
              username: state.user.username,
              email: state.user.email,
              size: size,
              providerId: state.user.providerId,
            );
          }
          return const Center(child: Text('User not found'));
        },
      ),
    );
  }
}
