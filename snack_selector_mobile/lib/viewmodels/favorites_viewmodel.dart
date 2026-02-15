import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/snack_recipe.dart';
import '../repositories/snack_recipe_repository.dart';
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
class FavoritesViewModel extends StateNotifier<FavoritesState> {
  final SnackRecipeRepository repository;
  final String userId;

  FavoritesViewModel({
    required this.repository,
    required this.userId,
  }) : super(FavoritesState()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
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
    await loadFavorites();
  }
}

// Provider
final favoritesViewModelProvider =
    StateNotifierProvider<FavoritesViewModel, FavoritesState>((ref) {
  final repository = ref.watch(snackRecipeRepositoryProvider);
  final userId = ref.watch(userIdProvider);
  return FavoritesViewModel(repository: repository, userId: userId);
});
