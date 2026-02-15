import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/snack_recipe.dart';
import '../models/pagination.dart';
import '../providers/providers.dart';

// ViewModelの状態
class RecipeListState {
  final List<SnackRecipe> recipes;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final Pagination? pagination;

  RecipeListState({
    this.recipes = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.pagination,
  });

  RecipeListState copyWith({
    List<SnackRecipe>? recipes,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    Pagination? pagination,
  }) {
    return RecipeListState(
      recipes: recipes ?? this.recipes,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      pagination: pagination ?? this.pagination,
    );
  }
}

// ViewModel
class RecipeListViewModel extends Notifier<RecipeListState> {
  @override
  RecipeListState build() {
    _fetchRecipes();
    return RecipeListState(isLoading: true);
  }

  Future<void> _fetchRecipes({
    String? category,
    String? difficulty,
    int page = 1,
  }) async {
    try {
      final repository = ref.read(snackRecipeRepositoryProvider);
      final response = await repository.getRecipes(
        page: page,
        limit: 10,
        category: category,
        difficulty: difficulty,
      );

      state = state.copyWith(
        recipes: response.recipes,
        pagination: response.pagination,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadRecipes({
    String? category,
    String? difficulty,
  }) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    await _fetchRecipes(category: category, difficulty: difficulty);
  }

  Future<void> loadMore({
    String? category,
    String? difficulty,
  }) async {
    if (state.isLoadingMore) return;
    if (state.pagination?.hasMore != true) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final repository = ref.read(snackRecipeRepositoryProvider);
      final nextPage = (state.pagination?.page ?? 0) + 1;
      final response = await repository.getRecipes(
        page: nextPage,
        limit: 10,
        category: category,
        difficulty: difficulty,
      );

      state = state.copyWith(
        recipes: [...state.recipes, ...response.recipes],
        pagination: response.pagination,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh({
    String? category,
    String? difficulty,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    await _fetchRecipes(category: category, difficulty: difficulty);
  }
}

// Provider
final recipeListViewModelProvider =
    NotifierProvider<RecipeListViewModel, RecipeListState>(
  RecipeListViewModel.new,
);
