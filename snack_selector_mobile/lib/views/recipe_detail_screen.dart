import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/snack_recipe.dart';

class RecipeDetailScreen extends StatefulWidget {
  final SnackRecipe recipe;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  static const _brown = Color(0xFF4E342E);
  static const _brownLight = Color(0xFF6D4C41);
  static const _textDark = Color(0xFF1C1B1F);
  static const _textBody = Color(0xFF3E2723);
  static const _expandedHeight = 320.0;

  final _scrollController = ScrollController();
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final collapsed =
        _scrollController.offset > _expandedHeight - kToolbarHeight;
    if (collapsed != _isCollapsed) {
      setState(() => _isCollapsed = collapsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAF8),
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCard(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _buildDescription(),
                        const SizedBox(height: 32),
                        _buildSectionHeader('材料', Icons.shopping_basket_outlined),
                        const SizedBox(height: 14),
                        _buildIngredients(),
                        const SizedBox(height: 32),
                        _buildSectionHeader('作り方', Icons.restaurant_menu_outlined),
                        const SizedBox(height: 16),
                        _buildSteps(),
                        if (widget.recipe.tags.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          _buildSectionHeader('タグ', Icons.label_outline),
                          const SizedBox(height: 12),
                          _buildTags(),
                        ],
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 40,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // SliverAppBar
  // FlexibleSpaceBar.title は使わず、background 内の Positioned で
  // 展開時タイトルを管理し、折りたたみ時は SliverAppBar.title に切替。
  // ----------------------------------------------------------------
  Widget _buildSliverAppBar(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return SliverAppBar(
      expandedHeight: _expandedHeight,
      pinned: true,
      stretch: true,
      backgroundColor: _brown,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black26,
      // collapsed 時のタイトル
      title: AnimatedOpacity(
        opacity: _isCollapsed ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 180),
        child: Text(
          widget.recipe.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _CircleIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        // title は使わない（スケール崩れを防ぐ）
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 背景画像
            CachedNetworkImage(
              imageUrl: widget.recipe.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: const Color(0xFFEFEBE9),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _brown,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: const Color(0xFFEFEBE9),
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  size: 60,
                  color: Color(0xFF8D6E63),
                ),
              ),
            ),
            // 上部グラデーション（ステータスバー視認性）
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topPadding + 56,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
              ),
            ),
            // 下部グラデーション（タイトル領域）
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.42, 1.0],
                    colors: [Colors.transparent, Color(0xEA000000)],
                  ),
                ),
              ),
            ),
            // 展開時タイトル（自前で Positioned 配置）
            Positioned(
              left: 20,
              right: 72,
              bottom: 22,
              child: AnimatedOpacity(
                opacity: _isCollapsed ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Text(
                  widget.recipe.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.25,
                    shadows: [
                      Shadow(
                        color: Colors.black38,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // スタッツカード
  // ----------------------------------------------------------------
  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildStatItem(
              Icons.timer_outlined,
              '${widget.recipe.prepTime}分',
              '調理時間',
            ),
            _buildVerticalDivider(),
            _buildStatItem(
              _difficultyIcon(),
              widget.recipe.difficulty,
              '難易度',
            ),
            _buildVerticalDivider(),
            _buildStatItem(
              Icons.category_outlined,
              widget.recipe.category,
              'カテゴリ',
            ),
            if (widget.recipe.calories != null) ...[
              _buildVerticalDivider(),
              _buildStatItem(
                Icons.local_fire_department_outlined,
                '${widget.recipe.calories}',
                'kcal',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: _brownLight),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _textDark,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF9E9E9E),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return const VerticalDivider(
      width: 1,
      thickness: 1,
      indent: 14,
      endIndent: 14,
      color: Color(0xFFEEEEEE),
    );
  }

  IconData _difficultyIcon() {
    switch (widget.recipe.difficulty) {
      case '簡単':
        return Icons.sentiment_satisfied_outlined;
      case '難しい':
        return Icons.sentiment_dissatisfied_outlined;
      default:
        return Icons.sentiment_neutral_outlined;
    }
  }

  // ----------------------------------------------------------------
  // 説明文
  // ----------------------------------------------------------------
  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDE7E4)),
      ),
      child: Text(
        widget.recipe.description,
        style: const TextStyle(
          fontSize: 14,
          height: 1.8,
          color: _textBody,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // セクションヘッダー
  // ----------------------------------------------------------------
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: _brown,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 18, color: _brown),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: _textDark,
                letterSpacing: -0.2,
              ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------------
  // 材料
  // ----------------------------------------------------------------
  Widget _buildIngredients() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: widget.recipe.ingredients.asMap().entries.map((entry) {
          final isLast = entry.key == widget.recipe.ingredients.length - 1;
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _brown.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 13, color: _brown),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: _textBody,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  indent: 52,
                  endIndent: 16,
                  color: Color(0xFFF2F2F2),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ----------------------------------------------------------------
  // 作り方（タイムライン）
  // ----------------------------------------------------------------
  Widget _buildSteps() {
    return Column(
      children: widget.recipe.steps.asMap().entries.map((entry) {
        final index = entry.key;
        final isLast = index == widget.recipe.steps.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // タイムライン列
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: _brown,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: _brown.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // コンテンツカード
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.65,
                        color: _textBody,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ----------------------------------------------------------------
  // タグ
  // ----------------------------------------------------------------
  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.recipe.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD7CCC8)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tag, size: 12, color: Color(0xFF8D6E63)),
              const SizedBox(width: 4),
              Text(
                tag,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF5D4037),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ----------------------------------------------------------------
// 戻るボタン（半透明円形）
// ----------------------------------------------------------------
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
