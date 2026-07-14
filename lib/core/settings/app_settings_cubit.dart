import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:checkmate/core/constants/app_constants.dart';

class AppSettingsState extends Equatable {
  final ThemeMode themeMode;
  final bool isLoading;

  const AppSettingsState({
    this.themeMode = ThemeMode.light,
    this.isLoading = true,
  });

  bool get isDarkMode => themeMode == ThemeMode.dark;

  AppSettingsState copyWith({ThemeMode? themeMode, bool? isLoading}) =>
      AppSettingsState(
        themeMode: themeMode ?? this.themeMode,
        isLoading: isLoading ?? this.isLoading,
      );

  @override
  List<Object?> get props => [themeMode, isLoading];
}

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit() : super(const AppSettingsState()) {
    load();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.prefThemeMode);

    emit(
      AppSettingsState(
        themeMode: saved == 'dark' ? ThemeMode.dark : ThemeMode.light,
        isLoading: false,
      ),
    );
  }

  Future<void> setDarkMode(bool enabled) async {
    final mode = enabled ? ThemeMode.dark : ThemeMode.light;
    emit(state.copyWith(themeMode: mode, isLoading: false));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.prefThemeMode,
      enabled ? 'dark' : 'light',
    );
  }
}
