import express, { Request, Response } from 'express';
import cors from 'cors';
import { PrismaClient } from '@prisma/client';

const app = express();
const prisma = new PrismaClient();
// 環境変数PORTが未設定の場合はデフォルトで3000番ポートを使用する
const PORT = process.env.PORT || 3000;

// CORSを有効にし、異なるオリジン（Flutterアプリ等）からのAPIリクエストを許可する
app.use(cors());
// リクエストボディのJSONを自動的にパースしてreq.bodyに格納するミドルウェア
app.use(express.json());

// レシピ一覧取得（ページネーション対応）
app.get('/api/recipes', async (req: Request, res: Response) => {
  try {
    // クエリパラメータをintにパースし、未指定や不正値の場合はデフォルト値を適用する
    // parseIntがNaNを返す場合、|| 演算子によりデフォルト値にフォールバックする
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    // Prismaのskipに渡すオフセット値を算出する（例: page=2, limit=10 → skip=10）
    const skip = (page - 1) * limit;
    const category = req.query.category as string;
    const difficulty = req.query.difficulty as string;

    // フィルタ条件を動的に構築する
    // クエリパラメータにcategoryやdifficultyが指定された場合のみ条件に追加される
    // 未指定の場合はwhereが空オブジェクトとなり、全件が対象になる
    const where: any = {};
    if (category) where.category = category;
    if (difficulty) where.difficulty = difficulty;

    // Promise.allでレシピ取得とカウントを並列実行し、パフォーマンスを最適化する
    // 逐次実行と比較して、DB往復の待ち時間を削減できる
    const [recipes, total] = await Promise.all([
      prisma.snackRecipe.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      prisma.snackRecipe.count({ where }),
    ]);

    // DBではJSON文字列・カンマ区切り文字列として保存されているフィールドを
    // クライアントが扱いやすい配列形式に変換してレスポンスに含める
    // ingredients, steps: JSON文字列 → 配列に復元
    // tags: カンマ区切り文字列 → 配列に分割
    const recipesWithParsedData = recipes.map((recipe) => ({
      ...recipe,
      ingredients: JSON.parse(recipe.ingredients),
      steps: JSON.parse(recipe.steps),
      tags: recipe.tags.split(','),
    }));

    // ページネーション情報をレスポンスに含めることで、
    // クライアント側で「次のページがあるか」「全何ページか」を判定できるようにする
    res.json({
      recipes: recipesWithParsedData,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
        hasMore: skip + limit < total,
      },
    });
  } catch (error) {
    console.error('Error fetching recipes:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// レシピ詳細取得
app.get('/api/recipes/:id', async (req: Request, res: Response) => {
  try {
    const id = parseInt(req.params.id);
    const recipe = await prisma.snackRecipe.findUnique({
      where: { id },
    });

    if (!recipe) {
      return res.status(404).json({ error: 'Recipe not found' });
    }

    const recipeWithParsedData = {
      ...recipe,
      ingredients: JSON.parse(recipe.ingredients),
      steps: JSON.parse(recipe.steps),
      tags: recipe.tags.split(','),
    };

    res.json(recipeWithParsedData);
  } catch (error) {
    console.error('Error fetching recipe:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Swipe結果保存
app.post('/api/swipes', async (req: Request, res: Response) => {
  try {
    const { recipeId, userId, liked } = req.body;

    // リクエストボディのバリデーション
    // likedはboolean型であることをtypeofで厳密に判定する
    // （falseは有効な値のため、!likedでは正しく検証できない）
    if (!recipeId || !userId || typeof liked !== 'boolean') {
      return res.status(400).json({ error: 'Invalid request body' });
    }

    const swipe = await prisma.userSwipe.create({
      data: {
        recipeId,
        userId,
        liked,
      },
    });

    res.json(swipe);
  } catch (error) {
    console.error('Error saving swipe:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ユーザーのお気に入りレシピ取得
app.get('/api/favorites/:userId', async (req: Request, res: Response) => {
  try {
    const userId = req.params.userId;

    // 2段階のクエリでお気に入りレシピを取得する
    // 1. userSwipeテーブルからliked=trueのレコードを取得してrecipeIdを収集
    // 2. 収集したrecipeIdの配列をIN句で指定してレシピを一括取得する
    // ※ Prismaのinclude/joinを使わない理由: userSwipeにrecipeへのリレーションが定義されていないため
    const likedSwipes = await prisma.userSwipe.findMany({
      where: {
        userId,
        liked: true,
      },
      orderBy: { createdAt: 'desc' },
    });

    const recipeIds = likedSwipes.map((swipe) => swipe.recipeId);
    const recipes = await prisma.snackRecipe.findMany({
      where: {
        id: { in: recipeIds },
      },
    });

    const recipesWithParsedData = recipes.map((recipe) => ({
      ...recipe,
      ingredients: JSON.parse(recipe.ingredients),
      steps: JSON.parse(recipe.steps),
      tags: recipe.tags.split(','),
    }));

    res.json(recipesWithParsedData);
  } catch (error) {
    console.error('Error fetching favorites:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// カテゴリー一覧取得
app.get('/api/categories', async (req: Request, res: Response) => {
  try {
    // distinctを指定することで、重複を除いたユニークなカテゴリ値のみを取得する
    // selectでcategoryのみに絞ることで、不要なカラムの転送を避ける
    const categories = await prisma.snackRecipe.findMany({
      select: { category: true },
      distinct: ['category'],
    });

    // { category: "ケーキ" } の形式からカテゴリ名の文字列配列に変換して返す
    res.json(categories.map((c) => c.category));
  } catch (error) {
    console.error('Error fetching categories:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
