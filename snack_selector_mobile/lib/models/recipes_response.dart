import 'snack_recipe.dart';
import 'pagination.dart';

class RecipesResponse {
  final List<SnackRecipe> recipes;
  final Pagination pagination;

  RecipesResponse({
    required this.recipes,
    required this.pagination,
  });

  factory RecipesResponse.fromJson(Map<String, dynamic> json) {
    return RecipesResponse(
      recipes: (json['recipes'] as List<dynamic>)
          .map((e) => SnackRecipe.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipes': recipes.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}
