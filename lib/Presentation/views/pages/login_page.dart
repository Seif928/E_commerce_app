import 'package:e_commerce_app/Presentation/controller/auth_cubit/auth_cubit.dart';
import 'package:e_commerce_app/Presentation/controller/favorite_cubit/favorite_cubit.dart';
import 'package:e_commerce_app/Presentation/controller/porfile_cubit/cubit/profile_cubit.dart';
import 'package:e_commerce_app/Presentation/views/widgets/label_with_textfield.dart';
import 'package:e_commerce_app/Presentation/views/widgets/main_button.dart';
import 'package:e_commerce_app/Presentation/views/widgets/social_media_button.dart';
import 'package:e_commerce_app/core/localization/app_localizations.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/core/utils/app_route.dart';
import 'package:e_commerce_app/core/utils/image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onAuthSucceeded(BuildContext context) {
    context.read<ProfileCubit>().getUserData();
    context.read<FavoriteCubit>().getFavoriteProducts();
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoute.homeRoute, (route) => false);
  }

  Future<void> _showForgotPasswordDialog(
    BuildContext context,
    AuthCubit cubit,
  ) async {
    final resetEmailController = TextEditingController(
      text: emailController.text.trim(),
    );
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.tr('reset_password_title')),
          content: TextField(
            controller: resetEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: context.tr('email'),
              hintText: context.tr('reset_password_sub'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.tr('cancel')),
            ),
            TextButton(
              onPressed: () {
                final email = resetEmailController.text.trim();
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.trError('Please enter your email'),
                      ),
                    ),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop();
                cubit.sendPasswordResetEmail(email);
              },
              child: Text(context.tr('send_link')),
            ),
          ],
        );
      },
    );
    resetEmailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<AuthCubit>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textDark : AppColors.black;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.grey1;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? AppColors.accentColor
                                : AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_rounded,
                        color: AppColors.white1,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'VERVE STORE',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color:
                            isDark
                                ? AppColors.textDark
                                : AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  context.tr('login_title'),
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('login_sub'),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: subtextColor),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      LabelWithTextField(
                        label: context.tr('email'),
                        controller: emailController,
                        prefixIcon: Icons.email_outlined,
                        hintText: context.tr('email_hint'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 18),
                      LabelWithTextField(
                        label: context.tr('password'),
                        controller: passwordController,
                        prefixIcon: Icons.lock_outline_rounded,
                        hintText: context.tr('password_hint'),
                        obsecureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 6),
                      BlocListener<AuthCubit, AuthState>(
                        bloc: cubit,
                        listenWhen:
                            (previous, current) =>
                                current is PasswordResetSuccess ||
                                current is PasswordResetError,
                        listener: (context, state) {
                          if (state is PasswordResetSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.tr('reset_link_sent'),
                                ),
                              ),
                            );
                          } else if (state is PasswordResetError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.trError(state.message)),
                              ),
                            );
                          }
                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed:
                                () => _showForgotPasswordDialog(context, cubit),
                            child: Text(
                              context.tr('forgot_password'),
                              style: const TextStyle(
                                color: AppColors.accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      BlocConsumer<AuthCubit, AuthState>(
                        bloc: cubit,
                        listenWhen:
                            (previous, current) =>
                                current is AuthDone || current is AuthError,
                        listener: (context, state) {
                          if (state is AuthDone) {
                            _onAuthSucceeded(context);
                          } else if (state is AuthError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.trError(state.message)),
                              ),
                            );
                          }
                        },
                        buildWhen:
                            (previous, current) =>
                                current is AuthLoading ||
                                current is AuthError ||
                                current is AuthDone,
                        builder: (context, state) {
                          if (state is AuthLoading) {
                            return MainButton(isLoading: true);
                          }
                          return MainButton(
                            text: context.tr('sign_in'),
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                await cubit.loginWithEmailAndPassword(
                                  emailController.text.trim(),
                                  passwordController.text,
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.tr('dont_have_account'),
                      style: TextStyle(color: subtextColor),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoute.registerRoute);
                      },
                      child: Text(
                        context.tr('create_account'),
                        style: const TextStyle(
                          color: AppColors.accentColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Divider(color: borderColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        context.tr('or_continue_with'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: subtextColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: borderColor)),
                  ],
                ),
                const SizedBox(height: 16),
                BlocConsumer<AuthCubit, AuthState>(
                  bloc: cubit,
                  listenWhen:
                      (previous, current) =>
                          current is GoogleAuthDone ||
                          current is GoogleAuthError,
                  listener: (context, state) {
                    if (state is GoogleAuthDone) {
                      _onAuthSucceeded(context);
                    } else if (state is GoogleAuthError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.trError(state.message))),
                      );
                    }
                  },
                  buildWhen:
                      (previous, current) =>
                          current is GoogleAuthenticating ||
                          current is GoogleAuthError ||
                          current is GoogleAuthDone,
                  builder: (context, state) {
                    if (state is GoogleAuthenticating) {
                      return SocialMediaButton(isLoading: true);
                    }
                    return SocialMediaButton(
                      text: context.tr('continue_google'),
                      imgUrl: ImageUtils.googleImgUrl,
                      onTap: () async => await cubit.authenticateWithGoogle(),
                    );
                  },
                ),
                const SizedBox(height: 12),
                BlocConsumer<AuthCubit, AuthState>(
                  bloc: cubit,
                  listenWhen:
                      (previous, current) =>
                          current is FacebookAuthDone ||
                          current is FacebookAuthError,
                  listener: (context, state) {
                    if (state is FacebookAuthDone) {
                      _onAuthSucceeded(context);
                    } else if (state is FacebookAuthError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.trError(state.message))),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is FacebookAuthenticating) {
                      return SocialMediaButton(isLoading: true);
                    }
                    return SocialMediaButton(
                      text: context.tr('continue_facebook'),
                      imgUrl: ImageUtils.faceBookImgUrl,
                      onTap: () async => await cubit.authenticateWithFacebook(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
