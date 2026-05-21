import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String department;
  final String position;
  final String employeeId;
  final String avatarUrl;
  final String phone;
  final String shiftStart;
  final String shiftEnd;
  final String workLocation;
  final int totalLeaves;
  final int usedLeaves;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.position,
    required this.employeeId,
    this.avatarUrl = '',
    this.phone = '',
    this.shiftStart = '09:00',
    this.shiftEnd = '17:30',
    this.workLocation = 'HQ - Tower A',
    this.totalLeaves = 21,
    this.usedLeaves = 5,
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

    return parts.take(2).map((n) => n[0]).join().toUpperCase();
  }

  int get remainingLeaves => totalLeaves - usedLeaves;

  UserEntity copyWith({
    String? name,
    String? phone,
    String? avatarUrl,
    String? department,
    String? position,
    String? shiftStart,
    String? shiftEnd,
    String? workLocation,
  }) => UserEntity(
    id: id,
    email: email,
    employeeId: employeeId,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    department: department ?? this.department,
    position: position ?? this.position,
    shiftStart: shiftStart ?? this.shiftStart,
    shiftEnd: shiftEnd ?? this.shiftEnd,
    workLocation: workLocation ?? this.workLocation,
    totalLeaves: totalLeaves,
    usedLeaves: usedLeaves,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    department,
    position,
    employeeId,
  ];
}
