import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/repositories/movie_repository.dart';

class MovieSearchState {
  const MovieSearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final String query;
  final List<MovieEntity> results;
  final bool isLoading;
  final String? errorMessage;

  MovieSearchState copyWith({
    String? query,
    List<MovieEntity>? results,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MovieSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class MovieSearchNotifier extends StateNotifier<MovieSearchState> {
  MovieSearchNotifier(this._repository) : super(const MovieSearchState());

  final MovieRepository _repository;
  Timer? _debounce;

  void onQueryChanged(String value) {
    state = state.copyWith(query: value, clearError: true);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 420), () => _search(value));
  }

  Future<void> _search(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.length < 2) {
      state = state.copyWith(results: const [], isLoading: false);
      return;
    }

    if (!EnvConfig.hasTmdbApiKey) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Chave TMDB ausente. Pare o app (q) e rode de novo com:\n'
            'flutter run -d chrome --dart-define=TMDB_API_KEY=sua_chave_v3',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await _repository.searchMovies(query: query);
      if (state.query.trim() != query) return;
      state = state.copyWith(results: results, isLoading: false);
    } on AppException catch (e) {
      if (state.query.trim() != query) return;
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      if (state.query.trim() != query) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro na busca. Verifique a chave TMDB.',
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
