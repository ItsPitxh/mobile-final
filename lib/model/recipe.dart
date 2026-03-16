class Recipe {
  int? id;
  String title;
  String category;
  String ingredients; // newline-separated list
  String instructions;
  int isFavorite;
  String? cookTime;
  String? servings;
  /// ISO-8601 date string, e.g. "2026-03-16". Set when recipe is created.
  String? createdAt;

  Recipe({
    this.id,
    required this.title,
    required this.category,
    required this.ingredients,
    required this.instructions,
    this.isFavorite = 0,
    this.cookTime,
    this.servings,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'ingredients': ingredients,
      'instructions': instructions,
      'isFavorite': isFavorite,
      'cookTime': cookTime,
      'servings': servings,
      'createdAt': createdAt,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as int?,
      title: map['title'] as String,
      category: map['category'] as String,
      ingredients: map['ingredients'] as String,
      instructions: map['instructions'] as String,
      isFavorite: map['isFavorite'] as int? ?? 0,
      cookTime: map['cookTime'] as String?,
      servings: map['servings'] as String?,
      createdAt: map['createdAt'] as String?,
    );
  }

  /// Parsed ingredient lines — empty/blank entries removed.
  List<String> get ingredientLines => ingredients
      .split('\n')
      .where((s) => s.trim().isNotEmpty)
      .toList();

  /// Parsed instruction steps — empty/blank entries removed and any
  /// leading "1. " numbering stripped so the UI can renumber freely.
  List<String> get instructionLines => instructions
      .split('\n')
      .where((s) => s.trim().isNotEmpty)
      .map((s) => s.replaceFirst(RegExp(r'^\d+\.\s*'), ''))
      .toList();

  Recipe copyWith({
    int? id,
    String? title,
    String? category,
    String? ingredients,
    String? instructions,
    int? isFavorite,
    String? cookTime,
    String? servings,
    String? createdAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      isFavorite: isFavorite ?? this.isFavorite,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
