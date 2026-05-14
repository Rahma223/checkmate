import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core
import 'core/theme/app_theme.dart';

// Repositories (mock — swap with real ones when backend is ready)
import 'data/repositories/mock_repositories.dart';

// Domain contracts
import 'domain/repositories/repositories.dart';

// Cubits
import 'presentation/cubits/cubits.dart';

// Screens
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/shell_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
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
    // ── Instantiate repositories once ────────────────────────
    // To connect a real backend later, just replace MockXxxRepository()
    // with your real implementation that implements the same abstract class.
    final authRepo = MockAuthRepository();
    final attendanceRepo = MockAttendanceRepository();
    final taskRepo = MockTaskRepository();
    final scheduleRepo = MockScheduleRepository();
    final leaveRepo = MockLeaveRepository();
    final teamRepo = MockTeamRepository();
    final notifRepo = MockNotificationRepository();

    return MultiRepositoryProvider(
      // Expose repository contracts so cubits can be rebuilt with real impls
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

// ─────────────────────────────────────────────────────────────
// Root navigator — shows Login or Shell based on auth state
// ─────────────────────────────────────────────────────────────
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
        return LoginScreen(
          onSuccess: () {
            // Navigation handled reactively by BlocBuilder above
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Splash screen shown briefly on cold start
// ─────────────────────────────────────────────────────────────
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
    // Kick off auth check — cubit will emit the right state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().checkAuth();
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
      backgroundColor: AppColors.surface,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.business_center_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Checkmate',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Smart attendance management',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
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
