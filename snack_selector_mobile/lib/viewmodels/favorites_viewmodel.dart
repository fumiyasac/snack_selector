import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/snack_recipe.dart';
import '../providers/providers.dart';

// ViewModelの状態
class FavoritesState {
  final List<SnackRecipe> favorites;
  final bool isLoading;
  final String? error;

  FavoritesState({
    this.favorites = const [],
    this.isLoading = false,
    this.error,
  });

  FavoritesState copyWith({
    List<SnackRecipe>? favorites,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ViewModel
class FavoritesViewModel extends Notifier<FavoritesState> {
  @override
  FavoritesState build() {
    _fetchFavorites();
    return FavoritesState(isLoading: true);
  }

  Future<void> _fetchFavorites() async {
    try {
      final repository = ref.read(snackRecipeRepositoryProvider);
      final userId = ref.read(userIdProvider);
      final favorites = await repository.getFavorites(userId);
      state = state.copyWith(
        favorites: favorites,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    await _fetchFavorites();
  }
}

// Provider
final favoritesViewModelProvider =
    NotifierProvider<FavoritesViewModel, FavoritesState>(
  FavoritesViewModel.new,
);
