import { PrismaClient } from '@prisma/client';

// PrismaClientのインスタンスを生成してDB接続を確立する
// このインスタンスを通じて全てのDB操作（CRUD）を行う
const prisma = new PrismaClient();

const snackRecipes = [
  {
    name: 'チョコレートチップクッキー',
    description: 'サクサクの食感と濃厚なチョコレートが楽しめる定番クッキーです。',
    imageUrl: 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=500',
    category: 'クッキー',
    difficulty: '簡単',
    prepTime: 30,
    // ingredients, stepsはDB上ではJSON文字列として保存される
    // Prismaスキーマで String 型として定義されているため、配列をJSON.stringifyで文字列化する
    // API側で返却時にJSON.parseして配列に復元する
    ingredients: JSON.stringify([
      '薄力粉 200g',
      'バター 100g',
      '砂糖 80g',
      '卵 1個',
      'チョコチップ 100g',
      'バニラエッセンス 少々'
    ]),
    steps: JSON.stringify([
      'バターを室温に戻し、砂糖と混ぜ合わせます',
      '卵とバニラエッセンスを加えてよく混ぜます',
      '薄力粉をふるい入れ、チョコチップを加えて混ぜます',
      '天板に並べ、180度のオーブンで12-15分焼きます'
    ]),
    calories: 120,
    tags: 'チョコレート,クッキー,定番,サクサク'
  },
  {
    name: '抹茶ガトーショコラ',
    description: '濃厚な抹茶の風味が楽しめる和風ガトーショコラです。',
    imageUrl: 'https://images.unsplash.com/photo-1571115177098-24ec42ed204d?w=500',
    category: 'ケーキ',
    difficulty: '普通',
    prepTime: 60,
    ingredients: JSON.stringify([
      'ホワイトチョコレート 150g',
      'バター 50g',
      '卵 3個',
      '砂糖 60g',
      '薄力粉 30g',
      '抹茶パウダー 15g'
    ]),
    steps: JSON.stringify([
      'チョコレートとバターを湯煎で溶かします',
      '卵黄と砂糖を白っぽくなるまで混ぜます',
      '溶かしたチョコレートを加え、粉類をふるい入れます',
      '卵白でメレンゲを作り、生地に混ぜ込みます',
      '型に流し入れ、170度のオーブンで30-35分焼きます'
    ]),
    calories: 280,
    tags: '抹茶,ケーキ,和風,濃厚'
  },
  {
    name: 'フルーツタルト',
    description: '季節のフルーツをたっぷり使った見た目も華やかなタルトです。',
    imageUrl: 'https://images.unsplash.com/photo-1464349095431-e9a21285b5f3?w=500',
    category: 'タルト',
    difficulty: '難しい',
    prepTime: 90,
    ingredients: JSON.stringify([
      'タルト生地用薄力粉 150g',
      'バター 80g',
      '砂糖 40g',
      '卵黄 1個',
      'カスタードクリーム 300g',
      'いちご、キウイ、ブルーベリー等 適量'
    ]),
    steps: JSON.stringify([
      'タルト生地を作り、冷蔵庫で30分休ませます',
      'タルト型に敷き詰め、180度で15分空焼きします',
      'カスタードクリームを作り、冷まします',
      '焼いたタルトにカスタードを流し入れます',
      'フルーツを美しく飾り付けます'
    ]),
    calories: 320,
    tags: 'フルーツ,タルト,華やか,カスタード'
  },
  {
    name: 'ティラミス',
    description: 'マスカルポーネチーズとコーヒーの絶妙なハーモニーが楽しめるイタリアンデザートです。',
    imageUrl: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=500',
    category: 'デザート',
    difficulty: '普通',
    prepTime: 45,
    ingredients: JSON.stringify([
      'マスカルポーネチーズ 250g',
      '卵黄 3個',
      '砂糖 80g',
      '生クリーム 200ml',
      'フィンガービスケット 20本',
      'エスプレッソコーヒー 200ml',
      'ココアパウダー 適量'
    ]),
    steps: JSON.stringify([
      '卵黄と砂糖を白っぽくなるまで混ぜます',
      'マスカルポーネチーズを加えてなめらかにします',
      '生クリームを7分立てにして加えます',
      'ビスケットをコーヒーに浸し、容器に並べます',
      'クリームを重ね、冷蔵庫で4時間以上冷やし、ココアをふります'
    ]),
    calories: 380,
    tags: 'コーヒー,チーズ,イタリアン,濃厚'
  },
  {
    name: 'チーズケーキ',
    description: 'しっとりとした食感と濃厚なチーズの味わいが人気のベイクドチーズケーキです。',
    imageUrl: 'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?w=500',
    category: 'ケーキ',
    difficulty: '普通',
    prepTime: 75,
    ingredients: JSON.stringify([
      'クリームチーズ 200g',
      '砂糖 60g',
      '卵 2個',
      '生クリーム 100ml',
      'レモン汁 大さじ1',
      '薄力粉 15g',
      'ビスケット(土台用) 80g',
      'バター(土台用) 40g'
    ]),
    steps: JSON.stringify([
      'ビスケットを砕き、溶かしバターと混ぜて型に敷き詰めます',
      'クリームチーズを柔らかくし、砂糖と混ぜます',
      '卵、生クリーム、レモン汁を順に加えて混ぜます',
      '薄力粉をふるい入れて混ぜ、型に流し入れます',
      '170度のオーブンで40-45分、湯煎焼きにします'
    ]),
    calories: 350,
    tags: 'チーズ,ケーキ,濃厚,しっとり'
  },
  {
    name: 'マカロン',
    description: 'フランス生まれの可愛らしい見た目と繊細な味わいのお菓子です。',
    imageUrl: 'https://images.unsplash.com/photo-1569864358642-9d1684040f43?w=500',
    category: 'クッキー',
    difficulty: '難しい',
    prepTime: 120,
    ingredients: JSON.stringify([
      'アーモンドプードル 100g',
      '粉砂糖 100g',
      '卵白 70g',
      'グラニュー糖 50g',
      '食用色素 適量',
      'バタークリーム 適量'
    ]),
    steps: JSON.stringify([
      'アーモンドプードルと粉砂糖を混ぜ、ふるいます',
      '卵白でメレンゲを作り、グラニュー糖を3回に分けて加えます',
      '色素を加え、粉類を混ぜ込みます(マカロナージュ)',
      '絞り袋で天板に絞り出し、30分乾燥させます',
      '140度で12-15分焼き、冷ましてクリームをサンドします'
    ]),
    calories: 90,
    tags: 'フランス菓子,可愛い,カラフル,繊細'
  },
  {
    name: 'シュークリーム',
    description: 'サクサクのシュー生地と濃厚なカスタードクリームの組み合わせが絶品です。',
    imageUrl: 'https://images.unsplash.com/photo-1612201142855-c58e2c6fe885?w=500',
    category: 'シュー',
    difficulty: '難しい',
    prepTime: 90,
    ingredients: JSON.stringify([
      '水 100ml',
      'バター 50g',
      '薄力粉 60g',
      '卵 2個',
      'カスタードクリーム 200g',
      '生クリーム 100ml'
    ]),
    steps: JSON.stringify([
      '水とバターを鍋で沸騰させます',
      '薄力粉を一気に加え、木べらで混ぜます',
      '卵を少しずつ加え、リボン状に落ちる固さにします',
      '絞り袋で天板に絞り、200度で10分、180度で20分焼きます',
      '冷ましてカスタードと生クリームを混ぜたものを詰めます'
    ]),
    calories: 250,
    tags: 'シュー,カスタード,サクサク,定番'
  },
  {
    name: 'パンケーキ',
    description: 'ふわふわでしっとりとした食感が楽しめる定番のパンケーキです。',
    imageUrl: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=500',
    category: 'パンケーキ',
    difficulty: '簡単',
    prepTime: 25,
    ingredients: JSON.stringify([
      'ホットケーキミックス 200g',
      '卵 1個',
      '牛乳 150ml',
      'バター 適量',
      'メープルシロップ 適量',
      '粉砂糖 適量'
    ]),
    steps: JSON.stringify([
      'ボウルに卵と牛乳を入れてよく混ぜます',
      'ホットケーキミックスを加えてさっくり混ぜます',
      'フライパンを熱し、生地を流し入れます',
      '表面にプツプツと穴が開いたら裏返します',
      'バターとメープルシロップをかけて完成です'
    ]),
    calories: 200,
    tags: 'パンケーキ,ふわふわ,簡単,朝食'
  },
  {
    name: 'ブラウニー',
    description: 'チョコレートがたっぷり入った濃厚でしっとりとしたブラウニーです。',
    imageUrl: 'https://images.unsplash.com/photo-1607920591413-4ec007e70023?w=500',
    category: 'ケーキ',
    difficulty: '簡単',
    prepTime: 40,
    ingredients: JSON.stringify([
      'チョコレート 150g',
      'バター 100g',
      '砂糖 100g',
      '卵 2個',
      '薄力粉 60g',
      'ココアパウダー 20g',
      'くるみ 50g'
    ]),
    steps: JSON.stringify([
      'チョコレートとバターを湯煎で溶かします',
      '砂糖を加えてよく混ぜます',
      '卵を1個ずつ加えて混ぜます',
      '粉類をふるい入れ、くるみを加えて混ぜます',
      '型に流し入れ、170度で25-30分焼きます'
    ]),
    calories: 290,
    tags: 'チョコレート,濃厚,しっとり,簡単'
  },
  {
    name: 'スコーン',
    description: 'イギリス伝統のお菓子。外はサクッと中はふんわりとした食感が特徴です。',
    imageUrl: 'https://images.unsplash.com/photo-1519676867240-f03bc0a17c9a?w=500',
    category: 'スコーン',
    difficulty: '普通',
    prepTime: 35,
    ingredients: JSON.stringify([
      '薄力粉 200g',
      'バター 50g',
      'ベーキングパウダー 小さじ2',
      '砂糖 30g',
      '塩 ひとつまみ',
      '牛乳 100ml',
      '卵 1個'
    ]),
    steps: JSON.stringify([
      '粉類をボウルに入れ、冷えたバターを混ぜ込みます',
      '牛乳と卵を加え、さっくり混ぜます',
      '生地をまとめ、厚さ2cmに伸ばします',
      '型で抜くか、ナイフで切り分けます',
      '200度のオーブンで15-18分焼きます'
    ]),
    calories: 180,
    tags: 'イギリス,スコーン,サクサク,ティータイム'
  },
  {
    name: 'マドレーヌ',
    description: 'バターの香りが豊かなフランスの伝統的な焼き菓子です。',
    imageUrl: 'https://images.unsplash.com/photo-1587241321921-91a834d82ffc?w=500',
    category: 'マドレーヌ',
    difficulty: '簡単',
    prepTime: 35,
    ingredients: JSON.stringify([
      '卵 2個',
      '砂糖 80g',
      '薄力粉 100g',
      'バター 100g',
      'ベーキングパウダー 小さじ1/2',
      'レモンの皮 1/2個分',
      'はちみつ 大さじ1'
    ]),
    steps: JSON.stringify([
      '卵と砂糖を白っぽくなるまで混ぜます',
      '粉類をふるい入れ、レモンの皮を加えます',
      '溶かしバターとはちみつを加えて混ぜます',
      '型に流し入れ、冷蔵庫で30分休ませます',
      '180度のオーブンで12-15分焼きます'
    ]),
    calories: 160,
    tags: 'フランス菓子,バター,レモン,しっとり'
  },
  {
    name: 'フィナンシェ',
    description: 'アーモンドの香りとバターの風味が豊かな高級焼き菓子です。',
    imageUrl: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=500',
    category: 'フィナンシェ',
    difficulty: '普通',
    prepTime: 40,
    ingredients: JSON.stringify([
      'アーモンドプードル 50g',
      '粉砂糖 100g',
      '薄力粉 30g',
      '卵白 100g',
      'バター 100g',
      'はちみつ 10g'
    ]),
    steps: JSON.stringify([
      '粉類を混ぜ合わせます',
      '卵白を加えて混ぜます',
      'バターを焦がしバターにして加えます',
      'はちみつを加え、冷蔵庫で1時間休ませます',
      '型に流し入れ、180度で15-18分焼きます'
    ]),
    calories: 140,
    tags: 'アーモンド,焦がしバター,高級,しっとり'
  },
  {
    name: 'カヌレ',
    description: '外はカリッと、中はもっちりとした独特の食感が楽しめるフランス菓子です。',
    imageUrl: 'https://images.unsplash.com/photo-1612203985729-70726954388c?w=500',
    category: 'カヌレ',
    difficulty: '難しい',
    prepTime: 240,
    ingredients: JSON.stringify([
      '牛乳 500ml',
      'バター 50g',
      'バニラビーンズ 1/2本',
      '薄力粉 100g',
      '砂糖 200g',
      '卵黄 2個',
      '全卵 1個',
      'ラム酒 30ml'
    ]),
    steps: JSON.stringify([
      '牛乳、バター、バニラを温めます',
      '卵と砂糖を混ぜ、粉を加えます',
      '温めた牛乳を加え、ラム酒を加えます',
      '冷蔵庫で一晩寝かせます',
      '型に流し入れ、220度で15分、180度で45分焼きます'
    ]),
    calories: 220,
    tags: 'フランス菓子,カリもち,バニラ,ラム酒'
  },
  {
    name: 'プリン',
    description: 'なめらかな食感とほろ苦いカラメルソースが絶妙なカスタードプリンです。',
    imageUrl: 'https://images.unsplash.com/photo-1603532648955-039310d9ed75?w=500',
    category: 'プリン',
    difficulty: '普通',
    prepTime: 60,
    ingredients: JSON.stringify([
      '卵 3個',
      '砂糖 60g',
      '牛乳 300ml',
      'バニラエッセンス 少々',
      'カラメル用砂糖 60g',
      'カラメル用水 大さじ2'
    ]),
    steps: JSON.stringify([
      'カラメルソースを作り、型に流します',
      '卵と砂糖を混ぜ、温めた牛乳を加えます',
      'バニラエッセンスを加え、濾します',
      '型に流し入れ、湯煎で蒸し焼きにします',
      '160度のオーブンで30-35分焼き、冷やします'
    ]),
    calories: 180,
    tags: 'プリン,カスタード,なめらか,定番'
  },
  {
    name: 'ダックワーズ',
    description: 'サクサクのアーモンド生地にクリームをサンドしたフランス菓子です。',
    imageUrl: 'https://images.unsplash.com/photo-1606313564016-4ba24cc1d7d6?w=500',
    category: 'クッキー',
    difficulty: '難しい',
    prepTime: 90,
    ingredients: JSON.stringify([
      'アーモンドプードル 60g',
      '粉砂糖 60g',
      '卵白 60g',
      'グラニュー糖 30g',
      'バタークリーム 100g',
      '薄力粉 10g'
    ]),
    steps: JSON.stringify([
      'アーモンドプードル、粉砂糖、薄力粉を混ぜます',
      '卵白でメレンゲを作り、グラニュー糖を加えます',
      '粉類を加えて混ぜ、絞り袋で絞ります',
      '粉砂糖をふり、180度で12-15分焼きます',
      '冷ましてバタークリームをサンドします'
    ]),
    calories: 150,
    tags: 'フランス菓子,アーモンド,サクサク,クリーム'
  },
  {
    name: 'ベイクドチーズタルト',
    description: 'タルト生地とチーズケーキの組み合わせが絶妙なデザートです。',
    imageUrl: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=500',
    category: 'タルト',
    difficulty: '難しい',
    prepTime: 100,
    ingredients: JSON.stringify([
      'タルト生地用薄力粉 120g',
      'バター 60g',
      '砂糖 30g',
      'クリームチーズ 200g',
      '砂糖 50g',
      '卵 1個',
      '生クリーム 100ml',
      'レモン汁 大さじ1'
    ]),
    steps: JSON.stringify([
      'タルト生地を作り、型に敷き詰めます',
      '180度で15分空焼きします',
      'クリームチーズと砂糖を混ぜます',
      '卵、生クリーム、レモン汁を加えて混ぜます',
      'タルトに流し入れ、170度で30-35分焼きます'
    ]),
    calories: 310,
    tags: 'タルト,チーズ,濃厚,しっとり'
  },
  {
    name: 'モンブラン',
    description: '栗のクリームとメレンゲの組み合わせが絶品のフランス菓子です。',
    imageUrl: 'https://images.unsplash.com/photo-1602351447937-745cb720612f?w=500',
    category: 'ケーキ',
    difficulty: '難しい',
    prepTime: 120,
    ingredients: JSON.stringify([
      'メレンゲ用卵白 2個分',
      'グラニュー糖 100g',
      '栗ペースト 200g',
      '生クリーム 200ml',
      'スポンジケーキ 1台',
      '栗の甘露煮 適量'
    ]),
    steps: JSON.stringify([
      'メレンゲを作り、100度で60分焼きます',
      'スポンジケーキを丸く型抜きします',
      '栗ペーストと生クリームを混ぜます',
      'スポンジの上に生クリームを絞ります',
      '栗クリームを細く絞り、栗の甘露煮を飾ります'
    ]),
    calories: 380,
    tags: '栗,フランス菓子,メレンゲ,秋'
  },
  {
    name: 'レアチーズケーキ',
    description: '焼かずに作れる爽やかな味わいのチーズケーキです。',
    imageUrl: 'https://images.unsplash.com/photo-1524351199678-941a58a3df50?w=500',
    category: 'ケーキ',
    difficulty: '簡単',
    prepTime: 30,
    ingredients: JSON.stringify([
      'クリームチーズ 200g',
      '砂糖 60g',
      'ヨーグルト 100g',
      '生クリーム 200ml',
      'レモン汁 大さじ2',
      'ゼラチン 5g',
      'ビスケット(土台用) 80g',
      'バター(土台用) 40g'
    ]),
    steps: JSON.stringify([
      'ビスケットを砕き、バターと混ぜて型に敷き詰めます',
      'クリームチーズと砂糖を混ぜます',
      'ヨーグルト、生クリーム、レモン汁を加えます',
      'ふやかしたゼラチンを加えて混ぜます',
      '型に流し入れ、冷蔵庫で3時間以上冷やします'
    ]),
    calories: 300,
    tags: 'チーズ,爽やか,簡単,冷やす'
  },
  {
    name: 'エクレア',
    description: 'チョコレートコーティングとカスタードクリームが絶品のシュー菓子です。',
    imageUrl: 'https://images.unsplash.com/photo-1612809297232-6e0a4cd10411?w=500',
    category: 'シュー',
    difficulty: '難しい',
    prepTime: 90,
    ingredients: JSON.stringify([
      'シュー生地材料(水100ml、バター50g、薄力粉60g、卵2個)',
      'カスタードクリーム 200g',
      '生クリーム 100ml',
      'チョコレート 100g',
      '生クリーム(コーティング用) 50ml'
    ]),
    steps: JSON.stringify([
      'シュー生地を作り、細長く絞ります',
      '200度で10分、180度で20分焼きます',
      'カスタードと生クリームを混ぜたものを詰めます',
      'チョコレートと生クリームでガナッシュを作ります',
      'シューの上部にガナッシュを塗ります'
    ]),
    calories: 280,
    tags: 'シュー,チョコレート,カスタード,フランス菓子'
  },
  {
    name: 'ミルクレープ',
    description: '何層ものクレープとクリームが織りなす美しいケーキです。',
    imageUrl: 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=500',
    category: 'ケーキ',
    difficulty: '難しい',
    prepTime: 120,
    ingredients: JSON.stringify([
      'クレープ生地用薄力粉 100g',
      '卵 2個',
      '牛乳 250ml',
      '砂糖 20g',
      'バター 20g',
      '生クリーム 400ml',
      '砂糖(クリーム用) 40g'
    ]),
    steps: JSON.stringify([
      'クレープ生地を作り、20枚焼きます',
      '生クリームと砂糖を泡立てます',
      'クレープとクリームを交互に重ねます',
      '20層程度重ねたら、冷蔵庫で2時間冷やします',
      '好みでフルーツや粉砂糖で飾ります'
    ]),
    calories: 320,
    tags: 'クレープ,生クリーム,層,手間'
  },
  {
    name: 'アップルパイ',
    description: 'シナモンの香りとりんごの甘酸っぱさが絶妙なパイです。',
    imageUrl: 'https://images.unsplash.com/photo-1535920527002-b35e96722eb9?w=500',
    category: 'パイ',
    difficulty: '難しい',
    prepTime: 90,
    ingredients: JSON.stringify([
      'パイシート 2枚',
      'りんご 3個',
      '砂糖 60g',
      'バター 20g',
      'シナモンパウダー 小さじ1',
      'レモン汁 大さじ1',
      '卵黄 1個'
    ]),
    steps: JSON.stringify([
      'りんごを薄切りにし、砂糖とレモン汁で煮ます',
      'バターとシナモンを加えて冷まします',
      'パイシートを型に敷き、りんごを詰めます',
      '上にパイシートを被せ、格子状に切り込みを入れます',
      '卵黄を塗り、200度で30-35分焼きます'
    ]),
    calories: 290,
    tags: 'りんご,パイ,シナモン,秋'
  },
  {
    name: 'ロールケーキ',
    description: 'ふわふわのスポンジと生クリームが楽しめる定番ケーキです。',
    imageUrl: 'https://images.unsplash.com/photo-1612810699408-090ae5fc9415?w=500',
    category: 'ケーキ',
    difficulty: '普通',
    prepTime: 60,
    ingredients: JSON.stringify([
      '卵 4個',
      '砂糖 80g',
      '薄力粉 80g',
      'バニラエッセンス 少々',
      '生クリーム 200ml',
      '砂糖(クリーム用) 20g',
      'フルーツ お好みで'
    ]),
    steps: JSON.stringify([
      '卵と砂糖を泡立て器で白っぽくなるまで混ぜます',
      '薄力粉をふるい入れ、さっくり混ぜます',
      '天板に流し、180度で12分焼きます',
      '生クリームを泡立て、スポンジに塗ります',
      '端から巻いて、冷蔵庫で冷やします'
    ]),
    calories: 250,
    tags: 'スポンジ,生クリーム,ふわふわ,定番'
  },
  {
    name: 'フォンダンショコラ',
    description: '中からとろけるチョコレートが流れ出す贅沢なデザートです。',
    imageUrl: 'https://images.unsplash.com/photo-1606312619070-d48b4ad2c1f5?w=500',
    category: 'ケーキ',
    difficulty: '普通',
    prepTime: 45,
    ingredients: JSON.stringify([
      'チョコレート 100g',
      'バター 80g',
      '卵 2個',
      '砂糖 50g',
      '薄力粉 30g',
      'ココアパウダー 10g'
    ]),
    steps: JSON.stringify([
      'チョコレートとバターを湯煎で溶かします',
      '卵と砂糖を白っぽくなるまで混ぜます',
      '溶かしたチョコレートを加えます',
      '粉類をふるい入れて混ぜます',
      '型に流し入れ、200度で10-12分焼きます'
    ]),
    calories: 320,
    tags: 'チョコレート,とろける,贅沢,温かい'
  },
  {
    name: 'バスクチーズケーキ',
    description: '表面が焦げた見た目と濃厚な味わいが特徴のスペイン発祥のチーズケーキです。',
    imageUrl: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=500',
    category: 'ケーキ',
    difficulty: '簡単',
    prepTime: 50,
    ingredients: JSON.stringify([
      'クリームチーズ 400g',
      '砂糖 130g',
      '卵 3個',
      '生クリーム 200ml',
      '薄力粉 15g',
      'レモン汁 大さじ1'
    ]),
    steps: JSON.stringify([
      'クリームチーズを柔らかくし、砂糖と混ぜます',
      '卵を1個ずつ加えて混ぜます',
      '生クリーム、薄力粉、レモン汁を加えます',
      'クッキングシートを敷いた型に流します',
      '230度のオーブンで25-30分焼きます'
    ]),
    calories: 340,
    tags: 'チーズ,スペイン,濃厚,焦げ'
  },
  {
    name: 'どら焼き',
    description: 'ふわふわの生地と甘さ控えめのあんこが絶妙な和菓子です。',
    imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500',
    category: '和菓子',
    difficulty: '簡単',
    prepTime: 35,
    ingredients: JSON.stringify([
      '卵 2個',
      '砂糖 60g',
      'はちみつ 30g',
      'みりん 大さじ1',
      '薄力粉 100g',
      'ベーキングパウダー 小さじ1',
      '水 50ml',
      'あんこ 200g'
    ]),
    steps: JSON.stringify([
      '卵、砂糖、はちみつ、みりんを混ぜます',
      '粉類をふるい入れ、水を加えて混ぜます',
      'フライパンで両面を焼きます',
      '冷ましてあんこを挟みます',
      'ラップで包んで馴染ませます'
    ]),
    calories: 220,
    tags: '和菓子,あんこ,ふわふわ,定番'
  },
  {
    name: '大福',
    description: 'もちもちの求肥とあんこが絶品の和菓子です。',
    imageUrl: 'https://images.unsplash.com/photo-1582716401301-b2407dc7563d?w=500',
    category: '和菓子',
    difficulty: '普通',
    prepTime: 40,
    ingredients: JSON.stringify([
      '白玉粉 100g',
      '砂糖 50g',
      '水 150ml',
      'あんこ 200g',
      '片栗粉 適量'
    ]),
    steps: JSON.stringify([
      '白玉粉と砂糖を混ぜ、水を加えます',
      '電子レンジで2分加熱し、混ぜます',
      'さらに1分加熱し、よく混ぜます',
      '片栗粉を広げた上に生地を出します',
      'あんこを包んで形を整えます'
    ]),
    calories: 150,
    tags: '和菓子,もち,あんこ,簡単'
  },
  {
    name: 'わらび餅',
    description: 'ぷるぷるの食感ときな粉の香ばしさが楽しめる夏の和菓子です。',
    imageUrl: 'https://images.unsplash.com/photo-1625944525533-473f1a3d54e7?w=500',
    category: '和菓子',
    difficulty: '簡単',
    prepTime: 30,
    ingredients: JSON.stringify([
      'わらび餅粉 100g',
      '砂糖 50g',
      '水 400ml',
      'きな粉 適量',
      '黒蜜 適量'
    ]),
    steps: JSON.stringify([
      'わらび餅粉と砂糖を混ぜます',
      '水を少しずつ加えてよく混ぜます',
      '鍋で加熱しながら透明になるまで練ります',
      '氷水で冷やし、一口大に切ります',
      'きな粉と黒蜜をかけます'
    ]),
    calories: 130,
    tags: '和菓子,ぷるぷる,きな粉,夏'
  },
  {
    name: 'パンナコッタ',
    description: 'なめらかでクリーミーなイタリアンデザートです。',
    imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500',
    category: 'デザート',
    difficulty: '簡単',
    prepTime: 25,
    ingredients: JSON.stringify([
      '生クリーム 300ml',
      '牛乳 200ml',
      '砂糖 50g',
      'バニラエッセンス 少々',
      'ゼラチン 5g',
      'ベリーソース お好みで'
    ]),
    steps: JSON.stringify([
      'ゼラチンを水でふやかします',
      '生クリーム、牛乳、砂糖を温めます',
      'ゼラチンとバニラエッセンスを加えます',
      '型に流し入れ、冷蔵庫で3時間冷やします',
      'ベリーソースをかけて完成です'
    ]),
    calories: 240,
    tags: 'イタリアン,クリーミー,簡単,冷やす'
  },
  {
    name: 'クレームブリュレ',
    description: 'カラメルのパリパリとカスタードのなめらかさが楽しめるフランス菓子です。',
    imageUrl: 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=500',
    category: 'デザート',
    difficulty: '普通',
    prepTime: 90,
    ingredients: JSON.stringify([
      '卵黄 4個',
      '砂糖 50g',
      '生クリーム 300ml',
      'バニラビーンズ 1/2本',
      '砂糖(カラメル用) 適量'
    ]),
    steps: JSON.stringify([
      '卵黄と砂糖を白っぽくなるまで混ぜます',
      '温めた生クリームとバニラを加えます',
      '濾して型に流し入れます',
      '湯煎で140度、30-35分焼きます',
      '冷やして表面に砂糖をかけ、バーナーで焦がします'
    ]),
    calories: 310,
    tags: 'フランス菓子,カスタード,パリパリ,バーナー'
  },
  {
    name: 'ミニタルト',
    description: 'フルーツやクリームをトッピングした可愛らしい一口サイズのタルトです。',
    imageUrl: 'https://images.unsplash.com/photo-1519915212116-7cfef71f1d3e?w=500',
    category: 'タルト',
    difficulty: '普通',
    prepTime: 60,
    ingredients: JSON.stringify([
      'タルト生地用薄力粉 120g',
      'バター 60g',
      '砂糖 30g',
      '卵黄 1個',
      'カスタードクリーム 150g',
      'フルーツ各種 適量'
    ]),
    steps: JSON.stringify([
      'タルト生地を作り、ミニタルト型に敷きます',
      '180度で12-15分空焼きします',
      'カスタードクリームを詰めます',
      'フルーツを美しく飾ります',
      'ナパージュを塗って完成です'
    ]),
    calories: 180,
    tags: 'タルト,フルーツ,可愛い,一口'
  },
  {
    name: 'チュロス',
    description: 'サクサクの外側と柔らかい中身、シナモンシュガーが絶品のスペイン菓子です。',
    imageUrl: 'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=500',
    category: '揚げ菓子',
    difficulty: '普通',
    prepTime: 40,
    ingredients: JSON.stringify([
      '水 200ml',
      'バター 50g',
      '塩 ひとつまみ',
      '薄力粉 100g',
      '卵 2個',
      '揚げ油 適量',
      'シナモンシュガー 適量'
    ]),
    steps: JSON.stringify([
      '水、バター、塩を沸騰させます',
      '薄力粉を一気に加え、よく混ぜます',
      '卵を少しずつ加えて混ぜます',
      '星口金で絞りながら油で揚げます',
      'シナモンシュガーをまぶします'
    ]),
    calories: 200,
    tags: 'スペイン,揚げ菓子,シナモン,サクサク'
  }
];

async function main() {
  console.log('Start seeding...');

  for (const recipe of snackRecipes) {
    // 重複登録を防止するため、nameで既存レコードを検索する
    // findFirstはユニーク制約のないカラムでも検索できるため、nameにユニーク制約がなくても使用可能
    // 同名レシピが既に存在する場合はスキップし、存在しない場合のみ新規作成する
    const existing = await prisma.snackRecipe.findFirst({
      where: { name: recipe.name },
    });
    if (existing) {
      console.log(`Skipped (already exists): ${existing.name}`);
      continue;
    }
    const created = await prisma.snackRecipe.create({
      data: recipe,
    });
    console.log(`Created recipe with id: ${created.id} - ${created.name}`);
  }

  console.log('Seeding finished.');
}

// main関数を実行し、エラー発生時はプロセスを異常終了させる（exit code: 1）
// finallyでPrismaのDB接続を確実に切断し、コネクションリークを防止する
// この切断処理はseed成功・失敗に関わらず必ず実行される
main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
