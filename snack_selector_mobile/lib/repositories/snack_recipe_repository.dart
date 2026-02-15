import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/snack_recipe.dart';
import '../models/recipes_response.dart';

class SnackRecipeRepository {
  final String baseUrl;

  SnackRecipeRepository({
    this.baseUrl = 'http://localhost:3000/api',
  });

  Future<RecipesResponse> getRecipes({
    int page = 1,
    int limit = 10,
    String? category,
    String? difficulty,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (category != null) {
        queryParams['category'] = category;
      }
      if (difficulty != null) {
        queryParams['difficulty'] = difficulty;
      }

      final uri = Uri.parse('$baseUrl/recipes').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return RecipesResponse.fromJson(json);
      } else {
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load recipes: $e');
    }
  }

  Future<SnackRecipe> getRecipeById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/recipes/$id'));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return SnackRecipe.fromJson(json);
      } else {
        throw Exception('Failed to load recipe: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load recipe: $e');
    }
  }

  Future<void> saveSwipe({
    required int recipeId,
    required String userId,
    required bool liked,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/swipes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'recipeId': recipeId,
          'userId': userId,
          'liked': liked,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save swipe: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to save swipe: $e');
    }
  }

  Future<List<SnackRecipe>> getFavorites(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/favorites/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        return json.map((e) => SnackRecipe.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load favorites: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load favorites: $e');
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        return json.map((e) => e as String).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }
}
