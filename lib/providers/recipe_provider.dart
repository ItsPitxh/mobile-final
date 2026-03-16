import 'package:flutter/foundation.dart';
import '../model/recipe.dart';
import '../services/database/database_helper.dart';

enum RecipeFilter { all, favorites }

enum RecipeSort {
  nameAZ,
  nameZA,
  categoryAZ,
  newest,
  oldest,
}

extension RecipeSortLabel on RecipeSort {
  String get label {
    switch (this) {
      case RecipeSort.nameAZ:     return 'Name (A → Z)';
      case RecipeSort.nameZA:     return 'Name (Z → A)';
      case RecipeSort.categoryAZ: return 'Category';
      case RecipeSort.newest:     return 'Newest';
      case RecipeSort.oldest:     return 'Oldest';
    }
  }
}

class RecipeProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Recipe> _recipes = [];
  List<Recipe> _filteredRecipes = [];
  RecipeFilter _currentFilter = RecipeFilter.all;
  RecipeSort _currentSort = RecipeSort.newest;
  String _searchQuery = '';
  String? _categoryFilter;
  bool _isLoading = false;

  // Getters
  List<Recipe> get recipes => _filteredRecipes;
  RecipeFilter get currentFilter => _currentFilter;
  RecipeSort get currentSort => _currentSort;
  String get searchQuery => _searchQuery;
  String? get categoryFilter => _categoryFilter;
  bool get isLoading => _isLoading;

  RecipeProvider() {
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    _isLoading = true;
    notifyListeners();

    if (_currentFilter == RecipeFilter.favorites) {
      _recipes = await _dbHelper.getFavoriteRecipes();
    } else {
      _recipes = await _dbHelper.getAllRecipes();
    }

    _applySearchAndSort();
    _isLoading = false;
    notifyListeners();
  }

  void _applySearchAndSort() {
    // Start from all loaded recipes
    List<Recipe> result = List.from(_recipes);

    // Filter by category (from CategoryScreen tap)
    if (_categoryFilter != null) {
      result = result
          .where((r) =>
              r.category.toLowerCase() == _categoryFilter!.toLowerCase())
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((r) =>
              r.title.toLowerCase().contains(q) ||
              r.category.toLowerCase().contains(q) ||
              r.ingredients.toLowerCase().contains(q))
          .toList();
    }

    // Apply sort
    switch (_currentSort) {
      case RecipeSort.nameAZ:
        result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case RecipeSort.nameZA:
        result.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
      case RecipeSort.categoryAZ:
        result.sort((a, b) => a.category.toLowerCase().compareTo(b.category.toLowerCase()));
        break;
      case RecipeSort.newest:
        // ISO-8601 strings sort lexicographically — newest date first.
        result.sort((a, b) =>
            (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
        break;
      case RecipeSort.oldest:
        result.sort((a, b) =>
            (a.createdAt ?? '').compareTo(b.createdAt ?? ''));
        break;
    }

    _filteredRecipes = result;
  }

  void setFilter(RecipeFilter filter) {
    _categoryFilter = null; // clear category filter when switching tabs
    if (_currentFilter != filter) {
      _currentFilter = filter;
      loadRecipes();
    } else {
      _applySearchAndSort();
      notifyListeners();
    }
  }

  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    _currentFilter = RecipeFilter.all; // always show all recipes base
    loadRecipes();
  }

  void setSortOrder(RecipeSort sort) {
    if (_currentSort != sort) {
      _currentSort = sort;
      _applySearchAndSort();
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applySearchAndSort();
    notifyListeners();
  }

  Future<void> addRecipe(Recipe recipe) async {
    await _dbHelper.insertRecipe(recipe);
    await loadRecipes();
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await _dbHelper.updateRecipe(recipe);
    await loadRecipes();
  }

  Future<void> deleteRecipe(int id) async {
    await _dbHelper.deleteRecipe(id);
    await loadRecipes();
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    await _dbHelper.toggleFavorite(recipe.id!, recipe.isFavorite);
    await loadRecipes();
  }
}
