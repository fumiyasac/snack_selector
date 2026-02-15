import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/favorites_viewmodel.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('お気に入り'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(favoritesViewModelProvider.notifier).refresh(),
        child: Builder(
          builder: (context) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Color(0xFFFFADAD)),
                    const SizedBox(height: 16),
                    Text(
                      'エラーが発生しました',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(favoritesViewModelProvider.notifier).refresh(),
                      child: const Text('再読み込み'),
                    ),
                  ],
                ),
              );
            }

            if (state.favorites.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Color(0xFFFF8BA7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'お気に入りがありません',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Swipe画面でレシピを選んでみましょう!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF9E8E8E),
                          ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final recipe = state.favorites[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: RecipeCard(
                    recipe: recipe,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailScreen(recipe: recipe),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
