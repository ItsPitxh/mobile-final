import 'package:flutter/foundation.dart' hide Category;
import '../model/category.dart';
import '../services/database/database_helper.dart';

class CategoryProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories    => _categories;
  bool           get isLoading     => _isLoading;
  String?        get error         => _error;

  /// Convenience: just the names, used by the recipe form dropdown.
  List<String> get categoryNames =>
      _categories.map((c) => c.name).toList();

  CategoryProvider() {
    loadCategories();
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _categories = await _db.getAllCategories();
    _isLoading  = false;
    notifyListeners();
  }

  /// Returns null on success, or an error message string on failure.
  Future<String?> addCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Name cannot be empty.';

    final exists = _categories.any(
        (c) => c.name.toLowerCase() == trimmed.toLowerCase());
    if (exists) return '"$trimmed" already exists.';

    try {
      await _db.insertCategory(Category(name: trimmed));
      await loadCategories();
      return null;
    } catch (e) {
      return 'Failed to add category.';
    }
  }

  /// Returns null on success, or an error message string on failure.
  Future<String?> updateCategory(Category category, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return 'Name cannot be empty.';

    final conflict = _categories.any(
        (c) => c.id != category.id &&
               c.name.toLowerCase() == trimmed.toLowerCase());
    if (conflict) return '"$trimmed" already exists.';

    try {
      await _db.updateCategory(category.copyWith(name: trimmed));
      await loadCategories();
      return null;
    } catch (e) {
      return 'Failed to update category.';
    }
  }

  /// Returns null on success, or an error message if recipes still use it.
  Future<String?> deleteCategory(Category category) async {
    final count = await _db.countRecipesInCategory(category.name);
    if (count > 0) {
      return 'Cannot delete — $count recipe${count == 1 ? '' : 's'} '
             'still use "${category.name}".';
    }
    await _db.deleteCategory(category.id!);
    await loadCategories();
    return null;
  }
}
