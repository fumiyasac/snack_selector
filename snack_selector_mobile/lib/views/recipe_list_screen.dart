import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/recipe_list_viewmodel.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class RecipeListScreen extends ConsumerStatefulWidget {
  const RecipeListScreen({super.key});

  @override
  ConsumerState<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends ConsumerState<RecipeListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      // 90%スクロールしたら次のページをロード
      ref.read(recipeListViewModelProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recipeListViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('おやつレシピ一覧'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(recipeListViewModelProvider.notifier).refresh(),
        child: Builder(
          builder: (context) {
            if (state.isLoading && state.recipes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null && state.recipes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Color(0xFFB71C1C)),
                    const SizedBox(height: 16),
                    Text(
                      'エラーが発生しました',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.error!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(recipeListViewModelProvider.notifier).refresh(),
                      child: const Text('再読み込み'),
                    ),
                  ],
                ),
              );
            }

            if (state.recipes.isEmpty) {
              return const Center(
                child: Text('レシピがありません'),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.recipes.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.recipes.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final recipe = state.recipes[index];
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
