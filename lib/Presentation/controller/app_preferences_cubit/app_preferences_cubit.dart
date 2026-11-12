import 'package:e_commerce_app/Presentation/controller/app_preferences_cubit/app_preferences_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesCubit extends Cubit<AppPreferencesState> {
  static const String _themeModeKey = 'app_theme_mode';
  static const String _languageKey = 'app_language';

  AppPreferencesCubit() : super(AppPreferencesState.initial());

  Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeStr = prefs.getString(_themeModeKey) ?? 'light';
      final langStr = prefs.getString(_languageKey) ?? 'en';

      final mode = themeStr == 'dark' ? ThemeMode.dark : ThemeMode.light;
      final locale = Locale(langStr == 'ar' ? 'ar' : 'en');

      emit(state.copyWith(themeMode: mode, locale: locale));
    } catch (_) {
      // Fallback silently to initial defaults
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final cleanMode =
        mode == ThemeMode.dark ? ThemeMode.dark : ThemeMode.light;
    emit(state.copyWith(themeMode: cleanMode));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _themeModeKey,
        cleanMode == ThemeMode.dark ? 'dark' : 'light',
      );
    } catch (_) {}
  }

  Future<void> setLocale(Locale locale) async {
    emit(state.copyWith(locale: locale));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
    } catch (_) {}
  }

  Future<void> toggleTheme() async {
    final newMode =
        state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}
