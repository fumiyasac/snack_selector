#!/bin/bash

echo "🍪 おやつSwipeアプリのセットアップを開始します..."

# バックエンドのセットアップ
echo "📦 バックエンドのセットアップ中..."
cd snack_selector_backend
npm install
cd ..

# Docker Composeの起動
echo "🐳 Dockerコンテナを起動中..."
docker compose up -d

# コンテナの起動を待つ
echo "⏳ データベースの起動を待っています..."
sleep 10

# マイグレーションの実行（シードはDockerコンテナ起動時に自動実行されます）
echo "🗄️  データベースのマイグレーションを実行中..."
docker compose exec -T backend npx prisma migrate deploy

# Flutterのセットアップ
echo "📱 Flutterアプリのセットアップ中..."
cd snack_selector_mobile
flutter pub get
cd ..

echo ""
echo "✅ セットアップが完了しました!"
echo ""
echo "📌 次のステップ:"
echo "1. バックエンドが起動しています: http://localhost:3000"
echo "2. Flutterアプリを起動するには:"
echo "   cd snack_selector_mobile"
echo "   flutter run"
echo ""
echo "🛑 停止するには: docker compose down"
