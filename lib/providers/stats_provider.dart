import 'package:flutter/foundation.dart';
import '../services/database/database_helper.dart';

class StatsProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  int _totalRecipes    = 0;
  int _totalFavorites  = 0;
  int _withCookTime    = 0;
  double _avgIngredients = 0;
  Map<String, int> _categoryBreakdown = {};
  bool _isLoading = true;

  // Getters
  int get totalRecipes      => _totalRecipes;
  int get totalFavorites    => _totalFavorites;
  int get withCookTime      => _withCookTime;
  double get avgIngredients => _avgIngredients;
  Map<String, int> get categoryBreakdown => _categoryBreakdown;
  bool get isLoading        => _isLoading;

  StatsProvider() {
    loadStats();
  }

  /// Called automatically by ChangeNotifierProxyProvider whenever
  /// RecipeProvider notifies (insert, update, delete, toggle).
  Future<void> loadStats() async {
    _isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _db.getTotalCount(),
      _db.getFavoritesCount(),
      _db.getWithCookTimeCount(),
      _db.getAvgIngredientCount(),
      _db.getCategoryBreakdown(),
    ]);

    _totalRecipes      = results[0] as int;
    _totalFavorites    = results[1] as int;
    _withCookTime      = results[2] as int;
    _avgIngredients    = results[3] as double;
    _categoryBreakdown = results[4] as Map<String, int>;
    _isLoading         = false;

    notifyListeners();
  }
}
