import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String assignedBy;
  final DateTime dueDate;
  final DateTime createdAt;
  final String? projectName;
  final double progress;
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

  bool get isOverdue =>
      dueDate.isBefore(DateTime.now()) && status != 'completed';

  @override
  List<Object?> get props => [id, title, status, priority];
}
