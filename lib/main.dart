import 'package:checkmate/core/network/api_client.dart';
import 'package:checkmate/core/theme/app_theme.dart';

import 'package:checkmate/data/repositories/attendance_repository_impl.dart';
import 'package:checkmate/data/repositories/auth_repository_impl.dart';
import 'package:checkmate/data/repositories/mock_repositories.dart';

import 'package:checkmate/data/services/attendance_remote_data_source.dart';
import 'package:checkmate/data/services/auth_local_data_source.dart';
import 'package:checkmate/data/services/auth_remote_data_source.dart';

import 'package:checkmate/domain/repositories/repositories.dart';

import 'package:checkmate/presentation/cubits/cubits.dart';

import 'package:checkmate/presentation/screens/auth/login_screen.dart';
import 'package:checkmate/presentation/screens/shell_screen.dart';

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
 await AuthLocalDataSource().clearToken();
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

    // REPOSITORIES
    final authRepo = AuthRepositoryImpl(
      authRemote,
      authLocal,
    );

    final attendanceRepo = AttendanceRepositoryImpl(
      attendanceRemote,
    );

    // MOCK REPOSITORIES
    final taskRepo = MockTaskRepository();
    final scheduleRepo = MockScheduleRepository();
    final leaveRepo = MockLeaveRepository();
    final teamRepo = MockTeamRepository();
    final notifRepo = MockNotificationRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => authRepo,
        ),
        RepositoryProvider<AttendanceRepository>(
          create: (_) => attendanceRepo,
        ),
        RepositoryProvider<TaskRepository>(
          create: (_) => taskRepo,
        ),
        RepositoryProvider<ScheduleRepository>(
          create: (_) => scheduleRepo,
        ),
        RepositoryProvider<LeaveRepository>(
          create: (_) => leaveRepo,
        ),
        RepositoryProvider<TeamRepository>(
          create: (_) => teamRepo,
        ),
        RepositoryProvider<NotificationRepository>(
          create: (_) => notifRepo,
        ),
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
            ),
          ),

          // SCHEDULE
          BlocProvider<ScheduleCubit>(
            create: (_) => ScheduleCubit(
              scheduleRepo,
              leaveRepo,
            ),
          ),

          // HISTORY
          BlocProvider<HistoryCubit>(
            create: (_) => HistoryCubit(attendanceRepo),
          ),

          // TASKS
          BlocProvider<TaskCubit>(
            create: (_) => TaskCubit(taskRepo),
          ),

          // TEAM
          BlocProvider<TeamCubit>(
            create: (_) => TeamCubit(teamRepo),
          ),

          // NOTIFICATIONS
          BlocProvider<NotificationCubit>(
            create: (_) => NotificationCubit(notifRepo),
          ),

          // PROFILE
          BlocProvider<ProfileCubit>(
            create: (_) => ProfileCubit(leaveRepo),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Checkmate',
          theme: AppTheme.light,
          home: const RootNavigator(),
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

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context.read<AuthCubit>().checkAuth();

      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
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

        return LoginScreen(
          onSuccess: () {},
        );
      },
    );
  }
}
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fadeAnimation;

  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primaryContainer,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.shield_rounded,
                    size: 70,
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Checkmate',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                  CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}