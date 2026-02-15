import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../viewmodels/swipe_viewmodel.dart';
import '../widgets/swipe_card.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  final CardSwiperController _controller = CardSwiperController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(swipeViewModelProvider);
    final viewModel = ref.read(swipeViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('今日のおやつを選ぼう!'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.refresh(),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'エラーが発生しました',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.refresh(),
                    child: const Text('再読み込み'),
                  ),
                ],
              ),
            );
          }

          if (!state.hasRecipes) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    'すべてのレシピをチェックしました!',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.refresh(),
                    child: const Text('最初から'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Swipeカード
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CardSwiper(
                    controller: _controller,
                    cardsCount: state.recipes.length - state.currentIndex,
                    onSwipe: (previousIndex, currentIndex, direction) {
                      final recipe = state.recipes[state.currentIndex + previousIndex];
                      if (direction == CardSwiperDirection.right) {
                        viewModel.onSwipeRight(recipe.id);
                      } else if (direction == CardSwiperDirection.left) {
                        viewModel.onSwipeLeft(recipe.id);
                      }
                      return true;
                    },
                    cardBuilder: (context, index, horizontalOffsetPercentage,
                        verticalOffsetPercentage) {
                      final recipe = state.recipes[state.currentIndex + index];
                      return SwipeCard(recipe: recipe);
                    },
                  ),
                ),
              ),
              // 操作ボタン
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // パスボタン
                    FloatingActionButton(
                      heroTag: 'pass',
                      onPressed: () => _controller.swipe(CardSwiperDirection.left),
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.close, size: 32),
                    ),
                    // 詳細ボタン
                    FloatingActionButton(
                      heroTag: 'info',
                      onPressed: () => _showRecipeDetail(context, state.currentRecipe!),
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.info_outline, size: 28),
                    ),
                    // 好きボタン
                    FloatingActionButton(
                      heroTag: 'like',
                      onPressed: () => _controller.swipe(CardSwiperDirection.right),
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.favorite, size: 32),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  void _showRecipeDetail(BuildContext context, recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  recipe.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  '材料',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...recipe.ingredients.map<Widget>(
                  (ingredient) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text('• $ingredient'),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '作り方',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...recipe.steps.asMap().entries.map<Widget>(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key + 1}. ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Expanded(child: Text(entry.value)),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
