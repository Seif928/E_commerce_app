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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  void _onAuthSucceeded(BuildContext context) {
    context.read<ProfileCubit>().getUserData();
    context.read<FavoriteCubit>().getFavoriteProducts();
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoute.homeRoute, (route) => false);
  }

  @override
  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<AuthCubit>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceCardDark : AppColors.surfaceCard;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textDark : AppColors.black;
    final subtextColor = isDark ? AppColors.textSecondaryDark : AppColors.grey1;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            context.isArabic
                ? Icons.arrow_forward_ios_rounded
                : Icons.arrow_back_ios_new_rounded,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(context.tr('create_account')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('join_verve'),
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('register_sub'),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: subtextColor),
                ),
                const SizedBox(height: 20),
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
                        label: context.tr('username'),
                        controller: usernameController,
                        prefixIcon: Icons.person_outline_rounded,
                        hintText: context.tr('username_hint'),
                      ),
                      const SizedBox(height: 16),
                      LabelWithTextField(
                        label: context.tr('email'),
                        controller: emailController,
                        prefixIcon: Icons.email_outlined,
                        hintText: context.tr('email_hint'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      LabelWithTextField(
                        label: context.tr('password'),
                        controller: passwordController,
                        prefixIcon: Icons.lock_outline_rounded,
                        hintText: context.tr('password_min_hint'),
                        obsecureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return context.tr('password_too_short');
                          }
                          return null;
                        },
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
                      const SizedBox(height: 24),
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
                            text: context.tr('create_account'),
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                await cubit.registerWithEmailAndPassword(
                                  emailController.text.trim(),
                                  passwordController.text,
                                  usernameController.text.trim(),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.tr('already_have_account'),
                      style: TextStyle(color: subtextColor),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        context.tr('sign_in'),
                        style: const TextStyle(
                          color: AppColors.accentColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(context.trError(state.message))));
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
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(context.trError(state.message))));
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
