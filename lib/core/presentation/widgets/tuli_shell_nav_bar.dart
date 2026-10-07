import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'tuli_status_dot.dart';

/// Barra inferior com FAB central (+) elevado — padrão app moderno.
class TuliShellNavBar extends StatelessWidget {
  const TuliShellNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onPrimaryAction,
    this.showFeedNotificationBadge = true,
  });

  /// Índices: 0 Feed, 1 Descubra, 2 (FAB — não selecionável), 3 Diversão, 4 Perfil.
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onPrimaryAction;
  final bool showFeedNotificationBadge;

  static const primaryFabIndex = 2;

  int _navSlotToShell(int navSlot) {
    if (navSlot <= 1) return navSlot;
    return navSlot + 1;
  }

  int _shellToNavSlot(int shellIndex) {
    if (shellIndex < primaryFabIndex) return shellIndex;
    if (shellIndex == primaryFabIndex) return -1;
    return shellIndex - 1;
  }

  @override
  Widget build(BuildContext context) {
    final navSelected = _shellToNavSlot(selectedIndex);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: 76 + bottomPadding,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Material(
              color: AppColors.surface.withValues(alpha: 0.98),
              elevation: 12,
              shadowColor: Colors.black54,
              child: Container(
                height: 76,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.borderSubtle.withValues(alpha: 0.8)),
                  ),
                ),
                child: Row(
                  children: [
                    _NavSlot(
                      icon: Icons.theaters_outlined,
                      selectedIcon: Icons.theaters_rounded,
                      label: 'Feed',
                      selected: navSelected == 0,
                      showBadge: showFeedNotificationBadge,
                      onTap: () => onDestinationSelected(_navSlotToShell(0)),
                    ),
                    _NavSlot(
                      icon: Icons.explore_outlined,
                      selectedIcon: Icons.explore_rounded,
                      label: 'Descubra',
                      selected: navSelected == 1,
                      onTap: () => onDestinationSelected(_navSlotToShell(1)),
                    ),
                    const Expanded(child: SizedBox(width: 72)),
                    _NavSlot(
                      icon: Icons.casino_outlined,
                      selectedIcon: Icons.casino_rounded,
                      label: 'Dinâmicas',
                      selected: navSelected == 2,
                      onTap: () => onDestinationSelected(_navSlotToShell(2)),
                    ),
                    _NavSlot(
                      icon: Icons.account_circle_outlined,
                      selectedIcon: Icons.account_circle_rounded,
                      label: 'Perfil',
                      selected: navSelected == 3,
                      onTap: () => onDestinationSelected(_navSlotToShell(3)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 22 + bottomPadding,
            child: _PrimaryFab(onPressed: onPrimaryAction, selected: selectedIndex == primaryFabIndex),
          ),
        ],
      ),
    );
  }
}

class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.showBadge = false,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.gold : AppColors.textMuted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(selected ? selectedIcon : icon, color: color, size: 24),
                if (showBadge)
                  const Positioned(
                    top: -2,
                    right: -4,
                    child: TuliStatusDot(size: 7),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryFab extends StatelessWidget {
  const _PrimaryFab({required this.onPressed, required this.selected});

  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: selected ? 0.55 : 0.35),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        elevation: 0,
        shape: CircleBorder(
          side: BorderSide(
            color: AppColors.gold,
            width: selected ? 2.5 : 1.5,
          ),
        ),
        color: selected ? AppColors.gold : AppColors.surfaceElevated,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 58,
            height: 58,
            child: Icon(
              Icons.add_rounded,
              size: 32,
              color: selected ? AppColors.backgroundDeep : AppColors.gold,
            ),
          ),
        ),
      ),
    );
  }
}
