import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/utils/username_rules.dart';
import '../../../social/presentation/providers/social_providers.dart';
import '../../domain/usecases/add_comment_use_case.dart';
import '../providers/comment_providers.dart';

/// Campo de comentário com sugestões de `@` entre quem o usuário segue.
class CommentInputBar extends ConsumerStatefulWidget {
  const CommentInputBar({super.key, required this.reviewId, required this.author});

  final String reviewId;
  final UserEntity author;

  @override
  ConsumerState<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends ConsumerState<CommentInputBar> {
  static final _activeMention = RegExp('@([${UsernameRules.allowedChars}]*)\$');
  static const _maxSuggestions = 5;

  final _controller = TextEditingController();
  bool _isSending = false;

  /// Parte do @ sendo digitada logo antes do cursor; `null` se não há @ ativo.
  String? _mentionQuery;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _textBeforeCursor {
    final selection = _controller.selection;
    final end = selection.isValid ? selection.baseOffset : _controller.text.length;
    return _controller.text.substring(0, end);
  }

  void _onTextChanged() {
    final match = _activeMention.firstMatch(_textBeforeCursor);
    final query = match?.group(1)?.toLowerCase();
    if (query != _mentionQuery) setState(() => _mentionQuery = query);
  }

  void _insertMention(String username) {
    final before = _textBeforeCursor;
    final after = _controller.text.substring(before.length);
    final replaced = before.replaceFirst(_activeMention, '@$username ');
    _controller.value = TextEditingValue(
      text: '$replaced$after',
      selection: TextSelection.collapsed(offset: replaced.length),
    );
  }

  Future<void> _send() async {
    setState(() => _isSending = true);
    try {
      await ref.read(addCommentUseCaseProvider).call(
            reviewId: widget.reviewId,
            author: widget.author,
            text: _controller.text,
          );
      _controller.clear();
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  List<UserEntity> _suggestions() {
    final query = _mentionQuery;
    if (query == null) return const [];
    final following = ref.watch(followingProvider(widget.author.id)).valueOrNull ?? const [];
    return following
        .where((user) => user.hasUsername && user.username!.startsWith(query))
        .take(_maxSuggestions)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _suggestions();

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (suggestions.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final user = suggestions[index];
                  return ActionChip(
                    avatar: TuliAvatar(
                      size: 22,
                      imageUrl: user.photoUrl,
                      initials: user.initials,
                    ),
                    label: Text('@${user.username}'),
                    onPressed: () => _insertMention(user.username!),
                  );
                },
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: AddCommentUseCase.maxLength,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Comente… use @ para marcar alguém',
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Enviar',
                onPressed: _isSending ? null : _send,
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, color: AppColors.gold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
