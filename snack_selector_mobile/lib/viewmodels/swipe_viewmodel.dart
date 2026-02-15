import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/snack_recipe.dart';
import '../models/pagination.dart';
import '../providers/providers.dart';
import 'favorites_viewmodel.dart';

// ViewModelの状態
class SwipeState {
  final List<SnackRecipe> recipes;
  final int currentIndex;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final List<int> likedRecipeIds;
  final Pagination? pagination;

  SwipeState({
    this.recipes = const [],
    this.currentIndex = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.likedRecipeIds = const [],
    this.pagination,
  });

  SwipeState copyWith({
    List<SnackRecipe>? recipes,
    int? currentIndex,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    List<int>? likedRecipeIds,
    Pagination? pagination,
  }) {
    return SwipeState(
      recipes: recipes ?? this.recipes,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      likedRecipeIds: likedRecipeIds ?? this.likedRecipeIds,
      pagination: pagination ?? this.pagination,
    );
  }

  SnackRecipe? get currentRecipe {
    if (currentIndex < recipes.length) {
      return recipes[currentIndex];
    }
    return null;
  }

  bool get hasRecipes => recipes.isNotEmpty && currentIndex < recipes.length;
}

// ViewModel
class SwipeViewModel extends Notifier<SwipeState> {
  @override
  SwipeState build() {
    _fetchRecipes();
    return SwipeState(isLoading: true);
  }

  Future<void> _fetchRecipes() async {
    try {
      final repository = ref.read(snackRecipeRepositoryProvider);
      final response = await repository.getRecipes(limit: 20);
      state = state.copyWith(
        recipes: response.recipes,
        pagination: response.pagination,
        currentIndex: 0,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadRecipes() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    await _fetchRecipes();
  }

  Future<void> onSwipeLeft(int recipeId) async {
    try {
      final repository = ref.read(snackRecipeRepositoryProvider);
      final userId = ref.read(userIdProvider);
      await repository.saveSwipe(
        recipeId: recipeId,
        userId: userId,
        liked: false,
      );
      _moveToNext();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> onSwipeRight(int recipeId) async {
    try {
      final repository = ref.read(snackRecipeRepositoryProvider);
      final userId = ref.read(userIdProvider);
      await repository.saveSwipe(
        recipeId: recipeId,
        userId: userId,
        liked: true,
      );
      state = state.copyWith(
        likedRecipeIds: [...state.likedRecipeIds, recipeId],
      );
      ref.invalidate(favoritesViewModelProvider);
      _moveToNext();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void _moveToNext() {
    final nextIndex = state.currentIndex + 1;

    // 残りのカードが少なくなったら追加でロード
    if (nextIndex >= state.recipes.length - 3) {
      _loadMoreRecipes();
    }

    state = state.copyWith(currentIndex: nextIndex);
  }

  Future<void> _loadMoreRecipes() async {
    if (state.isLoadingMore) return;
    if (state.pagination?.hasMore != true) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final repository = ref.read(snackRecipeRepositoryProvider);
      final nextPage = (state.pagination?.page ?? 0) + 1;
      final response = await repository.getRecipes(
        page: nextPage,
        limit: 10,
      );

      state = state.copyWith(
        recipes: [...state.recipes, ...response.recipes],
        pagination: response.pagination,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() async {
    await loadRecipes();
  }
}

// Provider
final swipeViewModelProvider =
    NotifierProvider<SwipeViewModel, SwipeState>(
  SwipeViewModel.new,
);
