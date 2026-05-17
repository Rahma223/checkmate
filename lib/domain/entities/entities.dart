import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// USER
// ─────────────────────────────────────────────────────────────
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String department;
  final String position;
  final String employeeId;
  final String avatarUrl;
  final String phone;
  final String shiftStart;  // "09:00"
  final String shiftEnd;    // "17:30"
  final String workLocation;
  final int    totalLeaves;
  final int    usedLeaves;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.position,
    required this.employeeId,
    this.avatarUrl   = '',
    this.phone       = '',
    this.shiftStart  = '09:00',
    this.shiftEnd    = '17:30',
    this.workLocation = 'HQ - Tower A',
    this.totalLeaves = 21,
    this.usedLeaves  = 5,
  });

  String get firstName {
  final parts = name.trim().split(RegExp(r'\s+'));
  return parts.isNotEmpty && parts.first.isNotEmpty ? parts.first : '';
}

String get initials {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((n) => n.isNotEmpty)
      .toList();

  if (parts.isEmpty) return '';

  return parts
      .take(2)
      .map((n) => n[0])
      .join()
      .toUpperCase();
}  int    get remainingLeaves => totalLeaves - usedLeaves;

  UserEntity copyWith({
    String? name, String? phone, String? avatarUrl,
    String? department, String? position,
    String? shiftStart, String? shiftEnd, String? workLocation,
  }) => UserEntity(
    id: id, email: email, employeeId: employeeId,
    name:         name         ?? this.name,
    phone:        phone        ?? this.phone,
    avatarUrl:    avatarUrl    ?? this.avatarUrl,
    department:   department   ?? this.department,
    position:     position     ?? this.position,
    shiftStart:   shiftStart   ?? this.shiftStart,
    shiftEnd:     shiftEnd     ?? this.shiftEnd,
    workLocation: workLocation ?? this.workLocation,
    totalLeaves: totalLeaves, usedLeaves: usedLeaves,
  );

  @override
  List<Object?> get props => [id, name, email, department, position, employeeId];
}


// ─────────────────────────────────────────────────────────────
// ATTENDANCE
// ─────────────────────────────────────────────────────────────
class BreakEntity extends Equatable {
  final DateTime  startTime;
  final DateTime? endTime;
  final String    type; // lunch | coffee | personal

  const BreakEntity({required this.startTime, this.endTime, required this.type});

  bool      get isActive => endTime == null;
  Duration? get duration => endTime != null ? endTime!.difference(startTime) : null;

  @override
  List<Object?> get props => [startTime, endTime, type];
}

class AttendanceEntity extends Equatable {
  final String         id;
  final String         userId;
  final DateTime       date;
  final DateTime?      checkIn;
  final DateTime?      checkOut;
  final String         status;
  final String         location;
  final double?        lat;
  final double?        lng;
  final String?        notes;
  final List<BreakEntity> breaks;

  const AttendanceEntity({
    required this.id,
    required this.userId,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    required this.location,
    this.lat,
    this.lng,
    this.notes,
    this.breaks = const [],
  });

  Duration get workedDuration {
    if (checkIn == null || checkOut == null) return Duration.zero;
    final total     = checkOut!.difference(checkIn!);
    final breakTime = breaks.fold<Duration>(
        Duration.zero, (s, b) => s + (b.duration ?? Duration.zero));
    return total - breakTime;
  }

  double get workedHours => workedDuration.inMinutes / 60.0;

  AttendanceEntity copyWith({
    DateTime? checkIn, DateTime? checkOut,
    String? status, List<BreakEntity>? breaks,
  }) => AttendanceEntity(
    id: id, userId: userId, date: date,
    location: location, lat: lat, lng: lng, notes: notes,
    checkIn:  checkIn  ?? this.checkIn,
    checkOut: checkOut ?? this.checkOut,
    status:   status   ?? this.status,
    breaks:   breaks   ?? this.breaks,
  );

  @override
  List<Object?> get props => [id, userId, date, status, checkIn, checkOut];
}

class MonthlyStatsEntity extends Equatable {
  final int    present;
  final int    absent;
  final int    late;
  final int    onLeave;
  final double totalHours;
  final double avgHours;
  final int    workingDays;
  final double overtimeHours;

  const MonthlyStatsEntity({
    required this.present,
    required this.absent,
    required this.late,
    required this.onLeave,
    required this.totalHours,
    required this.avgHours,
    required this.workingDays,
    required this.overtimeHours,
  });

  double get attendancePct => workingDays > 0 ? (present / workingDays) * 100 : 0;

  @override
  List<Object?> get props => [present, absent, late, onLeave, totalHours, workingDays];
}

// ─────────────────────────────────────────────────────────────
// TASK
// ─────────────────────────────────────────────────────────────
class TaskEntity extends Equatable {
  final String       id;
  final String       title;
  final String       description;
  final String       status;
  final String       priority;
  final String       assignedBy;
  final DateTime     dueDate;
  final DateTime     createdAt;
  final String?      projectName;
  final double       progress;
  final List<String> tags;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.assignedBy,
    required this.dueDate,
    required this.createdAt,
    this.projectName,
    this.progress = 0,
    this.tags = const [],
  });

  bool get isOverdue => dueDate.isBefore(DateTime.now()) && status != 'completed';

  @override
  List<Object?> get props => [id, title, status, priority];
}

// ─────────────────────────────────────────────────────────────
// SHIFT / SCHEDULE
// ─────────────────────────────────────────────────────────────
class ShiftEntity extends Equatable {
  final String   id;
  final DateTime date;
  final String   startTime;
  final String   endTime;
  final String   location;
  final String   type;        // regular | overtime | remote | off
  final String?  notes;

  const ShiftEntity({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.type,
    this.notes,
  });

  @override
  List<Object?> get props => [id, date, type];
}

// ─────────────────────────────────────────────────────────────
// LEAVE
// ─────────────────────────────────────────────────────────────
class LeaveEntity extends Equatable {
  final String   id;
  final String   userId;
  final String   type;
  final DateTime fromDate;
  final DateTime toDate;
  final String   reason;
  final String   status;       // pending | approved | rejected
  final String?  approverName;
  final String?  approverNote;
  final DateTime createdAt;

  const LeaveEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.status,
    this.approverName,
    this.approverNote,
    required this.createdAt,
  });

  int get daysCount => toDate.difference(fromDate).inDays + 1;

  @override
  List<Object?> get props => [id, userId, type, fromDate, toDate, status];
}

// ─────────────────────────────────────────────────────────────
// NOTIFICATION
// ─────────────────────────────────────────────────────────────
class NotificationEntity extends Equatable {
  final String   id;
  final String   title;
  final String   body;
  final String   type;
  final DateTime timestamp;
  final bool     isRead;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  NotificationEntity copyWith({bool? isRead}) => NotificationEntity(
    id: id, title: title, body: body, type: type, timestamp: timestamp,
    isRead: isRead ?? this.isRead,
  );

  @override
  List<Object?> get props => [id, isRead];
}

// ─────────────────────────────────────────────────────────────
// TEAM MEMBER
// ─────────────────────────────────────────────────────────────
class TeamMemberEntity extends Equatable {
  final String  id;
  final String  name;
  final String  position;
  final String  department;
  final String  avatarUrl;
  final String  status;
  final String? checkInTime;
  final String? workLocation;

  const TeamMemberEntity({
    required this.id,
    required this.name,
    required this.position,
    required this.department,
    this.avatarUrl   = '',
    required this.status,
    this.checkInTime,
    this.workLocation,
  });

  String get initials => name.split(' ').take(2).map((n) => n[0]).join().toUpperCase();

  @override
  List<Object?> get props => [id, name, status];
}
