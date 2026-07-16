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
          backgroundColor: Theme.of(context).colorScheme.surface,
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
            backgroundColor: Theme.of(ctx).colorScheme.primary,
            foregroundColor: Theme.of(ctx).colorScheme.onPrimary,
          ),
        );
      },
    );
  }

  void _showLeaveSheet(BuildContext ctx) => showModalBottomSheet(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: Theme.of(ctx).colorScheme.surfaceContainerLowest,
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
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
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
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.outline,
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
                        ? Theme.of(context).colorScheme.primary
                        : isToday
                        ? Theme.of(context).colorScheme.primaryContainer
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
                              ? Theme.of(context).colorScheme.onPrimary
                              : isToday
                              ? Theme.of(context).colorScheme.primary
                              : isWkend
                              ? Theme.of(context).colorScheme.outline
                              : Theme.of(context).colorScheme.onSurface,
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
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              if (hasLeave) ...[
                                const SizedBox(width: 2),
                                Dot(
                                  color: isSel
                                      ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                                      : SemanticColors.of(context).warning,
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
              Legend(color: Theme.of(context).colorScheme.primary, label: 'Work Shift'),
              const SizedBox(width: 16),
              Legend(color: SemanticColors.of(context).warning, label: 'Leave'),
              const SizedBox(width: 16),
              Legend(
                color: Theme.of(context).colorScheme.primaryContainer,
                label: 'Today',
                border: Theme.of(context).colorScheme.primary,
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
        style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isWknd
              ? 'Weekend - day off'
              : shifts.isEmpty
              ? 'No shift scheduled'
              : '${shifts.length} shift${shifts.length > 1 ? 's' : ''}',
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
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
      color: SemanticColors.of(context).successContainer.withOpacity(0.4),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: SemanticColors.of(context).success.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Icon(Icons.weekend_outlined, color: SemanticColors.of(context).success, size: 28),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekend',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: SemanticColors.of(context).success,
              ),
            ),
            Text(
              'Enjoy your rest day!',
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
    final colors = Theme.of(context).colorScheme;
    final sem = SemanticColors.of(context);
    final tc = shift.type == 'overtime'
        ? sem.warning
        : shift.type == 'remote'
        ? colors.tertiary
        : colors.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tc.withOpacity(0.1),
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
                  color: colors.outlineVariant.withOpacity(0.5),
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
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: colors.outline,
              ),
              const SizedBox(width: 5),
              Text(
                shift.location,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (shift.notes != null) ...[
            const SizedBox(height: 8),
            Text(
              shift.notes!,
              style: TextStyle(
                fontSize: 11,
                color: colors.outline,
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
          Icon(icon, size: 12, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.onSurface,
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
      color: SemanticColors.of(context).warningContainer,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: SemanticColors.of(context).warning.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Icon(
          Icons.beach_access_outlined,
          color: SemanticColors.of(context).warning,
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${leave.type} - ${AppUtils.leaveStatusLabel(leave.status)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                leave.reason,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              backgroundColor: SemanticColors.of(ctx).success,
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
              backgroundColor: Theme.of(context).colorScheme.error,
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
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: sel
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outlineVariant,
                              ),
                            ),
                            child: Text(
                              t,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: sel
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
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
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Reason',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
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
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Theme.of(context).colorScheme.onPrimary,
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
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                AppUtils.formatShortDate(date),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
