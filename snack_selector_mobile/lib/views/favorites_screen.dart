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
              return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2));
            }

            if (state.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Color(0xFFB71C1C)),
                    const SizedBox(height: 16),
                    Text(
                      'エラーが発生しました',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF1C1B1F),
                          ),
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
                      size: 48,
                      color: Color(0xFFAD1457),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'お気に入りがありません',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF1C1B1F),
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Swipe画面でレシピを選んでみましょう!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF6D6A6A),
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
