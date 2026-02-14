import express, { Request, Response } from 'express';
import cors from 'cors';
import { PrismaClient } from '@prisma/client';

const app = express();
const prisma = new PrismaClient();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// レシピ一覧取得（ページネーション対応）
app.get('/api/recipes', async (req: Request, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const skip = (page - 1) * limit;
    const category = req.query.category as string;
    const difficulty = req.query.difficulty as string;

    const where: any = {};
    if (category) where.category = category;
    if (difficulty) where.difficulty = difficulty;

    const [recipes, total] = await Promise.all([
      prisma.snackRecipe.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      prisma.snackRecipe.count({ where }),
    ]);

    const recipesWithParsedData = recipes.map((recipe) => ({
      ...recipe,
      ingredients: JSON.parse(recipe.ingredients),
      steps: JSON.parse(recipe.steps),
      tags: recipe.tags.split(','),
    }));

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
    const categories = await prisma.snackRecipe.findMany({
      select: { category: true },
      distinct: ['category'],
    });

    res.json(categories.map((c) => c.category));
  } catch (error) {
    console.error('Error fetching categories:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
