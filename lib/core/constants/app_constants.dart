class AppConstants {
  AppConstants._();

  // ── App ──────────────────────────────────────────────────
  static const appName = 'Checkmate';
  static const appVersion = '1.0.0';

  // ── Shared Prefs Keys ────────────────────────────────────
  static const prefToken = 'auth_token';
  static const prefUserId = 'user_id';
  static const prefThemeMode = 'theme_mode';
  static const prefBiometric = 'biometric_enabled';
  static const prefNotif = 'notifications_enabled';

  // ── Route Names ──────────────────────────────────────────
  static const routeSplash = '/';
  static const routeLogin = '/login';
  static const routeShell = '/shell';
  static const routeHome = '/home';
  static const routeSchedule = '/schedule';
  static const routeHistory = '/history';
  static const routeProfile = '/profile';
  static const routeNotifications = '/notifications';
  static const routeTasks = '/tasks';
  static const routeTeam = '/team';
  static const routeLeaveRequest = '/leave-request';
  static const routeSettings = '/settings';

  // ── Attendance Status ────────────────────────────────────
  static const statusNotCheckedIn = 'not_checked_in';
  static const statusCheckedIn = 'checked_in';
  static const statusOnBreak = 'on_break';
  static const statusCheckedOut = 'checked_out';
  static const statusAbsent = 'absent';
  static const statusLate = 'late';
  static const statusOnLeave = 'on_leave';

  // ── Leave Types ──────────────────────────────────────────
  static const leaveTypes = [
    'Annual Leave',
    'Sick Leave',
    'Personal Leave',
    'Emergency Leave',
    'Remote Work',
  ];

  // ── Task Status ──────────────────────────────────────────
  static const taskPending = 'pending';
  static const taskInProgress = 'in_progress';
  static const taskCompleted = 'completed';
  static const taskOverdue = 'overdue';

  // ── Task Priority ────────────────────────────────────────
  static const priorityHigh = 'high';
  static const priorityMedium = 'medium';
  static const priorityLow = 'low';
}
