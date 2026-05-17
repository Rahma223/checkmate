import 'package:checkmate/core/network/api_client.dart';
import 'package:checkmate/data/repositories/auth_repository_impl.dart';
import 'package:checkmate/data/services/auth_local_data_source.dart';
import 'package:checkmate/data/services/auth_remote_data_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';

import 'data/repositories/mock_repositories.dart';

import 'domain/repositories/repositories.dart';

import 'presentation/cubits/cubits.dart';

import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/shell_screen.dart';

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
    final authRepo = AuthRepositoryImpl(
  AuthRemoteDataSource(
    ApiClient.create(),
  ),
  AuthLocalDataSource(),
);
    final attendanceRepo = MockAttendanceRepository();
    final taskRepo = MockTaskRepository();
    final scheduleRepo = MockScheduleRepository();
    final leaveRepo = MockLeaveRepository();
    final teamRepo = MockTeamRepository();
    final notifRepo = MockNotificationRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => authRepo),
        RepositoryProvider<AttendanceRepository>(create: (_) => attendanceRepo),
        RepositoryProvider<TaskRepository>(create: (_) => taskRepo),
        RepositoryProvider<ScheduleRepository>(create: (_) => scheduleRepo),
        RepositoryProvider<LeaveRepository>(create: (_) => leaveRepo),
        RepositoryProvider<TeamRepository>(create: (_) => teamRepo),
        RepositoryProvider<NotificationRepository>(create: (_) => notifRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(create: (_) => AuthCubit(authRepo)),
          BlocProvider<HomeCubit>(
            create: (_) => HomeCubit(attendanceRepo, taskRepo, notifRepo),
          ),
          BlocProvider<ScheduleCubit>(
            create: (_) => ScheduleCubit(scheduleRepo, leaveRepo),
          ),
          BlocProvider<HistoryCubit>(
            create: (_) => HistoryCubit(attendanceRepo),
          ),
          BlocProvider<TaskCubit>(create: (_) => TaskCubit(taskRepo)),
          BlocProvider<TeamCubit>(create: (_) => TeamCubit(teamRepo)),
          BlocProvider<NotificationCubit>(
            create: (_) => NotificationCubit(notifRepo),
          ),
          BlocProvider<ProfileCubit>(create: (_) => ProfileCubit(leaveRepo)),
        ],
        child: MaterialApp(
          title: 'Checkmate',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const _RootNavigator(),
        ),
      ),
    );
  }
}

class _RootNavigator extends StatelessWidget {
  const _RootNavigator();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (ctx, state) {
        if (state is AuthInitial) {
          return const _SplashScreen();
        }
        if (state is AuthAuthenticated) {
          return ShellScreen(onLogout: () => ctx.read<AuthCubit>().logout());
        }
        // AuthUnauthenticated, AuthError
        return LoginScreen(onSuccess: () {});
      },
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeOut,
  );

  late final Animation<double> _scale = Tween<double>(
    begin: 0.8,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

  @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {

    Future.delayed(
      const Duration(seconds: 2),
      () {
        if (mounted) {
          context.read<AuthCubit>().checkAuth();
        }
      },
    );
  });
}

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryContainer],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.onPrimary, AppColors.primary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.28),
                                blurRadius: 22,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            color: AppColors.onPrimary,
                            size: 44,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Checkmate',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Workforce attendance, simplified.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 36),
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(
                              AppColors.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Text(
                  'Built for modern HR teams',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onPrimary,
                    letterSpacing: 0.15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
