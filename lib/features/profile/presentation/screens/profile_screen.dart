import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:checkmate/core/settings/app_settings_cubit.dart';
import 'package:checkmate/core/theme/app_theme.dart';
// util helpers not used in this file
import 'package:checkmate/domain/entities/entities.dart';
import 'package:checkmate/presentation/cubits/cubits.dart';
import 'package:checkmate/presentation/widgets/common/shared_widgets.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onLogout;
  final bool isActive;
  const ProfileScreen({
    super.key,
    required this.onLogout,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return _ProfileTabs(onLogout: onLogout, isActive: isActive);
  }
}

class _ProfileTabs extends StatefulWidget {
  final VoidCallback onLogout;
  final bool isActive;
  const _ProfileTabs({required this.onLogout, required this.isActive});

  @override
  State<_ProfileTabs> createState() => _ProfileTabsState();
}

class _ProfileTabsState extends State<_ProfileTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(_handleTabChanged);
  }

  @override
  void didUpdateWidget(covariant _ProfileTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      context.read<ProfileCubit>().loadUserLeaves();
    }
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabChanged)
      ..dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 1 && widget.isActive) {
      context.read<ProfileCubit>().loadUserLeaves();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (ctx, authState) {
          final user = authState is AuthAuthenticated ? authState.user : null;
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _ProfileSliverHeader(user: user, onLogout: widget.onLogout),
            ],
            body: Column(
              children: [
                _TabBar(controller: _tabController),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      BlocBuilder<ProfileCubit, ProfileState>(
                        builder: (context, profileState) => _OverviewTab(
                          user: user,
                          stats: profileState.monthlyStats,
                          isStatsLoading: profileState.isStatsLoading,
                        ),
                      ),
                      _LeaveTab(),
                      _SettingsTab(onLogout: widget.onLogout),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileSliverHeader extends StatelessWidget {
  final UserEntity? user;
  final VoidCallback onLogout;
  const _ProfileSliverHeader({this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.surfaceContainerLowest,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 20,
          right: 20,
          bottom: 20,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => _showEditSheet(context, user),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Stack(
                  children: [
                    UserAvatar(
                      avatarUrl: user?.avatarUrl,
                      initials: user?.initials ?? 'U',
                      size: 72,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 11,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? '---',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.position ?? '---',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.badge_outlined,
                            size: 13,
                            color: AppColors.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user?.employeeId ?? '---',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.outline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _QuickStat(
                  label: 'Department',
                  value: user?.department ?? '---',
                ),
                _Vdivider(),
                _QuickStat(
                  label: 'Work Location',
                  value: user?.workLocation ?? '---',
                ),
                _Vdivider(),
                _QuickStat(
                  label: 'Shift',
                  value: user != null
                      ? '${user!.shiftStart}–${user!.shiftEnd}'
                      : '---',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _LeaveBalanceCard(user: user),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, UserEntity? user) {
    if (user == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<AuthCubit>(),
        child: _EditProfileSheet(user: user),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label, value;
  const _QuickStat({required this.label, required this.value});

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
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

class _Vdivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 30,
    color: AppColors.outlineVariant,
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );
}

class _LeaveBalanceCard extends StatelessWidget {
  final UserEntity? user;
  const _LeaveBalanceCard({this.user});

  @override
  Widget build(BuildContext context) {
    final total = user?.totalLeaves ?? 21;
    final used = user?.usedLeaves ?? 0;
    final remaining = user?.remainingLeaves ?? 21;
    final pct = total > 0 ? used / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryFixed),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.beach_access_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Leave Balance',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Text(
                '$remaining remaining',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: AppColors.primaryFixed,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Used: $used days',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                'Total: $total days',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final TabController controller;
  const _TabBar({required this.controller});

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.surfaceContainerLowest,
    child: TabBar(
      controller: controller,
      tabs: const [
        Tab(text: 'Overview'),
        Tab(text: 'Leave'),
        Tab(text: 'Settings'),
      ],
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.outline,
      labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      indicatorColor: AppColors.primary,
      indicatorWeight: 2.5,
    ),
  );
}

class _OverviewTab extends StatelessWidget {
  final UserEntity? user;
  final MonthlyStatsEntity? stats;
  final bool isStatsLoading;
  const _OverviewTab({this.user, this.stats, this.isStatsLoading = false});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      _SectionCard(
        title: 'Personal Information',
        children: [
          InfoRow(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: user?.email ?? '---',
          ),
          const Divider(),
          InfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: user?.phone ?? '---',
          ),
          const Divider(),
          InfoRow(
            icon: Icons.business_outlined,
            label: 'Department',
            value: user?.department ?? '---',
          ),
          const Divider(),
          InfoRow(
            icon: Icons.work_outline_rounded,
            label: 'Position',
            value: user?.position ?? '---',
          ),
        ],
      ),
      const SizedBox(height: 16),
      _SectionCard(
        title: 'Work Schedule',
        children: [
          InfoRow(
            icon: Icons.schedule_rounded,
            label: 'Shift Start',
            value: user?.shiftStart ?? '09:00',
          ),
          const Divider(),
          InfoRow(
            icon: Icons.schedule_outlined,
            label: 'Shift End',
            value: user?.shiftEnd ?? '17:30',
          ),
          const Divider(),
          InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: user?.workLocation ?? 'HQ - Tower A',
          ),
        ],
      ),
      const SizedBox(height: 16),
      _SectionCard(
        title: 'This Month Stats',
        children: isStatsLoading
            ? const [
                Padding(
                  padding: EdgeInsets.all(18),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ]
            : [
                _MiniStatRow(
                  label: 'Days Present',
                  value: stats != null
                      ? '${stats!.present} / ${stats!.workingDays}'
                      : '--',
                  color: AppColors.success,
                ),
                const Divider(),
                _MiniStatRow(
                  label: 'Total Worked',
                  value: stats != null
                      ? '${stats!.totalHours.toStringAsFixed(1)} hrs'
                      : '--',
                  color: AppColors.primary,
                ),
                const Divider(),
                _MiniStatRow(
                  label: 'Overtime',
                  value: stats != null
                      ? '${stats!.overtimeHours.toStringAsFixed(1)} hrs'
                      : '--',
                  color: AppColors.warning,
                ),
                const Divider(),
                _MiniStatRow(
                  label: 'Punctuality',
                  value: stats != null
                      ? '${stats!.attendancePct.toStringAsFixed(0)}%'
                      : '--',
                  color: AppColors.success,
                ),
              ],
      ),
    ],
  );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant, width: 0.5),
        ),
        child: Column(children: children),
      ),
    ],
  );
}

class _MiniStatRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniStatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    child: Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    ),
  );
}

class _LeaveTab extends StatelessWidget {
  Future<void> _refresh(BuildContext context) {
    return context.read<ProfileCubit>().loadUserLeaves();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (ctx, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.leaves.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => _refresh(ctx),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: const [
                SizedBox(height: 160),
                EmptyState(
                  icon: Icons.beach_access_outlined,
                  title: 'No leave requests',
                  subtitle: 'Your leave history will appear here',
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => _refresh(ctx),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            itemCount: state.leaves.length,
            separatorBuilder: (context, index) => const SizedBox(height: 0),
            itemBuilder: (_, i) => LeaveCard(leave: state.leaves[i]),
          ),
        );
      },
    );
  }
}

class _SettingsTab extends StatefulWidget {
  final VoidCallback onLogout;
  const _SettingsTab({required this.onLogout});

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  bool _notif = true;
  bool _biometric = false;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      _SettingsSection(
        title: 'Preferences',
        tiles: [
          _SwitchTile(
            icon: Icons.notifications_outlined,
            label: 'Push Notifications',
            sub: 'Shift reminders, leave updates',
            value: _notif,
            onChanged: (v) => setState(() => _notif = v),
          ),
          _SwitchTile(
            icon: Icons.fingerprint_rounded,
            label: 'Biometric Login',
            sub: 'Use fingerprint or Face ID',
            value: _biometric,
            onChanged: (v) => setState(() => _biometric = v),
          ),
          BlocBuilder<AppSettingsCubit, AppSettingsState>(
            builder: (context, settings) => _SwitchTile(
              icon: Icons.dark_mode_outlined,
              label: 'Dark Mode',
              sub: 'Switch to dark theme',
              value: settings.isDarkMode,
              onChanged: context.read<AppSettingsCubit>().setDarkMode,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      _SettingsSection(
        title: 'Support',
        tiles: [
          _NavTile(
            icon: Icons.help_outline_rounded,
            label: 'Help Center',
            onTap: () {},
          ),
          _NavTile(
            icon: Icons.policy_outlined,
            label: 'Privacy Policy',
            onTap: () {},
          ),
          _NavTile(
            icon: Icons.description_outlined,
            label: 'Terms of Service',
            onTap: () {},
          ),
          _NavTile(
            icon: Icons.info_outline_rounded,
            label: 'App Version 1.0.0',
            onTap: () {},
          ),
        ],
      ),
      const SizedBox(height: 24),
      OutlinedButton.icon(
        onPressed: () => _confirmLogout(context),
        icon: const Icon(Icons.logout_rounded, color: AppColors.error),
        label: const Text(
          'Sign Out',
          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
      const SizedBox(height: 60),
    ],
  );

  void _confirmLogout(BuildContext context) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Sign Out',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onLogout();
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Sign Out'),
        ),
      ],
    ),
  );
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> tiles;
  const _SettingsSection({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 0.3,
        ),
      ),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant, width: 0.5),
        ),
        child: Column(
          children: [
            for (int i = 0; i < tiles.length; i++) ...[
              tiles[i],
              if (i < tiles.length - 1) const Divider(height: 1, indent: 52),
            ],
          ],
        ),
      ),
    ],
  );
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final bool value;
  final void Function(bool) onChanged;
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                sub,
                style: const TextStyle(fontSize: 11, color: AppColors.outline),
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    ),
  );
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, size: 20, color: AppColors.primary),
    title: Text(
      label,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
    trailing: const Icon(
      Icons.chevron_right_rounded,
      size: 18,
      color: AppColors.outline,
    ),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
  );
}

class _EditProfileSheet extends StatefulWidget {
  final UserEntity user;
  const _EditProfileSheet({required this.user});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final _nameCtrl = TextEditingController(text: widget.user.name);
  late final _phoneCtrl = TextEditingController(text: widget.user.phone);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
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
        const SheetHandle(title: 'Edit Profile'),
        const SizedBox(height: 16),
        const Text(
          'Full Name',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Phone',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              context.read<AuthCubit>().updateProfile(
                widget.user.copyWith(
                  name: _nameCtrl.text,
                  phone: _phoneCtrl.text,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Save Changes'),
          ),
        ),
      ],
    ),
  );
}
