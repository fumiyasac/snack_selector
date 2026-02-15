import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/snack_recipe.dart';
import '../repositories/snack_recipe_repository.dart';
import '../providers/providers.dart';

// ViewModelの状態
class SwipeState {
  final List<SnackRecipe> recipes;
  final int currentIndex;
  final bool isLoading;
  final String? error;
  final List<int> likedRecipeIds;

  SwipeState({
    this.recipes = const [],
    this.currentIndex = 0,
    this.isLoading = false,
    this.error,
    this.likedRecipeIds = const [],
  });

  SwipeState copyWith({
    List<SnackRecipe>? recipes,
    int? currentIndex,
    bool? isLoading,
    String? error,
    List<int>? likedRecipeIds,
  }) {
    return SwipeState(
      recipes: recipes ?? this.recipes,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      likedRecipeIds: likedRecipeIds ?? this.likedRecipeIds,
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
class SwipeViewModel extends StateNotifier<SwipeState> {
  final SnackRecipeRepository repository;
  final String userId;

  SwipeViewModel({
    required this.repository,
    required this.userId,
  }) : super(SwipeState()) {
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await repository.getRecipes(limit: 20);
      state = state.copyWith(
        recipes: response.recipes,
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

  Future<void> onSwipeLeft(int recipeId) async {
    try {
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
      await repository.saveSwipe(
        recipeId: recipeId,
        userId: userId,
        liked: true,
      );
      state = state.copyWith(
        likedRecipeIds: [...state.likedRecipeIds, recipeId],
      );
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
    try {
      final currentPage = (state.recipes.length ~/ 10) + 1;
      final response = await repository.getRecipes(
        page: currentPage,
        limit: 10,
      );
      
      state = state.copyWith(
        recipes: [...state.recipes, ...response.recipes],
      );
    } catch (e) {
      // エラーは無視（次回のロードで再試行）
    }
  }

  Future<void> refresh() async {
    await loadRecipes();
  }
}

// Provider
final swipeViewModelProvider =
    StateNotifierProvider<SwipeViewModel, SwipeState>((ref) {
  final repository = ref.watch(snackRecipeRepositoryProvider);
  final userId = ref.watch(userIdProvider);
  return SwipeViewModel(repository: repository, userId: userId);
});
