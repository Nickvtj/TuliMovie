import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/constants/avatar_catalog.dart';
import '../../domain/usecases/update_profile_use_case.dart';
import '../providers/profile_providers.dart';

/// Edita avatar (galeria pronta), nome e bio.
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key, required this.user});

  final UserEntity user;

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final _nameController = TextEditingController(text: widget.user.displayName);
  late final _bioController = TextEditingController(text: widget.user.bio ?? '');
  late String? _photoUrl = widget.user.photoUrl;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(updateProfileUseCaseProvider).call(
            userId: widget.user.id,
            displayName: _nameController.text,
            bio: _bioController.text,
            photoUrl: _photoUrl,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(const SnackBar(content: Text('Perfil atualizado!')));
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const TuliScreenHeader(
              mode: TuliScreenHeaderMode.stacked,
              title: 'Editar perfil',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
                children: [
                  Center(
                    child: TuliRingAvatar(
                      displayName: _nameController.text,
                      imageUrl: _photoUrl,
                      size: 96,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const TuliSectionTitle(title: 'Escolha seu avatar'),
                  const SizedBox(height: AppSpacing.sm),
                  _AvatarGrid(
                    selectedUrl: _photoUrl,
                    onSelected: (url) => setState(() => _photoUrl = url),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TuliInputField(
                    controller: _nameController,
                    label: 'Nome',
                    hint: 'Como você quer aparecer',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TuliInputField(
                    controller: _bioController,
                    label: 'Bio',
                    hint: 'Fale um pouco sobre seu gosto de cinema...',
                    maxLines: 3,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_bioController.text.trim().length}/${UpdateProfileUseCase.bioMaxLength}',
                      style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: TuliButton(
                label: 'Salvar',
                icon: Icons.check_rounded,
                expand: true,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarGrid extends StatelessWidget {
  const _AvatarGrid({required this.selectedUrl, required this.onSelected});

  final String? selectedUrl;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      children: [
        for (final url in AvatarCatalog.urls)
          GestureDetector(
            onTap: () => onSelected(url),
            child: AnimatedContainer(
              duration: AppDurations.fast,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: url == selectedUrl ? AppColors.gold : Colors.transparent,
                  width: 2.5,
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) =>
                    TuliAvatar(size: constraints.maxWidth, imageUrl: url),
              ),
            ),
          ),
      ],
    );
  }
}
