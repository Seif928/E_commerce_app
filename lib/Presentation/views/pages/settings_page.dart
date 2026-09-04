import 'package:e_commerce_app/Presentation/controller/auth_cubit/auth_cubit.dart';
import 'package:e_commerce_app/Presentation/views/widgets/empty_list_tile.dart';
import 'package:e_commerce_app/Presentation/views/widgets/main_button.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/core/utils/app_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<AuthCubit>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamedAndRemoveUntil(AppRoute.profileRoute, (route) => false);
          },
          child: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          'Settings',
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: size.height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'General',
              style: TextTheme.of(
                context,
              ).titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            EmptyListTile(
              ontap:
                  () => Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamedAndRemoveUntil(
                    AppRoute.editProfileRoute,
                    (route) => false,
                  ),
              leadingIcon: Icon(Icons.person),
              title: 'Edit Profile',
              trailingIcon: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.grey1,
              ),
            ),
            EmptyListTile(
              ontap:
                  () => Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamedAndRemoveUntil(
                    AppRoute.editProfileRoute,
                    (route) => false,
                  ),
              leadingIcon: Icon(Icons.password),
              title: 'Change Password',
              trailingIcon: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.grey1,
              ),
            ),
            EmptyListTile(
              ontap:
                  () => Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamedAndRemoveUntil(
                    AppRoute.profileRoute,
                    (route) => false,
                  ),
              leadingIcon: Icon(Icons.notifications),
              title: 'Notifications',
              trailingIcon: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.grey1,
              ),
            ),
            EmptyListTile(
              ontap:
                  () => Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamedAndRemoveUntil(
                    AppRoute.profileRoute,
                    (route) => false,
                  ),
              leadingIcon: Icon(Icons.lock),
              title: 'Security',
              trailingIcon: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.grey1,
              ),
            ),
            EmptyListTile(
              ontap:
                  () => Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamedAndRemoveUntil(
                    AppRoute.profileRoute,
                    (route) => false,
                  ),
              leadingIcon: Icon(Icons.language),
              title: 'Language',
              trailingIcon: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.grey1,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'Preferences',
              style: TextTheme.of(
                context,
              ).titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.02),
            EmptyListTile(
              ontap:
                  () => Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamedAndRemoveUntil(
                    AppRoute.profileRoute,
                    (route) => false,
                  ),
              leadingIcon: Icon(Icons.privacy_tip),
              title: 'Privacy Policy',
              trailingIcon: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.grey1,
              ),
            ),
            EmptyListTile(
              ontap:
                  () => Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamedAndRemoveUntil(
                    AppRoute.profileRoute,
                    (route) => false,
                  ),
              leadingIcon: Icon(Icons.help_outline),
              title: 'Help & Support',
              trailingIcon: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.grey1,
              ),
            ),
            BlocConsumer<AuthCubit, AuthState>(
              bloc: cubit,
              listenWhen:
                  (previous, current) =>
                      current is AuthLoggedOut || current is AuthLogOutError,
              listener: (context, state) {
                if (state is AuthLoggedOut) {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamedAndRemoveUntil(
                    AppRoute.loginRoute,
                    (route) => false,
                  );
                } else if (state is AuthLogOutError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              buildWhen: (previous, current) => current is AuthLoggingOut,
              builder: (context, state) {
                if (state is AuthLoggingOut) {
                  return MainButton(isLoading: true);
                }
                if (state is AuthLoggedOut) {
                  return EmptyListTile(
                    ontap: () async {
                      await cubit.logout();
                      if (!context.mounted) return;
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamedAndRemoveUntil(
                        AppRoute.profileRoute,
                        (route) => false,
                      );
                    },
                    leadingIcon: Icon(Icons.logout, color: AppColors.red),
                    title: 'Logout',
                    titleColor: AppColors.red,
                  );
                }
                return EmptyListTile(
                  ontap: () async {
                    await cubit.logout();
                    if (!context.mounted) return;
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushNamedAndRemoveUntil(
                      AppRoute.profileRoute,
                      (route) => false,
                    );
                  },
                  leadingIcon: Icon(Icons.logout, color: AppColors.red),
                  title: 'Logout',
                  titleColor: AppColors.red,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
