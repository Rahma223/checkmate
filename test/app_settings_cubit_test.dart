import 'package:checkmate/core/constants/app_constants.dart';
import 'package:checkmate/core/settings/app_settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads light mode by default', () async {
    final cubit = AppSettingsCubit();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.themeMode, ThemeMode.light);

    await cubit.close();
  });

  test('persists dark mode preference', () async {
    final cubit = AppSettingsCubit();
    await Future<void>.delayed(Duration.zero);

    await cubit.setDarkMode(true);
    expect(cubit.state.themeMode, ThemeMode.dark);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(AppConstants.prefThemeMode), 'dark');

    await cubit.close();
  });
}
