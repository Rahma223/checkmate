import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// flutter_bloc not used here
import 'package:checkmate/core/theme/app_theme.dart';
import 'package:checkmate/features/home/presentation/screens/home_screen.dart';
import 'package:checkmate/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:checkmate/features/history/presentation/screens/history_screen.dart';
import 'package:checkmate/features/profile/presentation/screens/profile_screen.dart';
import 'package:checkmate/features/notifications/presentation/screens/notifications_screen.dart';

class ShellScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const ShellScreen({super.key, required this.onLogout});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;
  bool _showNotifications = false;

  @override
  Widget build(BuildContext context) {
    if (_showNotifications) {
      return WillPopScope(
        onWillPop: () async {
          setState(() => _showNotifications = false);
          return false;
        },
        child: const NotificationsScreen(),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            onNotifications: () => setState(() => _showNotifications = true),
          ),
          const ScheduleScreen(),
          const HistoryScreen(),
          ProfileScreen(
            onLogout: widget.onLogout,
            isActive: _currentIndex == 3,
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
     final colors = Theme.of(context).colorScheme;
     return Container(
       decoration: BoxDecoration(
         color: colors.surfaceContainerLowest,
         border: Border(
           top: BorderSide(color: colors.outlineVariant, width: 0.5),
         ),
         boxShadow: [
           BoxShadow(
             color: colors.shadow.withOpacity(0.04),
             blurRadius: 12,
             offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                index: 0,
                current: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today_rounded,
                label: 'Schedule',
                index: 1,
                current: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.history_outlined,
                activeIcon: Icons.history_rounded,
                label: 'History',
                index: 2,
                current: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                index: 3,
                current: currentIndex,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final int index, current;
  final void Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap(index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: active ? 18 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: active
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? activeIcon : icon,
              size: 22,
              color: active ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
            ),
            if (active) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
