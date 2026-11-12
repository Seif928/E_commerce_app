import 'package:e_commerce_app/Presentation/controller/app_preferences_cubit/app_preferences_cubit.dart';
import 'package:e_commerce_app/Presentation/controller/app_preferences_cubit/app_preferences_state.dart';
import 'package:e_commerce_app/Presentation/controller/auth_cubit/auth_cubit.dart';
import 'package:e_commerce_app/Presentation/controller/porfile_cubit/cubit/profile_cubit.dart';
import 'package:e_commerce_app/Presentation/views/widgets/empty_list_tile.dart';
import 'package:e_commerce_app/Presentation/views/widgets/main_button.dart';
import 'package:e_commerce_app/Presentation/views/widgets/notifications_sheet.dart';
import 'package:e_commerce_app/core/localization/app_localizations.dart';
import 'package:e_commerce_app/core/utils/app_colors.dart';
import 'package:e_commerce_app/core/utils/app_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final profileCubit = context.read<ProfileCubit>();
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.tr('settings_change_password')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.isArabic ? 'كلمة المرور الجديدة' : 'New Password',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.isArabic ? 'تأكيد كلمة المرور' : 'Confirm Password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.tr('cancel')),
            ),
            TextButton(
              onPressed: () {
                final newPass = passwordController.text.trim();
                final confirmPass = confirmController.text.trim();
                if (newPass.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.trError('Password must be at least 6 characters'),
                      ),
                    ),
                  );
                  return;
                }
                if (newPass != confirmPass) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.trError('Passwords do not match'),
                      ),
                    ),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop();
                profileCubit.updatePassword(newPassword: newPass);
              },
              child: Text(context.tr('save')),
            ),
          ],
        );
      },
    );
    passwordController.dispose();
    confirmController.dispose();
  }

  Future<void> _showSecurityDialog(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final providers =
        user?.providerData.map((p) => p.providerId).join(', ') ?? 'None';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.tr('settings_security')),
          content: Text(
            context.isArabic
                ? 'البريد الإلكتروني: ${user?.email ?? 'غير متوفر'}\n'
                  'تم التحقق: ${user?.emailVerified == true ? 'نعم' : 'لا'}\n'
                  'طريقة تسجيل الدخول: $providers'
                : 'Email: ${user?.email ?? 'N/A'}\n'
                  'Email Verified: ${user?.emailVerified ?? false}\n'
                  'Sign-in Provider: $providers',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.tr('ok')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showInfoDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.tr('ok')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showThemeSelectionSheet(BuildContext context) async {
    final prefCubit = context.read<AppPreferencesCubit>();
    final currentMode = prefCubit.state.themeMode;

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.grey1.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  context.tr('settings_theme'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.light_mode_outlined),
                  title: Text(context.tr('theme_light')),
                  trailing: currentMode == ThemeMode.light
                      ? const Icon(Icons.check_circle, color: AppColors.accentColor)
                      : null,
                  onTap: () {
                    prefCubit.setThemeMode(ThemeMode.light);
                    Navigator.of(sheetContext).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: Text(context.tr('theme_dark')),
                  trailing: currentMode == ThemeMode.dark
                      ? const Icon(Icons.check_circle, color: AppColors.accentColor)
                      : null,
                  onTap: () {
                    prefCubit.setThemeMode(ThemeMode.dark);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showLanguageSelectionSheet(BuildContext context) async {
    final prefCubit = context.read<AppPreferencesCubit>();
    final currentCode = prefCubit.state.locale.languageCode;

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.grey1.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  context.tr('settings_language'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Text('🇺🇸', style: TextStyle(fontSize: 22)),
                  title: Text(context.tr('lang_en')),
                  trailing: currentCode == 'en'
                      ? const Icon(Icons.check_circle, color: AppColors.accentColor)
                      : null,
                  onTap: () {
                    prefCubit.setLocale(const Locale('en'));
                    Navigator.of(sheetContext).pop();
                  },
                ),
                ListTile(
                  leading: const Text('🇪🇬', style: TextStyle(fontSize: 22)),
                  title: Text(context.tr('lang_ar')),
                  trailing: currentCode == 'ar'
                      ? const Icon(Icons.check_circle, color: AppColors.accentColor)
                      : null,
                  onTap: () {
                    prefCubit.setLocale(const Locale('ar'));
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getThemeModeTitle(BuildContext context, ThemeMode mode) {
    return mode == ThemeMode.dark
        ? context.tr('theme_dark')
        : context.tr('theme_light');
  }

  String _getLanguageTitle(BuildContext context, Locale locale) {
    return locale.languageCode == 'ar'
        ? context.tr('lang_ar')
        : context.tr('lang_en');
  }

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<AuthCubit>(context);
    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen:
          (previous, current) =>
              current is ProfileUpdatedSuccess ||
              current is ProfileUpdatingFailed,
      listener: (context, state) {
        if (state is ProfileUpdatedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr('profile_updated'))),
          );
        } else if (state is ProfileUpdatingFailed) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.trError(state.error))));
        }
      },
      child: Scaffold(
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
                  AppRoute.homeRoute,
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
          title: Text(context.tr('settings_title')),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('settings_general'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              EmptyListTile(
                ontap:
                    () => Navigator.of(
                      context,
                    ).pushNamed(AppRoute.editProfileRoute),
                leadingIcon: const Icon(Icons.person_outline_rounded),
                title: context.tr('settings_edit_profile'),
                trailingIcon: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.grey1,
                ),
              ),
              EmptyListTile(
                ontap: () => _showChangePasswordDialog(context),
                leadingIcon: const Icon(Icons.password_rounded),
                title: context.tr('settings_change_password'),
                trailingIcon: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.grey1,
                ),
              ),
              EmptyListTile(
                ontap: () => showNotificationsSheet(context),
                leadingIcon: const Icon(Icons.notifications_none_rounded),
                title: context.tr('settings_notifications'),
                trailingIcon: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.grey1,
                ),
              ),
              EmptyListTile(
                ontap: () => _showSecurityDialog(context),
                leadingIcon: const Icon(Icons.lock_outline_rounded),
                title: context.tr('settings_security'),
                trailingIcon: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.grey1,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                context.tr('settings_preferences'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              BlocBuilder<AppPreferencesCubit, AppPreferencesState>(
                builder: (context, prefState) {
                  return EmptyListTile(
                    ontap: () => _showThemeSelectionSheet(context),
                    leadingIcon: Icon(
                      prefState.themeMode == ThemeMode.dark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: AppColors.accentColor,
                    ),
                    title: context.tr('settings_theme'),
                    subtitle: _getThemeModeTitle(context, prefState.themeMode),
                    trailingIcon: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.grey1,
                    ),
                  );
                },
              ),
              BlocBuilder<AppPreferencesCubit, AppPreferencesState>(
                builder: (context, prefState) {
                  return EmptyListTile(
                    ontap: () => _showLanguageSelectionSheet(context),
                    leadingIcon: const Icon(
                      Icons.language_rounded,
                      color: AppColors.blue,
                    ),
                    title: context.tr('settings_language'),
                    subtitle: _getLanguageTitle(context, prefState.locale),
                    trailingIcon: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.grey1,
                    ),
                  );
                },
              ),
              EmptyListTile(
                ontap:
                    () => _showInfoDialog(
                      context,
                      title: context.tr('settings_privacy'),
                      content: context.isArabic
                          ? 'يتم تخزين بيانات حسابك وعناوين الشحن وبطاقات الدفع وسلتك وطلباتك بأمان تام وفقاً لأعلى معايير الخصوصية.'
                          : 'Your account data, saved addresses, payment cards, cart, and orders are stored securely per user account.',
                    ),
                leadingIcon: const Icon(Icons.privacy_tip_outlined),
                title: context.tr('settings_privacy'),
                trailingIcon: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.grey1,
                ),
              ),
              EmptyListTile(
                ontap:
                    () => _showInfoDialog(
                      context,
                      title: context.tr('settings_help'),
                      content: context.isArabic
                          ? 'هل تحتاج لمساعدة في حسابك أو طلباتك؟ تواصل معنا عبر البريد: support@ecommerce-app.local'
                          : 'Need help with an order or your account? Contact support@ecommerce-app.local.',
                    ),
                leadingIcon: const Icon(Icons.help_outline_rounded),
                title: context.tr('settings_help'),
                trailingIcon: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.grey1,
                ),
              ),
              const SizedBox(height: 12),
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
                    ).showSnackBar(SnackBar(content: Text(context.trError(state.message))));
                  }
                },
                buildWhen:
                    (previous, current) =>
                        current is AuthLoggingOut ||
                        current is AuthLoggedOut ||
                        current is AuthLogOutError,
                builder: (context, state) {
                  if (state is AuthLoggingOut) {
                    return MainButton(isLoading: true);
                  }
                  return EmptyListTile(
                    ontap: () async => await cubit.logout(),
                    leadingIcon: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.red,
                    ),
                    title: context.tr('settings_logout'),
                    titleColor: AppColors.red,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
