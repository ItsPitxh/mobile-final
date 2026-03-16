/// App-wide constant values shared across screens and widgets.
class AppConstants {
  AppConstants._();

  /// All supported recipe categories, in display order.
  static const List<String> categories = [
    'Breakfast', 'Pasta', 'Asian', 'Soup',
    'Salad', 'Seafood', 'Beef', 'Chicken', 'Dessert', 'Other',
  ];

  static const String defaultCategory = 'Other';
}
