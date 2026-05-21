import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:checkmate/core/theme/app_theme.dart';
import 'package:checkmate/core/utils/app_utils.dart';
import 'package:checkmate/domain/entities/entities.dart';
import 'package:checkmate/presentation/cubits/cubits.dart';
import 'package:checkmate/presentation/widgets/common/shared_widgets.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (ctx, state) => Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: const Text('Attendance History'),
          actions: [
            IconButton(
              icon: const Icon(Icons.ios_share_outlined),
              onPressed: () {},
            ),
          ],
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (state.stats != null) _StatsHeader(stats: state.stats!),
                  _FilterBar(
                    current: state.filterStatus,
                    onChanged: ctx.read<HistoryCubit>().setFilter,
                  ),
                  Expanded(child: _RecordList(records: state.filteredRecords)),
                ],
              ),
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  final MonthlyStatsEntity stats;
  const _StatsHeader({required this.stats});

  @override
  Widget build(BuildContext context) {
    final pct = stats.attendancePct;
    return Container(
      color: AppColors.surfaceContainerLowest,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'This Month',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '${pct.toStringAsFixed(0)}% attendance',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppUtils.attendanceColor(pct),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation(AppUtils.attendanceColor(pct)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatPill(
                label: 'Present',
                value: '${stats.present}',
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              _StatPill(
                label: 'Absent',
                value: '${stats.absent}',
                color: AppColors.error,
              ),
              const SizedBox(width: 8),
              _StatPill(
                label: 'Late',
                value: '${stats.late}',
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              _StatPill(
                label: 'Leave',
                value: '${stats.onLeave}',
                color: AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoTile(label: 'Total Hours', value: '${stats.totalHours}h'),
              _InfoTile(label: 'Avg / Day', value: '${stats.avgHours}h'),
              _InfoTile(label: 'Overtime', value: '${stats.overtimeHours}h'),
              _InfoTile(label: 'Work Days', value: '${stats.workingDays}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppColors.outline),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _InfoTile extends StatelessWidget {
  final String label, value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: AppColors.outline),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _FilterBar extends StatelessWidget {
  final String current;
  final void Function(String) onChanged;
  const _FilterBar({required this.current, required this.onChanged});

  static const _filters = [
    ('all', 'All'),
    ('checked_out', 'Present'),
    ('late', 'Late'),
    ('absent', 'Absent'),
    ('on_leave', 'Leave'),
  ];

  @override
  Widget build(BuildContext context) => Container(
    height: 50,
    color: AppColors.surfaceContainerLowest,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      children: _filters.map((f) {
        final sel = current == f.$1;
        return GestureDetector(
          onTap: () => onChanged(f.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: sel ? AppColors.primary : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: sel ? AppColors.primary : AppColors.outlineVariant,
              ),
            ),
            child: Text(
              f.$2,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: sel ? Colors.white : AppColors.onSurface,
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}

class _RecordList extends StatelessWidget {
  final List<AttendanceEntity> records;
  const _RecordList({required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty)
      return const EmptyState(
        icon: Icons.history,
        title: 'No records',
        subtitle: 'No attendance records found',
      );
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _RecordTile(record: records[i]),
    );
  }
}

class _RecordTile extends StatelessWidget {
  final AttendanceEntity record;
  const _RecordTile({required this.record});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DetailSheet(record: record),
    ),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
      ),
      child: Row(
        children: [
          _DateBlock(record: record),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      AppUtils.formatDayName(record.date),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const Spacer(),
                    StatusBadge(status: record.status, small: true),
                  ],
                ),
                const SizedBox(height: 4),
                if (record.checkIn != null)
                  Row(
                    children: [
                      _TimeChip(
                        icon: Icons.login_outlined,
                        time: AppUtils.formatTime(record.checkIn!),
                        color: AppColors.success,
                      ),
                      if (record.checkOut != null) ...[
                        const SizedBox(width: 8),
                        _TimeChip(
                          icon: Icons.logout_outlined,
                          time: AppUtils.formatTime(record.checkOut!),
                          color: AppColors.error,
                        ),
                      ],
                    ],
                  )
                else
                  Text(
                    record.status == 'on_leave'
                        ? 'On Leave'
                        : 'No check-in recorded',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.outline,
                    ),
                  ),
                if (record.workedHours > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      '${AppUtils.formatHours(record.workedHours)} • ${record.location}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.outline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.outline,
          ),
        ],
      ),
    ),
  );
}

class _DateBlock extends StatelessWidget {
  final AttendanceEntity record;
  const _DateBlock({required this.record});

  @override
  Widget build(BuildContext context) => Container(
    width: 46,
    height: 52,
    decoration: BoxDecoration(
      color: AppUtils.statusBgColor(record.status),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${record.date.day}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppUtils.statusColor(record.status),
          ),
        ),
        Text(
          AppUtils.formatShortDate(record.date).split(' ')[0],
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppUtils.statusColor(record.status),
          ),
        ),
      ],
    ),
  );
}

class _TimeChip extends StatelessWidget {
  final IconData icon;
  final String time;
  final Color color;
  const _TimeChip({
    required this.icon,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 10, color: color),
      const SizedBox(width: 3),
      Text(
        time,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    ],
  );
}

class _DetailSheet extends StatelessWidget {
  final AttendanceEntity record;
  const _DetailSheet({required this.record});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SheetHandle(),
            const Spacer(),
            StatusBadge(status: record.status),
          ],
        ),
        Text(
          AppUtils.formatDateFull(record.date),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),
        InfoRow(
          icon: Icons.login_rounded,
          label: 'Check In',
          value: record.checkIn != null
              ? AppUtils.formatTime(record.checkIn!)
              : '--',
        ),
        const Divider(),
        InfoRow(
          icon: Icons.logout_rounded,
          label: 'Check Out',
          value: record.checkOut != null
              ? AppUtils.formatTime(record.checkOut!)
              : '--',
        ),
        const Divider(),
        InfoRow(
          icon: Icons.timer_outlined,
          label: 'Total Worked',
          value: record.workedHours > 0
              ? AppUtils.formatHours(record.workedHours)
              : '--',
        ),
        const Divider(),
        InfoRow(
          icon: Icons.location_on_outlined,
          label: 'Location',
          value: record.location,
        ),
        if (record.breaks.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Breaks',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...record.breaks.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.free_breakfast_outlined,
                    size: 13,
                    color: AppColors.outline,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${b.type} · ${AppUtils.formatTime(b.startTime)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (b.endTime != null) ...[
                    Text(
                      ' → ${AppUtils.formatTime(b.endTime!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.outline,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      AppUtils.formatDuration(b.duration!),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    ),
  );
}
