import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../repositories/snack_recipe_repository.dart';

// Repository Provider
final snackRecipeRepositoryProvider = Provider<SnackRecipeRepository>((ref) {
  return SnackRecipeRepository();
});

// User ID Provider (アプリ起動時に生成される一意のID)
final userIdProvider = Provider<String>((ref) {
  return const Uuid().v4();
});
