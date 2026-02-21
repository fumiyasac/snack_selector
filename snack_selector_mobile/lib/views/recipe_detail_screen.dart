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
                      color: Colors.black54,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: CachedNetworkImage(
                imageUrl: recipe.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
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
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        Icons.category,
                        recipe.category,
                        const Color(0xFFEFEBE9),
                      ),
                      _buildInfoChip(
                        Icons.timer,
                        '${recipe.prepTime}分',
                        const Color(0xFFECEFF1),
                      ),
                      _buildInfoChip(
                        Icons.star,
                        recipe.difficulty,
                        const Color(0xFFF3E5F5),
                      ),
                      if (recipe.calories != null)
                        _buildInfoChip(
                          Icons.local_fire_department,
                          '${recipe.calories} kcal',
                          const Color(0xFFFCE4EC),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 説明
                  Text(
                    recipe.description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 材料
                  Text(
                    '材料',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C1B1F),
                        ),
                  ),
                  const SizedBox(height: 16),
                  ...recipe.ingredients.map(
                    (ingredient) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              size: 18, color: Color(0xFF4E342E)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ingredient,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF3E2723),
                              ),
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
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C1B1F),
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
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4E342E),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.6,
                                    color: Color(0xFF3E2723),
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
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1C1B1F),
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: recipe.tags
                          .map(
                            (tag) => Chip(
                              label: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                              backgroundColor: const Color(0xFFEFEBE9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: BorderSide.none,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
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

  Widget _buildInfoChip(IconData icon, String label, Color bgColor) {
    const textColor = Color(0xFF5D4037);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
