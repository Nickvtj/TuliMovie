import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/tmdb_image_url.dart';
import '../../../auth/domain/entities/favorite_actor_entity.dart';
import '../../../auth/domain/entities/favorite_movie_entity.dart';
import '../../../movies/presentation/providers/movie_providers.dart';
import '../../domain/usecases/update_profile_use_case.dart';
import '../providers/profile_providers.dart';

enum FavoriteKind {
  movies('Top 4 filmes', 'Buscar filme...'),
  actors('Top 4 atores', 'Buscar ator ou atriz...');

  const FavoriteKind(this.title, this.searchHint);

  final String title;
  final String searchHint;
}

/// Item escolhível (filme ou ator) com o mínimo para exibir.
class _Pick {
  const _Pick({required this.id, required this.label, this.imagePath});

  final int id;
  final String label;
  final String? imagePath;
}

/// Escolhe até 4 filmes ou atores favoritos buscando no catálogo.
class EditFavoritesPage extends ConsumerStatefulWidget {
  const EditFavoritesPage.movies({
    super.key,
    required this.userId,
    required List<FavoriteMovieEntity> current,
  })  : kind = FavoriteKind.movies,
        _initialMovies = current,
        _initialActors = const [];

  const EditFavoritesPage.actors({
    super.key,
    required this.userId,
    required List<FavoriteActorEntity> current,
  })  : kind = FavoriteKind.actors,
        _initialMovies = const [],
        _initialActors = current;

  final String userId;
  final FavoriteKind kind;
  final List<FavoriteMovieEntity> _initialMovies;
  final List<FavoriteActorEntity> _initialActors;

  @override
  ConsumerState<EditFavoritesPage> createState() => _EditFavoritesPageState();
}

class _EditFavoritesPageState extends ConsumerState<EditFavoritesPage> {
  static const _debounce = Duration(milliseconds: 420);
  static const _minQuery = 2;

  late final List<_Pick> _selected = widget.kind == FavoriteKind.movies
      ? widget._initialMovies
          .map((m) => _Pick(id: m.tmdbMovieId, label: m.title, imagePath: m.posterPath))
          .toList()
      : widget._initialActors
          .map((a) => _Pick(id: a.personId, label: a.name, imagePath: a.profilePath))
          .toList();

  List<_Pick> _results = const [];
  bool _isSearching = false;
  bool _isSaving = false;
  Timer? _timer;
  String _query = '';

  bool get _isFull => _selected.length >= UpdateProfileUseCase.favoritesMax;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _query = value.trim();
    _timer?.cancel();
    _timer = Timer(_debounce, _search);
  }

  Future<void> _search() async {
    final query = _query;
    if (query.length < _minQuery) {
      setState(() => _results = const []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final repository = ref.read(movieRepositoryProvider);
      final results = widget.kind == FavoriteKind.movies
          ? (await repository.searchMovies(query: query))
              .map((m) => _Pick(id: m.id, label: m.title, imagePath: m.posterPath))
              .toList()
          : (await repository.searchPeople(query: query))
              .map((p) => _Pick(id: p.id, label: p.name, imagePath: p.profilePath))
              .toList();
      if (mounted && query == _query) setState(() => _results = results);
    } on AppException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _add(_Pick pick) {
    if (_isFull || _selected.any((p) => p.id == pick.id)) return;
    setState(() => _selected.add(pick));
  }

  void _remove(_Pick pick) => setState(() => _selected.removeWhere((p) => p.id == pick.id));

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final useCase = ref.read(updateProfileUseCaseProvider);
      if (widget.kind == FavoriteKind.movies) {
        await useCase(
          userId: widget.userId,
          favoriteMovies: [
            for (final p in _selected)
              FavoriteMovieEntity(tmdbMovieId: p.id, title: p.label, posterPath: p.imagePath),
          ],
        );
      } else {
        await useCase(
          userId: widget.userId,
          favoriteActors: [
            for (final p in _selected)
              FavoriteActorEntity(personId: p.id, name: p.label, profilePath: p.imagePath),
          ],
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _imageUrl(String? path) =>
      widget.kind == FavoriteKind.movies
          ? TmdbImageUrl.posterForWidth(path, 92)
          : TmdbImageUrl.profile(path);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TuliScreenHeader(
              mode: TuliScreenHeaderMode.stacked,
              title: widget.kind.title,
              subtitle: '${_selected.length} de ${UpdateProfileUseCase.favoritesMax} escolhidos',
            ),
            if (_selected.isNotEmpty)
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: _selected.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final pick = _selected[index];
                    return InputChip(
                      avatar: TuliAvatar(size: 24, imageUrl: _imageUrl(pick.imagePath)),
                      label: Text(pick.label),
                      onDeleted: () => _remove(pick),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: TuliInputField(
                hint: widget.kind.searchHint,
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                onChanged: _onQueryChanged,
              ),
            ),
            Expanded(child: _buildResults()),
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

  Widget _buildResults() {
    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: TuliFeedSkeleton(itemCount: 3),
      );
    }
    if (_query.length < _minQuery) {
      return TuliEmptyState(
        message: _isFull
            ? 'Seus 4 favoritos estão escolhidos.\nRemova um para trocar.'
            : 'Digite pelo menos 2 letras para buscar.',
        icon: widget.kind == FavoriteKind.movies ? Icons.movie_outlined : Icons.person_outline,
      );
    }
    if (_results.isEmpty) {
      return const TuliEmptyState(message: 'Nada encontrado.', icon: Icons.search_off_rounded);
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final pick = _results[index];
        final chosen = _selected.any((p) => p.id == pick.id);
        return TuliCard(
          padding: const EdgeInsets.all(AppSpacing.sm),
          onTap: chosen ? () => _remove(pick) : (_isFull ? null : () => _add(pick)),
          child: Row(
            children: [
              if (widget.kind == FavoriteKind.movies)
                SizedBox(
                  width: 40,
                  height: 60,
                  child: TuliPosterImage(posterPath: pick.imagePath, expand: true),
                )
              else
                TuliAvatar(size: 44, imageUrl: _imageUrl(pick.imagePath)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(pick.label, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
              Icon(
                chosen ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                color: chosen
                    ? AppColors.gold
                    : (_isFull ? AppColors.borderElevated : AppColors.textMuted),
              ),
            ],
          ),
        );
      },
    );
  }
}
