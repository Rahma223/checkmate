import 'package:checkmate/core/network/api_client.dart';
import 'package:checkmate/core/settings/app_settings_cubit.dart';
import 'package:checkmate/core/services/geofence_service.dart';
import 'package:checkmate/core/theme/app_theme.dart';

import 'package:checkmate/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:checkmate/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:checkmate/features/profile/data/repositories/leave_repository_impl.dart';
import 'package:checkmate/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:checkmate/features/shared/data/repositories/mock_repositories.dart';

import 'package:checkmate/features/attendance/data/services/attendance_remote_data_source.dart';
import 'package:checkmate/features/auth/data/services/auth_local_data_source.dart';
import 'package:checkmate/features/auth/data/services/auth_remote_data_source.dart';
import 'package:checkmate/features/profile/data/services/leave_remote_data_source.dart';
import 'package:checkmate/features/schedule/data/services/schedule_remote_data_source.dart';

import 'package:checkmate/domain/repositories/repositories.dart';

import 'package:checkmate/presentation/cubits/cubits.dart';

import 'package:checkmate/features/auth/presentation/screens/login_screen.dart';
import 'package:checkmate/features/home/presentation/screens/shell_screen.dart';
import 'package:checkmate/presentation/screens/splash_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const CheckmateApp());
}

class CheckmateApp extends StatelessWidget {
  const CheckmateApp({super.key});

  @override
  Widget build(BuildContext context) {
    // API CLIENT
    final apiClient = ApiClient.create();

    // DATA SOURCES
    final authLocal = AuthLocalDataSource();

    final authRemote = AuthRemoteDataSource(apiClient);

    final attendanceRemote = AttendanceRemoteDataSource(apiClient);
    final leaveRemote = LeaveRemoteDataSource(apiClient);
    final scheduleRemote = ScheduleRemoteDataSource(apiClient);
    final geofenceService = GeofenceService();

    // REPOSITORIES
    final authRepo = AuthRepositoryImpl(authRemote, authLocal);

    final attendanceRepo = AttendanceRepositoryImpl(attendanceRemote);
    final leaveRepo = LeaveRepositoryImpl(leaveRemote);
    final scheduleRepo = ScheduleRepositoryImpl(scheduleRemote);

    // MOCK REPOSITORIES
    final taskRepo = MockTaskRepository();
    final teamRepo = MockTeamRepository();
    final notifRepo = MockNotificationRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => authRepo),
        RepositoryProvider<AttendanceRepository>(create: (_) => attendanceRepo),
        RepositoryProvider<GeofenceService>(create: (_) => geofenceService),
        RepositoryProvider<TaskRepository>(create: (_) => taskRepo),
        RepositoryProvider<ScheduleRepository>(create: (_) => scheduleRepo),
        RepositoryProvider<LeaveRepository>(create: (_) => leaveRepo),
        RepositoryProvider<TeamRepository>(create: (_) => teamRepo),
        RepositoryProvider<NotificationRepository>(create: (_) => notifRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          // AUTH
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(authRepo)..checkAuth(),
          ),

          // HOME
          BlocProvider<HomeCubit>(
            create: (context) => HomeCubit(
              attendanceRepo,
              taskRepo,
              notifRepo,
              context.read<AuthCubit>(),
              context.read<GeofenceService>(),
            ),
          ),

          // SCHEDULE
          BlocProvider<ScheduleCubit>(
            create: (context) =>
                ScheduleCubit(scheduleRepo, context.read<AuthCubit>()),
          ),

          // HISTORY
          BlocProvider<HistoryCubit>(
            create: (context) => HistoryCubit(
              attendanceRepo,
              context.read<AuthCubit>(),
              context.read<HomeCubit>(),
            ),
          ),

          // TASKS
          BlocProvider<TaskCubit>(create: (_) => TaskCubit(taskRepo)),

          // TEAM
          BlocProvider<TeamCubit>(create: (_) => TeamCubit(teamRepo)),

          // NOTIFICATIONS
          BlocProvider<NotificationCubit>(
            create: (_) => NotificationCubit(notifRepo),
          ),

          // PROFILE
          BlocProvider<ProfileCubit>(
            create: (context) => ProfileCubit(
              leaveRepo,
              attendanceRepo,
              context.read<AuthCubit>(),
            ),
          ),

          // SETTINGS
          BlocProvider<AppSettingsCubit>(create: (_) => AppSettingsCubit()),
        ],
        child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
          builder: (context, settings) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Checkmate',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.themeMode,
            home: const RootNavigator(),
          ),
        ),
      ),
    );
  }
}

class RootNavigator extends StatefulWidget {
  const RootNavigator({super.key});

  @override
  State<RootNavigator> createState() => _RootNavigatorState();
}

class _RootNavigatorState extends State<RootNavigator> {
  bool _initialized = false;
  bool _initStarted = false;
  late AuthCubit _authCubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initStarted) return;

    _initStarted = true;
    _authCubit = context.read<AuthCubit>();
    _initialize();
  }

  Future<void> _initialize() async {
    // Ensure splash shows for at least 5 seconds while auth check runs.
    await Future.wait([
      _authCubit.checkAuth(),
      Future.delayed(const Duration(seconds: 5)),
    ]);

    if (!mounted) return;
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const SplashScreen();
    }

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return ShellScreen(
            onLogout: () {
              context.read<AuthCubit>().logout();
            },
          );
        }

        return LoginScreen(onSuccess: () {});
      },
    );
  }
}
