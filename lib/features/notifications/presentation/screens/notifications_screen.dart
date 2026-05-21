import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:checkmate/core/theme/app_theme.dart';
import 'package:checkmate/core/utils/app_utils.dart';
import 'package:checkmate/presentation/cubits/cubits.dart';
import 'package:checkmate/presentation/widgets/common/shared_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (ctx, state) => Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: [
            if (state.unreadCount > 0)
              TextButton(
                onPressed: ctx.read<NotificationCubit>().markAllRead,
                child: const Text(
                  'Mark all read',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.items.isEmpty
            ? const EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No notifications',
                subtitle: 'You\'re all caught up!',
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.items.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 70),
                itemBuilder: (_, i) {
                  final n = state.items[i];
                  return _NotifTile(
                    item: n,
                    onTap: () => ctx.read<NotificationCubit>().markRead(n.id),
                  );
                },
              ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;
  const _NotifTile({required this.item, required this.onTap});

  IconData get _icon => switch (item.type) {
    'shift' => Icons.schedule_rounded,
    'leave' => Icons.beach_access_outlined,
    'task' => Icons.task_alt_rounded,
    'team' => Icons.group_outlined,
    'payroll' => Icons.payments_outlined,
    _ => Icons.notifications_outlined,
  };

  Color get _iconColor => switch (item.type) {
    'shift' => AppColors.primary,
    'leave' => AppColors.warning,
    'task' => AppColors.success,
    'team' => AppColors.secondary,
    'payroll' => AppColors.tertiary,
    _ => AppColors.outline,
  };

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      color: item.isRead
          ? Colors.transparent
          : AppColors.primaryFixed.withOpacity(0.15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, size: 20, color: _iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: item.isRead
                              ? FontWeight.w500
                              : FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppUtils.timeAgo(item.timestamp),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.body,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!item.isRead)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(left: 8, top: 4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    ),
  );
}
