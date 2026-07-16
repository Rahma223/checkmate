import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

class AppUtils {
  AppUtils._();

  // ── Date / Time ──────────────────────────────────────────
  static String formatDate(DateTime d)       => DateFormat('EEE, MMM d').format(d);
  static String formatDateFull(DateTime d)   => DateFormat('EEEE, MMMM d, y').format(d);
  static String formatShortDate(DateTime d)  => DateFormat('MMM d').format(d);
  static String formatMonthYear(DateTime d)  => DateFormat('MMMM yyyy').format(d);
  static String formatDayName(DateTime d)    => DateFormat('EEEE').format(d);
  static String formatTime(DateTime t)       => DateFormat('hh:mm a').format(t);
  static String formatTime24(DateTime t)     => DateFormat('HH:mm').format(t);

  static String formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  static String formatHours(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60)  return 'Just now';
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24)  return '${diff.inHours}h ago';
    if (diff.inDays    < 7)   return '${diff.inDays}d ago';
    return formatShortDate(dt);
  }

  static String getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // ── Status Helpers ───────────────────────────────────────
  static String statusLabel(String s) => switch (s) {
    AppConstants.statusCheckedIn   => 'Checked In',
    AppConstants.statusOnBreak     => 'On Break',
    AppConstants.statusCheckedOut  => 'Checked Out',
    AppConstants.statusAbsent      => 'Absent',
    AppConstants.statusLate        => 'Late',
    AppConstants.statusOnLeave     => 'On Leave',
    _                              => 'Not Checked In',
  };

  static Color statusColor(BuildContext context, String s) {
    final colors = Theme.of(context).colorScheme;
    final sem = SemanticColors.of(context);
    return switch (s) {
      AppConstants.statusCheckedIn  => sem.success,
      AppConstants.statusOnBreak    => sem.warning,
      AppConstants.statusCheckedOut => colors.primary,
      AppConstants.statusAbsent     => colors.error,
      AppConstants.statusLate       => sem.warning,
      AppConstants.statusOnLeave    => colors.secondary,
      _                             => colors.outline,
    };
  }

  static Color statusBgColor(BuildContext context, String s) {
    final colors = Theme.of(context).colorScheme;
    final sem = SemanticColors.of(context);
    return switch (s) {
      AppConstants.statusCheckedIn  => sem.successContainer,
      AppConstants.statusOnBreak    => sem.warningContainer,
      AppConstants.statusCheckedOut => colors.primaryContainer.withOpacity(0.2),
      AppConstants.statusAbsent     => colors.errorContainer,
      AppConstants.statusLate       => sem.warningContainer,
      AppConstants.statusOnLeave    => colors.secondaryContainer,
      _                             => colors.surfaceContainerLow,
    };
  }

  // ── Priority ─────────────────────────────────────────────
  static Color priorityColor(BuildContext context, String p) {
    final colors = Theme.of(context).colorScheme;
    final sem = SemanticColors.of(context);
    return switch (p) {
      AppConstants.priorityHigh   => colors.error,
      AppConstants.priorityMedium => sem.warning,
      _                           => sem.success,
    };
  }

  // ── Leave Status ─────────────────────────────────────────
  static String leaveStatusLabel(String s) => switch (s) {
    'approved' => 'Approved',
    'pending'  => 'Pending',
    'rejected' => 'Rejected',
    _          => s,
  };

  static Color leaveStatusColor(BuildContext context, String s) {
    final colors = Theme.of(context).colorScheme;
    final sem = SemanticColors.of(context);
    return switch (s) {
      'approved' => sem.success,
      'pending'  => sem.warning,
      'rejected' => colors.error,
      _          => colors.outline,
    };
  }

  // ── Task Status ──────────────────────────────────────────
  static Color taskStatusColor(BuildContext context, String s) {
    final colors = Theme.of(context).colorScheme;
    final sem = SemanticColors.of(context);
    return switch (s) {
      AppConstants.taskCompleted  => sem.success,
      AppConstants.taskInProgress => colors.primary,
      AppConstants.taskOverdue    => colors.error,
      _                           => colors.outline,
    };
  }

  static String taskStatusLabel(String s) => switch (s) {
    AppConstants.taskCompleted  => 'Completed',
    AppConstants.taskInProgress => 'In Progress',
    AppConstants.taskOverdue    => 'Overdue',
    _                           => 'Pending',
  };

  // ── Attendance % ─────────────────────────────────────────
  static double attendancePct(int present, int workingDays) =>
      workingDays == 0 ? 0 : (present / workingDays) * 100;

  static Color attendanceColor(BuildContext context, double pct) {
    final colors = Theme.of(context).colorScheme;
    final sem = SemanticColors.of(context);
    if (pct >= 90) return sem.success;
    if (pct >= 75) return sem.warning;
    return colors.error;
  }

  // ── Number formatting ───────────────────────────────────
  static String formatNumber(double value, {int decimals = 1, bool trimTrailingZeros = true}) {
    final s = value.toStringAsFixed(decimals);
    if (!trimTrailingZeros) return s;
    if (s.contains('.')) {
      return s.replaceFirst(RegExp(r"\.?0+\$"), '');
    }
    return s;
  }
}

