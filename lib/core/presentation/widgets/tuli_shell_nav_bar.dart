import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Barra inferior com FAB central (+) elevado — padrão app moderno.
class TuliShellNavBar extends StatelessWidget {
  const TuliShellNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onPrimaryAction,
  });

  /// Índices: 0 Feed, 1 Descubra, 2 (FAB — não selecionável), 3 Diversão, 4 Perfil.
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onPrimaryAction;

  static const primaryFabIndex = 2;

  /// Índice visual na barra (0–3, sem o FAB): Feed, Descubra, Diversão, Perfil.
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
      height: 72 + bottomPadding,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Material(
              color: AppColors.surface.withValues(alpha: 0.96),
              elevation: 12,
              shadowColor: Colors.black54,
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.borderSubtle.withValues(alpha: 0.6))),
                ),
                child: Row(
                  children: [
                    _NavSlot(
                      icon: Icons.dynamic_feed_outlined,
                      selectedIcon: Icons.dynamic_feed,
                      label: 'Feed',
                      selected: navSelected == 0,
                      onTap: () => onDestinationSelected(_navSlotToShell(0)),
                    ),
                    _NavSlot(
                      icon: Icons.public_outlined,
                      selectedIcon: Icons.public,
                      label: 'Descubra',
                      selected: navSelected == 1,
                      onTap: () => onDestinationSelected(_navSlotToShell(1)),
                    ),
                    const Expanded(child: SizedBox(width: 72)),
                    _NavSlot(
                      icon: Icons.extension_outlined,
                      selectedIcon: Icons.extension,
                      label: 'Diversão',
                      selected: navSelected == 2,
                      onTap: () => onDestinationSelected(_navSlotToShell(2)),
                    ),
                    _NavSlot(
                      icon: Icons.person_outline,
                      selectedIcon: Icons.person,
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
            bottom: 20 + bottomPadding,
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
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.gold : AppColors.textMuted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, color: color, size: 24),
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
    return Material(
      elevation: selected ? 10 : 6,
      shadowColor: AppColors.gold.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? AppColors.gold.withValues(alpha: 0.7) : AppColors.borderSubtle,
          width: selected ? 2 : 1,
        ),
      ),
      color: selected ? AppColors.gold : AppColors.surfaceElevated,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(
            Icons.add_rounded,
            size: 32,
            color: selected ? AppColors.backgroundDeep : AppColors.gold,
          ),
        ),
      ),
    );
  }
}
