import 'package:flutter/foundation.dart' hide Category;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../model/recipe.dart';
import '../../model/category.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  static const String _dbName      = 'food_recipes.db';
  static const int    _dbVersion   = 3;
  static const String _tableName   = 'recipes';
  static const String _categoryTable = 'categories';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ── Schema creation ────────────────────────────────────────────────────────

  Future<void> _onCreate(Database db, int version) async {
    // Recipes table
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        ingredients TEXT NOT NULL,
        instructions TEXT NOT NULL,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        cookTime TEXT,
        servings TEXT,
        createdAt TEXT
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE $_categoryTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await _insertSampleRecipes(db);
    await _insertDefaultCategories(db);
  }

  /// Incremental migrations.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // v1 → v2: add createdAt column to recipes
    if (oldVersion < 2) {
      try {
        await db.execute(
            'ALTER TABLE $_tableName ADD COLUMN createdAt TEXT');
      } catch (_) {
        // Column already exists — safe to ignore.
      }
    }
    // v2 → v3: create categories table
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_categoryTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE
        )
      ''');
      await _insertDefaultCategories(db);
    }
  }

  // ── Seed data ──────────────────────────────────────────────────────────────

  Future<void> _insertDefaultCategories(Database db) async {
    const defaults = [
      'Breakfast', 'Pasta', 'Asian', 'Soup',
      'Salad', 'Seafood', 'Beef', 'Chicken', 'Dessert', 'Other',
    ];
    for (final name in defaults) {
      await db.insert(
        _categoryTable,
        {'name': name},
        conflictAlgorithm: ConflictAlgorithm.ignore, // skip if already there
      );
    }
  }

  Future<void> _insertSampleRecipes(Database db) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final samples = [
      {
        'title': 'Spaghetti Carbonara',
        'category': 'Pasta',
        'ingredients':
            '200g spaghetti\n100g pancetta\n2 large eggs\n50g pecorino cheese\n50g parmesan\nBlack pepper\nSalt',
        'instructions':
            '1. Cook spaghetti in salted boiling water until al dente.\n2. Fry pancetta in a pan until crispy.\n3. Whisk eggs with grated cheeses and pepper.\n4. Drain pasta, reserve some pasta water.\n5. Remove pan from heat, add pasta to pancetta.\n6. Add egg mixture and toss quickly.\n7. Add a splash of pasta water if too thick.\n8. Serve immediately with extra cheese.',
        'isFavorite': 0,
        'cookTime': '20 mins',
        'servings': '2',
        'createdAt': today,
      },
      {
        'title': 'Chicken Stir Fry',
        'category': 'Asian',
        'ingredients':
            '300g chicken breast\n2 tbsp soy sauce\n1 tbsp oyster sauce\n1 tsp sesame oil\n2 cloves garlic\n1 bell pepper\n1 cup broccoli\n2 tbsp vegetable oil\nSalt & pepper',
        'instructions':
            '1. Slice chicken into thin strips and season.\n2. Heat oil in a wok over high heat.\n3. Stir-fry chicken for 4–5 minutes until cooked.\n4. Add garlic and vegetables, stir-fry 3 minutes.\n5. Mix soy sauce, oyster sauce, and sesame oil.\n6. Pour sauce over chicken and vegetables.\n7. Toss well and cook for 1 more minute.\n8. Serve over steamed rice.',
        'isFavorite': 1,
        'cookTime': '25 mins',
        'servings': '3',
        'createdAt': today,
      },
      {
        'title': 'Classic Pancakes',
        'category': 'Breakfast',
        'ingredients':
            '1 cup all-purpose flour\n2 tbsp sugar\n1 tsp baking powder\n1/2 tsp baking soda\n1/4 tsp salt\n1 cup buttermilk\n1 egg\n2 tbsp melted butter',
        'instructions':
            '1. Mix dry ingredients in a bowl.\n2. Whisk buttermilk, egg, and butter together.\n3. Pour wet into dry ingredients and stir until just combined.\n4. Heat a griddle over medium heat and lightly grease.\n5. Pour 1/4 cup batter per pancake.\n6. Cook until bubbles form on surface, about 2 minutes.\n7. Flip and cook another 1–2 minutes.\n8. Serve with maple syrup and butter.',
        'isFavorite': 0,
        'cookTime': '15 mins',
        'servings': '4',
        'createdAt': today,
      },
    ];

    for (final recipe in samples) {
      await db.insert(_tableName, recipe);
    }
  }

  // ── Console logger ─────────────────────────────────────────────────────────

  Future<void> _logTable(String event) async {
    if (!kDebugMode) return;
    final db = await database;
    final rows = await db.query(_tableName, orderBy: 'id ASC');

    final sep = '─' * 80;
    debugPrint('\n╔$sep');
    debugPrint('║  🗄  DB CHANGE  ▸  $event');
    debugPrint('║  Total rows: ${rows.length}');
    debugPrint('╠$sep');

    if (rows.isEmpty) {
      debugPrint('║  (empty table)');
    } else {
      for (final r in rows) {
        final fav  = r['isFavorite'] == 1 ? '❤️ ' : '♡  ';
        final time = r['cookTime'] ?? '-';
        final srv  = r['servings'] ?? '-';
        final date = r['createdAt'] ?? '-';
        debugPrint(
          '║  [${r['id']}] $fav ${r['title']} '
          '(${r['category']})  ⏱ $time  👥 $srv  📅 $date',
        );
      }
    }
    debugPrint('╚$sep\n');
  }

  Future<void> _logCategories(String event) async {
    if (!kDebugMode) return;
    final db = await database;
    final rows = await db.query(_categoryTable, orderBy: 'id ASC');

    final sep = '─' * 60;
    debugPrint('\n╔$sep');
    debugPrint('║  🏷  CATEGORIES  ▸  $event');
    debugPrint('║  Total: ${rows.length}');
    debugPrint('╠$sep');
    for (final r in rows) {
      debugPrint('║  [${r['id']}]  ${r['name']}');
    }
    debugPrint('╚$sep\n');
  }

  // ── Recipe CRUD ────────────────────────────────────────────────────────────

  Future<int> insertRecipe(Recipe recipe) async {
    final db = await database;
    final map = recipe.toMap()..remove('id');
    final id = await db.insert(_tableName, map);
    await _logTable('INSERT  "${recipe.title}"');
    return id;
  }

  Future<List<Recipe>> getAllRecipes() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'title ASC');
    return maps.map((m) => Recipe.fromMap(m)).toList();
  }

  Future<List<Recipe>> getFavoriteRecipes() async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'title ASC',
    );
    return maps.map((m) => Recipe.fromMap(m)).toList();
  }

  Future<Recipe?> getRecipeById(int id) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return Recipe.fromMap(maps.first);
    return null;
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'title LIKE ? OR category LIKE ? OR ingredients LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'title ASC',
    );
    return maps.map((m) => Recipe.fromMap(m)).toList();
  }

  Future<int> updateRecipe(Recipe recipe) async {
    final db = await database;
    final affected = await db.update(
      _tableName,
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
    await _logTable('UPDATE  id=${recipe.id}  "${recipe.title}"');
    return affected;
  }

  Future<int> toggleFavorite(int id, int currentValue) async {
    final db = await database;
    final newVal = currentValue == 1 ? 0 : 1;
    final affected = await db.update(
      _tableName,
      {'isFavorite': newVal},
      where: 'id = ?',
      whereArgs: [id],
    );
    await _logTable(
        'TOGGLE FAVORITE  id=$id  →  ${newVal == 1 ? '❤️  favorited' : '♡  unfavorited'}');
    return affected;
  }

  Future<int> deleteRecipe(int id) async {
    final db = await database;
    final affected = await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    await _logTable('DELETE  id=$id');
    return affected;
  }

  // ── Category CRUD ──────────────────────────────────────────────────────────

  Future<int> insertCategory(Category category) async {
    final db = await database;
    final id = await db.insert(
      _categoryTable,
      {'name': category.name},
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    await _logCategories('INSERT  "${category.name}"');
    return id;
  }

  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final maps = await db.query(_categoryTable, orderBy: 'name ASC');
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    final affected = await db.update(
      _categoryTable,
      {'name': category.name},
      where: 'id = ?',
      whereArgs: [category.id],
    );
    await _logCategories('UPDATE  id=${category.id}  "${category.name}"');
    return affected;
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    final affected = await db.delete(
      _categoryTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    await _logCategories('DELETE  id=$id');
    return affected;
  }

  /// Returns how many recipes currently use this category name.
  Future<int> countRecipesInCategory(String name) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE category = ?', [name]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ── Stats queries ──────────────────────────────────────────────────────────

  Future<int> getTotalCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getFavoritesCount() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE isFavorite = 1');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Map<String, int>> getCategoryBreakdown() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT category, COUNT(*) as count FROM $_tableName GROUP BY category ORDER BY count DESC');
    final Map<String, int> breakdown = {};
    for (final row in result) {
      breakdown[row['category'] as String] = row['count'] as int;
    }
    return breakdown;
  }

  Future<double> getAvgIngredientCount() async {
    final db = await database;
    final maps = await db.query(_tableName, columns: ['ingredients']);
    if (maps.isEmpty) return 0;
    final total = maps.fold<int>(
        0,
        (sum, row) =>
            sum +
            (row['ingredients'] as String)
                .split('\n')
                .where((s) => s.trim().isNotEmpty)
                .length);
    return total / maps.length;
  }

  Future<int> getWithCookTimeCount() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE cookTime IS NOT NULL AND cookTime != ""');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
