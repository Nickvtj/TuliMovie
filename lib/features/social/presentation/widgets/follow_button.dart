import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/social_providers.dart';

/// Seguir / Seguindo / Seguir de volta. Oculto no próprio perfil.
class FollowButton extends ConsumerStatefulWidget {
  const FollowButton({super.key, required this.targetId});

  final String targetId;

  @override
  ConsumerState<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends ConsumerState<FollowButton> {
  bool _isBusy = false;

  Future<void> _onPressed() async {
    setState(() => _isBusy = true);
    try {
      await toggleFollow(ref, widget.targetId);
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(authSessionProvider).valueOrNull?.id;
    if (me == null || me == widget.targetId) return const SizedBox.shrink();

    final status = ref.watch(followStatusProvider(widget.targetId));
    final isFollowing = status?.isFollowing ?? false;
    final label = isFollowing
        ? 'Seguindo'
        : (status?.followsYou ?? false)
            ? 'Seguir de volta'
            : 'Seguir';

    return TuliButton(
      label: label,
      expand: true,
      icon: isFollowing ? Icons.check_rounded : Icons.person_add_alt_1_rounded,
      variant: isFollowing ? TuliButtonVariant.secondary : TuliButtonVariant.primary,
      isLoading: status == null || _isBusy,
      onPressed: status == null || _isBusy ? null : _onPressed,
    );
  }
}
