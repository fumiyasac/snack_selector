import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/snack_recipe.dart';

class RecipeDetailScreen extends StatelessWidget {
  final SnackRecipe recipe;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipe.name,
                style: const TextStyle(
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: CachedNetworkImage(
                imageUrl: recipe.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, size: 50),
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // メタ情報
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildInfoChip(
                        Icons.category,
                        recipe.category,
                        const Color(0xFFFFB5A7),
                      ),
                      _buildInfoChip(
                        Icons.timer,
                        '${recipe.prepTime}分',
                        const Color(0xFFFCD5CE),
                      ),
                      _buildInfoChip(
                        Icons.star,
                        recipe.difficulty,
                        const Color(0xFFCDB4DB),
                      ),
                      if (recipe.calories != null)
                        _buildInfoChip(
                          Icons.local_fire_department,
                          '${recipe.calories} kcal',
                          const Color(0xFFA2D2FF),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 説明
                  Text(
                    recipe.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 材料
                  Text(
                    '材料',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ...recipe.ingredients.map(
                    (ingredient) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              size: 20, color: Color(0xFFFF8BA7)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ingredient,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 作り方
                  Text(
                    '作り方',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ...recipe.steps.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFFF8BA7),
                                      Color(0xFFFFB5A7),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  const SizedBox(height: 32),
                  // タグ
                  if (recipe.tags.isNotEmpty) ...[
                    Text(
                      'タグ',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: recipe.tags
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              backgroundColor:
                                  const Color(0xFFFFB5A7).withValues(alpha: 0.3),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    final textColor = HSLColor.fromColor(color).withLightness(0.35).toColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
