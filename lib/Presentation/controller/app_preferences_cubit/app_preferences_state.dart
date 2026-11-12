import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppPreferencesState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;

  const AppPreferencesState({
    required this.themeMode,
    required this.locale,
  });

  factory AppPreferencesState.initial() {
    return const AppPreferencesState(
      themeMode: ThemeMode.light,
      locale: Locale('en'),
    );
  }

  AppPreferencesState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return AppPreferencesState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale];
}
