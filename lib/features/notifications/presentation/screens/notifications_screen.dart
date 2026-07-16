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
        backgroundColor: Theme.of(context).colorScheme.surface,
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

  Color _iconColor(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final sem = SemanticColors.of(context);
    return switch (item.type) {
      'shift' => colors.primary,
      'leave' => sem.warning,
      'task' => sem.success,
      'team' => colors.secondary,
      'payroll' => colors.tertiary,
      _ => colors.outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ic = _iconColor(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        color: item.isRead
            ? Colors.transparent
            : colors.primaryContainer.withOpacity(0.15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: ic.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, size: 20, color: ic),
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
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppUtils.timeAgo(item.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
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
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
