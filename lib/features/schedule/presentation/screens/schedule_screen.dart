import 'package:checkmate/core/theme/app_theme.dart';
import 'package:checkmate/core/utils/app_utils.dart';
import 'package:checkmate/domain/entities/entities.dart';
import 'package:checkmate/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:checkmate/features/schedule/presentation/cubits/schedule_cubit.dart';
import 'package:checkmate/presentation/widgets/common/shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ScheduleCubit>().loadMonth(
        context.read<ScheduleCubit>().state.selectedMonth,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (ctx, state) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            title: const Text('My Schedule'),
            actions: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => ctx.read<ScheduleCubit>().loadMonth(
                  DateTime(
                    state.selectedMonth.year,
                    state.selectedMonth.month - 1,
                  ),
                ),
              ),
              Center(
                child: Text(
                  AppUtils.formatMonthYear(state.selectedMonth),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => ctx.read<ScheduleCubit>().loadMonth(
                  DateTime(
                    state.selectedMonth.year,
                    state.selectedMonth.month + 1,
                  ),
                ),
              ),
            ],
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    if (state.error != null)
                      MaterialBanner(
                        content: Text(state.error!),
                        actions: [
                          TextButton(
                            onPressed: () => ctx
                                .read<ScheduleCubit>()
                                .loadMonth(state.selectedMonth),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    CalendarHeader(state: state),
                    const Divider(height: 1),
                    Expanded(child: DayDetail(state: state)),
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showLeaveSheet(ctx),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Request Leave',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  void _showLeaveSheet(BuildContext ctx) => showModalBottomSheet(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: ctx.read<ProfileCubit>()),
        BlocProvider.value(value: ctx.read<ScheduleCubit>()),
      ],
      child: const LeaveRequestSheet(),
    ),
  );
}

class CalendarHeader extends StatelessWidget {
  final ScheduleState state;
  const CalendarHeader({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final month = state.selectedMonth;
    final first = DateTime(month.year, month.month, 1);
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final offset = first.weekday - 1;
    final today = DateTime.now();
    final cubit = context.read<ScheduleCubit>();

    return Container(
      color: AppColors.surfaceContainerLowest,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(
        children: [
          Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.05,
            ),
            itemCount: offset + days,
            itemBuilder: (_, i) {
              if (i < offset) return const SizedBox();
              final day = DateTime(month.year, month.month, i - offset + 1);
              final isToday = DateUtils.isSameDay(day, today);
              final isSel = DateUtils.isSameDay(day, state.selectedDay);
              final hasShift = state.hasShift(day);
              final hasLeave = state.hasLeave(day);
              final isWkend = day.weekday >= 6;

              return GestureDetector(
                onTap: () => cubit.selectDay(day),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSel
                        ? AppColors.primary
                        : isToday
                        ? AppColors.primaryFixed
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSel
                              ? Colors.white
                              : isToday
                              ? AppColors.primary
                              : isWkend
                              ? AppColors.outline
                              : AppColors.onSurface,
                        ),
                      ),
                      if (hasShift || hasLeave)
                        Positioned(
                          bottom: 3,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasShift)
                                Dot(
                                  color: isSel
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                              if (hasLeave) ...[
                                const SizedBox(width: 2),
                                Dot(
                                  color: isSel
                                      ? Colors.white70
                                      : AppColors.warning,
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Legend(color: AppColors.primary, label: 'Work Shift'),
              const SizedBox(width: 16),
              const Legend(color: AppColors.warning, label: 'Leave'),
              const SizedBox(width: 16),
              Legend(
                color: AppColors.primaryFixed,
                label: 'Today',
                border: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Dot extends StatelessWidget {
  final Color color;
  const Dot({super.key, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: 4,
    height: 4,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class Legend extends StatelessWidget {
  final Color color;
  final String label;
  final Color? border;
  const Legend({
    super.key,
    required this.color,
    required this.label,
    this.border,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: border != null
              ? Border.all(color: border!, width: 1.5)
              : null,
        ),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: AppColors.outline),
      ),
    ],
  );
}

class DayDetail extends StatelessWidget {
  final ScheduleState state;
  const DayDetail({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final day = state.selectedDay;
    final shifts = state.selectedDayShifts;
    final isWknd = day.weekday >= 6;
    final leaves = state.leaves
        .where((l) => !day.isBefore(l.fromDate) && !day.isAfter(l.toDate))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        Text(
          AppUtils.formatDateFull(day),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isWknd
              ? 'Weekend - day off'
              : shifts.isEmpty
              ? 'No shift scheduled'
              : '${shifts.length} shift${shifts.length > 1 ? 's' : ''}',
          style: const TextStyle(fontSize: 12, color: AppColors.outline),
        ),
        const SizedBox(height: 20),
        if (isWknd)
          const WeekendCard()
        else if (shifts.isEmpty && leaves.isEmpty)
          const EmptyState(
            icon: Icons.event_busy_outlined,
            title: 'No shift',
            subtitle: 'Nothing scheduled for this day',
          )
        else ...[
          ...shifts.map((s) => ShiftCard(shift: s)),
          ...leaves.map((l) => LeaveIndicator(leave: l)),
        ],
      ],
    );
  }
}

class WeekendCard extends StatelessWidget {
  const WeekendCard({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.successContainer.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
    ),
    child: const Row(
      children: [
        Icon(Icons.weekend_outlined, color: AppColors.success, size: 28),
        SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekend',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
            Text(
              'Enjoy your rest day!',
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ],
    ),
  );
}

class ShiftCard extends StatelessWidget {
  final ShiftEntity shift;
  const ShiftCard({super.key, required this.shift});

  @override
  Widget build(BuildContext context) {
    final tc = shift.type == 'overtime'
        ? AppColors.warning
        : shift.type == 'remote'
        ? AppColors.tertiary
        : AppColors.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tc.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  shift.type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: tc,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                shift.type == 'remote'
                    ? Icons.home_work_outlined
                    : Icons.business_outlined,
                size: 16,
                color: tc,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ShiftTime(
                icon: Icons.login_rounded,
                label: 'Start',
                value: shift.startTime,
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              ShiftTime(
                icon: Icons.logout_rounded,
                label: 'End',
                value: shift.endTime,
                align: CrossAxisAlignment.end,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.outline,
              ),
              const SizedBox(width: 5),
              Text(
                shift.location,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (shift.notes != null) ...[
            const SizedBox(height: 8),
            Text(
              shift.notes!,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.outline,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ShiftTime extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final CrossAxisAlignment align;
  const ShiftTime({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.align = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: align,
    children: [
      Row(
        children: [
          Icon(icon, size: 12, color: AppColors.outline),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.outline),
          ),
        ],
      ),
      Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurface,
        ),
      ),
    ],
  );
}

class LeaveIndicator extends StatelessWidget {
  final LeaveEntity leave;
  const LeaveIndicator({super.key, required this.leave});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: AppColors.warningContainer,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.beach_access_outlined,
          color: AppColors.warning,
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${leave.type} - ${AppUtils.leaveStatusLabel(leave.status)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                leave.reason,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class LeaveRequestSheet extends StatefulWidget {
  const LeaveRequestSheet({super.key});

  @override
  State<LeaveRequestSheet> createState() => _LeaveRequestSheetState();
}

class _LeaveRequestSheetState extends State<LeaveRequestSheet> {
  String _type = 'Annual Leave';
  DateTime _from = DateTime.now().add(const Duration(days: 1));
  DateTime _to = DateTime.now().add(const Duration(days: 1));
  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from : _to,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _from = picked;
        if (_to.isBefore(_from)) _to = _from;
      } else {
        _to = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _to.difference(_from).inDays + 1;
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (ctx, state) {
        if (state.successMessage != null) {
          final message = state.successMessage!;
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.success,
            ),
          );
          context.read<ScheduleCubit>().loadMonth(
            context.read<ScheduleCubit>().state.selectedMonth,
          );
          ctx.read<ProfileCubit>().clearMessages();
          Navigator.pop(context);
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
            ),
          );
          ctx.read<ProfileCubit>().clearMessages();
        }
      },
      builder: (ctx, state) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SheetHandle(title: 'Request Leave'),
              const SizedBox(height: 16),
              const Text(
                'Leave Type',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children:
                      [
                        'Annual Leave',
                        'Sick Leave',
                        'Personal Leave',
                        'Emergency Leave',
                        'Remote Work',
                      ].map((t) {
                        final sel = _type == t;
                        return GestureDetector(
                          onTap: () => setState(() => _type = t),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppColors.primary
                                  : AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: sel
                                    ? AppColors.primary
                                    : AppColors.outlineVariant,
                              ),
                            ),
                            child: Text(
                              t,
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
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DateButton(
                      label: 'From',
                      date: _from,
                      onTap: () => _pickDate(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DateButton(
                      label: 'To',
                      date: _to,
                      onTap: () => _pickDate(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '$days day${days > 1 ? 's' : ''} selected',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Reason',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Briefly explain your reason...',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () {
                          if (_reasonCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please provide a reason'),
                              ),
                            );
                            return;
                          }
                          ctx.read<ProfileCubit>().submitLeave(
                            type: _type,
                            fromDate: _from,
                            toDate: _to,
                            reason: _reasonCtrl.text.trim(),
                          );
                        },
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit Request'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  const DateButton({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                AppUtils.formatShortDate(date),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
