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

  static Color statusColor(String s) => switch (s) {
    AppConstants.statusCheckedIn  => AppColors.success,
    AppConstants.statusOnBreak    => AppColors.warning,
    AppConstants.statusCheckedOut => AppColors.primary,
    AppConstants.statusAbsent     => AppColors.error,
    AppConstants.statusLate       => AppColors.warning,
    AppConstants.statusOnLeave    => AppColors.secondary,
    _                             => AppColors.outline,
  };

  static Color statusBgColor(String s) => switch (s) {
    AppConstants.statusCheckedIn  => AppColors.successContainer,
    AppConstants.statusOnBreak    => AppColors.warningContainer,
    AppConstants.statusCheckedOut => AppColors.primaryFixed,
    AppConstants.statusAbsent     => AppColors.errorContainer,
    AppConstants.statusLate       => AppColors.warningContainer,
    AppConstants.statusOnLeave    => AppColors.secondaryContainer,
    _                             => AppColors.surfaceContainerLow,
  };

  // ── Priority ─────────────────────────────────────────────
  static Color priorityColor(String p) => switch (p) {
    AppConstants.priorityHigh   => AppColors.error,
    AppConstants.priorityMedium => AppColors.warning,
    _                           => AppColors.success,
  };

  // ── Leave Status ─────────────────────────────────────────
  static String leaveStatusLabel(String s) => switch (s) {
    'approved' => 'Approved',
    'pending'  => 'Pending',
    'rejected' => 'Rejected',
    _          => s,
  };

  static Color leaveStatusColor(String s) => switch (s) {
    'approved' => AppColors.success,
    'pending'  => AppColors.warning,
    'rejected' => AppColors.error,
    _          => AppColors.outline,
  };

  // ── Task Status ──────────────────────────────────────────
  static Color taskStatusColor(String s) => switch (s) {
    AppConstants.taskCompleted  => AppColors.success,
    AppConstants.taskInProgress => AppColors.primary,
    AppConstants.taskOverdue    => AppColors.error,
    _                           => AppColors.outline,
  };

  static String taskStatusLabel(String s) => switch (s) {
    AppConstants.taskCompleted  => 'Completed',
    AppConstants.taskInProgress => 'In Progress',
    AppConstants.taskOverdue    => 'Overdue',
    _                           => 'Pending',
  };

  // ── Attendance % ─────────────────────────────────────────
  static double attendancePct(int present, int workingDays) =>
      workingDays == 0 ? 0 : (present / workingDays) * 100;

  static Color attendanceColor(double pct) {
    if (pct >= 90) return AppColors.success;
    if (pct >= 75) return AppColors.warning;
    return AppColors.error;
  }
}
