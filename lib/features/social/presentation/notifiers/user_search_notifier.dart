import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/usecases/search_users_use_case.dart';

class UserSearchState {
  const UserSearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final String query;
  final List<UserEntity> results;
  final bool isLoading;
  final String? errorMessage;

  bool get hasQuery => query.trim().length >= SearchUsersUseCase.minQueryLength;

  UserSearchState copyWith({
    String? query,
    List<UserEntity>? results,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UserSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class UserSearchNotifier extends StateNotifier<UserSearchState> {
  UserSearchNotifier(this._searchUsers, {required String currentUserId})
      : _currentUserId = currentUserId,
        super(const UserSearchState());

  final SearchUsersUseCase _searchUsers;
  final String _currentUserId;
  Timer? _debounce;

  void onQueryChanged(String value) {
    state = state.copyWith(query: value, clearError: true);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 420), () => _search(value));
  }

  Future<void> _search(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.length < SearchUsersUseCase.minQueryLength) {
      state = state.copyWith(results: const [], isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await _searchUsers(query: query, currentUserId: _currentUserId);
      if (state.query.trim() != query) return;
      state = state.copyWith(results: results, isLoading: false);
    } on AppException catch (e) {
      if (state.query.trim() != query) return;
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
