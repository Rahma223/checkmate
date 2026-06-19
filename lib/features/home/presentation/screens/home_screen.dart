import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:checkmate/core/theme/app_theme.dart';
import 'package:checkmate/core/utils/app_utils.dart';
import 'package:checkmate/domain/entities/entities.dart';
import 'package:checkmate/presentation/cubits/cubits.dart';
import 'package:checkmate/presentation/widgets/common/shared_widgets.dart';
import 'map_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onNotifications;

  const HomeScreen({super.key, required this.onNotifications});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (ctx, state) {
        if (state.error != null && state.error!.isNotEmpty) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
            ),
          );
          ctx.read<HomeCubit>().clearError();
        }
      },
      builder: (ctx, state) {
        final user = ctx.read<AuthCubit>().currentUser;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: _buildAppBar(ctx, user, state),
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => ctx.read<HomeCubit>().load(),
            child: state.isLoading
                ? const _HomeShimmer()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    children: [
                      if (state.isSyncing) ...[
                        const _SyncBanner(),
                        const SizedBox(height: 14),
                      ],
                      _GreetingSection(user: user),
                      const SizedBox(height: 20),
                      _MapPreviewCard(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MapDetailScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _StatusCard(state: state),
                      const SizedBox(height: 14),
                      if (state.isCheckedIn && state.actionInProgress.isEmpty)
                        _QuickBreakRow(cubit: ctx.read<HomeCubit>()),
                      const SizedBox(height: 20),
                      SectionHeader(
                        title: "Today's Summary",
                        actionLabel: 'Schedule',
                      ),
                      const SizedBox(height: 12),
                      _TodaySummaryGrid(state: state),
                      const SizedBox(height: 24),
                      SectionHeader(title: 'My Tasks', actionLabel: 'View All'),
                      const SizedBox(height: 12),
                      _TasksPreview(tasks: state.tasks.take(4).toList()),
                    ],
                  ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext ctx,
    UserEntity? user,
    HomeState state,
  ) {
    return AppBar(
      titleSpacing: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Icon(
          Icons.grid_view_rounded,
          color: AppColors.primary,
          size: 24,
        ),
      ),
      title: const Text(
        'Checkmate',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        NotifBadgeIcon(
          count: state.unreadNotifications,
          onTap: onNotifications,
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: UserAvatar(
            avatarUrl: user?.avatarUrl,
            initials: user?.initials ?? 'U',
            size: 34,
          ),
        ),
      ],
    );
  }
}

class _SyncBanner extends StatelessWidget {
  const _SyncBanner();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.tertiaryFixed,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.tertiaryContainer.withOpacity(0.3)),
    ),
    child: const Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.tertiary,
          ),
        ),
        SizedBox(width: 10),
        Text(
          'Syncing data...',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.onTertiaryFixedVariant,
          ),
        ),
      ],
    ),
  );
}

class _GreetingSection extends StatelessWidget {
  final UserEntity? user;
  const _GreetingSection({this.user});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '${AppUtils.getGreeting()}, ${user?.firstName ?? 'there'} 👋',
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurface,
          letterSpacing: -0.4,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        '${AppUtils.formatTime(DateTime.now())} • ${AppUtils.formatDate(DateTime.now())}',
        style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
      ),
    ],
  );
}

class _MapPreviewCard extends StatelessWidget {
  final VoidCallback onTap;
  const _MapPreviewCard({required this.onTap});

  @override
  Widget build(BuildContext context) => BlocBuilder<HomeCubit, HomeState>(
    builder: (ctx, state) => GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant, width: 0.5),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: AppColors.surfaceContainerHigh,
                child: Center(
                  child: Icon(
                    Icons.map_rounded,
                    size: 56,
                    color: AppColors.outlineVariant,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14),
                    const SizedBox(width: 8),
                    Text(
                      state.todayRecord?.location ?? 'Inside Workspace',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'View Map',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _StatusCard extends StatefulWidget {
  final HomeState state;
  const _StatusCard({required this.state});

  @override
  State<_StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends State<_StatusCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final isIn = s.isCheckedIn;
    final isOut = s.isCheckedOut;
    final isBrk = s.isOnBreak;
    final busy = s.actionInProgress.isNotEmpty;
    final checkOut = s.todayRecord?.checkOut;
    final statusColor = AppUtils.statusColor(s.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURRENT STATUS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.outline,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 3),
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, __) => Text(
                      AppUtils.statusLabel(s.status),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                        shadows: isIn
                            ? [
                                Shadow(
                                  color: statusColor.withOpacity(
                                    0.3 * _pulse.value,
                                  ),
                                  blurRadius: 8,
                                ),
                              ]
                            : [],
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _GeofencePill(inside: s.isInsideGeofence),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: AppColors.outlineVariant.withOpacity(0.4),
                ),
              ),
            ),
            child: Row(
              children: [
                _TimeCol(
                  label: 'Check In',
                  value: s.todayRecord?.checkIn != null
                      ? AppUtils.formatTime(s.todayRecord!.checkIn!)
                      : '09:00 AM',
                  active: s.todayRecord?.checkIn != null,
                ),
                _vLine(),

                _TimeCol(
                  label: 'Check Out',
                  value: checkOut != null
                      ? AppUtils.formatTime(checkOut)
                      : '05:30 PM',
                  active: checkOut != null,
                ),
                _vLine(),
                _TimeCol(
                  label: 'Location',
                  value: s.todayRecord?.location ?? 'HQ - Tower A',
                  active: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          if (!isOut)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: busy ? null : () => _handleAction(context, s),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBrk
                      ? AppColors.warning
                      : isIn
                      ? AppColors.success
                      : AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                ),
                child: busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isBrk
                                ? Icons.play_arrow_rounded
                                : isIn
                                ? Icons.logout_rounded
                                : Icons.login_rounded,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isBrk
                                ? 'End Break'
                                : isIn
                                ? 'Check Out'
                                : 'Check In',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

          if (isOut && s.todayRecord != null)
            _CheckedOutSummary(record: s.todayRecord!),
        ],
      ),
    );
  }

  Widget _vLine() => Container(
    width: 1,
    height: 40,
    color: AppColors.outlineVariant.withOpacity(0.4),
  );

  Future<void> _handleAction(BuildContext context, HomeState s) async {
    HapticFeedback.mediumImpact();
    final cubit = context.read<HomeCubit>();
    if (s.isOnBreak) {
      await cubit.endBreak();
    } else if (s.isCheckedIn) {
      _showCheckOutSheet(context, cubit, s);
    } else {
      await cubit.checkIn();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checked in successfully! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _showCheckOutSheet(BuildContext context, HomeCubit cubit, HomeState s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHandle(title: 'Check Out'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryChip(
                    label: 'Worked',
                    value: AppUtils.formatHours(
                      s.todayRecord?.workedHours ?? 0,
                    ),
                  ),
                  _SummaryChip(
                    label: 'Breaks',
                    value: '${s.todayRecord?.breaks.length ?? 0}',
                  ),
                  _SummaryChip(
                    label: 'Location',
                    value: s.todayRecord?.location ?? 'HQ',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await cubit.checkOut();
                    },
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
      Text(
        label,
        style: const TextStyle(fontSize: 10, color: AppColors.outline),
      ),
    ],
  );
}

class _GeofencePill extends StatelessWidget {
  final bool inside;
  const _GeofencePill({required this.inside});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: inside ? AppColors.successContainer : AppColors.errorContainer,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: inside
            ? AppColors.success.withOpacity(0.3)
            : AppColors.error.withOpacity(0.3),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: inside ? AppColors.success : AppColors.error,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          inside ? 'In Geofence' : 'Out of Range',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: inside ? AppColors.success : AppColors.error,
          ),
        ),
      ],
    ),
  );
}

class _TimeCol extends StatelessWidget {
  final String label;
  final String value;
  final bool active;
  const _TimeCol({
    required this.label,
    required this.value,
    required this.active,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.outline,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? AppColors.primary : AppColors.onSurface,
          ),
        ),
      ],
    ),
  );
}

class _CheckedOutSummary extends StatelessWidget {
  final AttendanceEntity record;

  const _CheckedOutSummary({required this.record});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.primaryFixed.withOpacity(0.3),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _SummaryChip(
          label: 'Check In',
          value: AppUtils.formatTime(record.checkIn!),
        ),
        _SummaryChip(
          label: 'Check Out',
          value: record.checkOut != null
              ? AppUtils.formatTime(record.checkOut!)
              : '--:--',
        ),
        _SummaryChip(
          label: 'Total',
          value: AppUtils.formatHours(record.workedHours),
        ),
      ],
    ),
  );
}

class _QuickBreakRow extends StatelessWidget {
  final HomeCubit cubit;
  const _QuickBreakRow({required this.cubit});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Expanded(
          child: _BreakBtn(
            icon: Icons.free_breakfast_outlined,
            label: 'Coffee',
            color: AppColors.warning,
            onTap: () => cubit.startBreak('coffee'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _BreakBtn(
            icon: Icons.restaurant_outlined,
            label: 'Lunch',
            color: AppColors.tertiary,
            onTap: () => cubit.startBreak('lunch'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _BreakBtn(
            icon: Icons.person_outlined,
            label: 'Personal',
            color: AppColors.secondary,
            onTap: () => cubit.startBreak('personal'),
          ),
        ),
      ],
    ),
  );
}

class _BreakBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _BreakBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}

class _TodaySummaryGrid extends StatelessWidget {
  final HomeState state;
  const _TodaySummaryGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final record = state.todayRecord;
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        StatCard(
          icon: Icons.schedule_rounded,
          iconColor: AppColors.primary,
          label: 'Worked Today',
          value: record != null
              ? AppUtils.formatHours(record.workedHours)
              : '--',
          sub: 'of 8.5h shift',
        ),
        StatCard(
          icon: Icons.task_alt_rounded,
          iconColor: AppColors.success,
          label: 'Tasks',
          value: '${state.tasks.length}',
          sub:
              '${state.tasks.where((t) => t.status == 'pending').length} pending',
        ),
        StatCard(
          icon: Icons.free_breakfast_outlined,
          iconColor: AppColors.warning,
          label: 'Break Time',
          value: record != null
              ? AppUtils.formatDuration(record.breakDuration)
              : '--',
          sub: '${record?.breaks.length ?? 0} break(s)',
        ),
        StatCard(
          icon: Icons.event_available_rounded,
          iconColor: AppColors.tertiary,
          label: 'Attendance',
          value: state.monthlyStats != null
              ? '${state.monthlyStats!.attendancePct.toStringAsFixed(0)}%'
              : '--',
          sub: 'This month',
        ),
      ],
    );
  }
}

class _TasksPreview extends StatelessWidget {
  final List<TaskEntity> tasks;
  const _TasksPreview({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const EmptyState(
        icon: Icons.task_outlined,
        title: 'No tasks',
        subtitle: 'You\'re all caught up!',
      );
    }
    return Column(children: tasks.map((t) => _TaskTile(task: t)).toList());
  }
}

class _TaskTile extends StatelessWidget {
  final TaskEntity task;
  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.outlineVariant, width: 0.5),
    ),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 42,
          decoration: BoxDecoration(
            color: AppUtils.priorityColor(task.priority),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                task.projectName ?? task.assignedBy,
                style: const TextStyle(fontSize: 11, color: AppColors.outline),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            PriorityChip(priority: task.priority),
            const SizedBox(height: 4),
            Text(
              AppUtils.timeAgo(task.dueDate),
              style: TextStyle(
                fontSize: 10,
                color: task.isOverdue ? AppColors.error : AppColors.outline,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _HomeShimmer extends StatelessWidget {
  const _HomeShimmer();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerBox(height: 26, width: 220),
        const SizedBox(height: 8),
        const ShimmerBox(height: 14, width: 160),
        const SizedBox(height: 24),
        const ShimmerBox(height: 200),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(child: ShimmerBox(height: 95)),
            SizedBox(width: 12),
            Expanded(child: ShimmerBox(height: 95)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(child: ShimmerBox(height: 95)),
            SizedBox(width: 12),
            Expanded(child: ShimmerBox(height: 95)),
          ],
        ),
      ],
    ),
  );
}
