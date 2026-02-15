class SnackRecipe {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final String difficulty;
  final int prepTime;
  final List<String> ingredients;
  final List<String> steps;
  final int? calories;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  SnackRecipe({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.difficulty,
    required this.prepTime,
    required this.ingredients,
    required this.steps,
    this.calories,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SnackRecipe.fromJson(Map<String, dynamic> json) {
    return SnackRecipe(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      prepTime: json['prepTime'] as int,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      steps:
      (json['steps'] as List<dynamic>).map((e) => e as String).toList(),
      calories: json['calories'] as int?,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'difficulty': difficulty,
      'prepTime': prepTime,
      'ingredients': ingredients,
      'steps': steps,
      'calories': calories,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  SnackRecipe copyWith({
    int? id,
    String? name,
    String? description,
    String? imageUrl,
    String? category,
    String? difficulty,
    int? prepTime,
    List<String>? ingredients,
    List<String>? steps,
    int? calories,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SnackRecipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      prepTime: prepTime ?? this.prepTime,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
