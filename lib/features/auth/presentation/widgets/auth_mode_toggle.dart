import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'auth_tokens.dart';

class AuthModeToggle extends StatelessWidget {
  const AuthModeToggle({
    super.key,
    required this.isRegister,
    required this.onChanged,
  });

  final bool isRegister;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AuthTokens.toggleTrack,
        borderRadius: BorderRadius.circular(AuthTokens.toggleTrackRadius),
        border: Border.all(color: AuthTokens.inputBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PillTab(
              label: 'Entrar',
              icon: Icons.lock_outline_rounded,
              selected: !isRegister,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _PillTab(
              label: 'Cadastro',
              icon: Icons.person_add_alt_1_outlined,
              selected: isRegister,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  const _PillTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.fast,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AuthTokens.toggleTabRadius),
        color: selected ? AuthTokens.primaryYellow : Colors.transparent,
        boxShadow: selected ? AuthTokens.primaryButtonGlow : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AuthTokens.toggleTabRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: selected ? AuthTokens.background : AuthTokens.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected ? AuthTokens.background : AuthTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
