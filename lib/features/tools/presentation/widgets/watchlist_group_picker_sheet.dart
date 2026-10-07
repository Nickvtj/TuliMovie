import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/tuli_bottom_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/widgets/tuli_filter_chip.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../../groups/presentation/widgets/group_badge_chip.dart';

/// Escolhe em quais turmas adicionar ou remover um filme da watchlist.
class WatchlistGroupPickerSheet extends StatefulWidget {
  const WatchlistGroupPickerSheet({
    super.key,
    required this.groups,
    required this.title,
    required this.initialSelectedIds,
    this.allowMultiple = true,
    this.applyLabel = 'Confirmar',
  });

  final List<GroupEntity> groups;
  final String title;
  final Set<String> initialSelectedIds;
  final bool allowMultiple;
  final String applyLabel;

  static Future<Set<String>?> show(
    BuildContext context, {
    required List<GroupEntity> groups,
    required String title,
    Set<String> initialSelectedIds = const {},
    bool allowMultiple = true,
    String applyLabel = 'Confirmar',
  }) {
    return showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WatchlistGroupPickerSheet(
        groups: groups,
        title: title,
        initialSelectedIds: initialSelectedIds,
        allowMultiple: allowMultiple,
        applyLabel: applyLabel,
      ),
    );
  }

  @override
  State<WatchlistGroupPickerSheet> createState() => _WatchlistGroupPickerSheetState();
}

class _WatchlistGroupPickerSheetState extends State<WatchlistGroupPickerSheet> {
  late Set<String> _selected = {...widget.initialSelectedIds};

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else if (widget.allowMultiple) {
        _selected.add(id);
      } else {
        _selected = {id};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TuliBottomSheet(
      title: widget.title,
      applyLabel: widget.applyLabel,
      onCancel: () => Navigator.pop(context),
      onApply: () {
        if (_selected.isEmpty) return;
        Navigator.pop(context, _selected);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.groups.isEmpty)
            const Text('Entre ou crie uma turma em Minha turma.')
          else
            ...widget.groups.map((group) {
              final selected = _selected.contains(group.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: InkWell(
                  onTap: () => _toggle(group.id),
                  borderRadius: AppShape.borderRadiusMd,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        GroupBadgeChip(groupId: group.id, label: group.name),
                        const Spacer(),
                        if (widget.allowMultiple)
                          TuliFilterChip(
                            label: selected ? 'Selecionada' : 'Adicionar',
                            selected: selected,
                            onSelected: () => _toggle(group.id),
                          )
                        else if (selected)
                          const Icon(Icons.check_rounded, color: AppColors.gold),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
