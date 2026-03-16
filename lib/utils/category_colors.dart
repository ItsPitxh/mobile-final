import 'package:flutter/material.dart';

/// Central lookup for category-specific color and icon.
/// Used by widgets and screens — no duplication needed.
class CategoryColors {
  CategoryColors._();

  static Color colorFor(String category) {
    switch (category.toLowerCase()) {
      case 'pasta':     return const Color(0xFFFFB74D);
      case 'asian':     return const Color(0xFF81C784);
      case 'breakfast': return const Color(0xFF64B5F6);
      case 'dessert':   return const Color(0xFFF48FB1);
      case 'soup':      return const Color(0xFF4DB6AC);
      case 'salad':     return const Color(0xFFA5D6A7);
      case 'seafood':   return const Color(0xFF4FC3F7);
      case 'beef':      return const Color(0xFFEF9A9A);
      case 'chicken':   return const Color(0xFFFFCC80);
      default:          return const Color(0xFFCE93D8);
    }
  }

  static IconData iconFor(String category) {
    switch (category.toLowerCase()) {
      case 'pasta':     return Icons.restaurant;
      case 'asian':     return Icons.ramen_dining;
      case 'breakfast': return Icons.free_breakfast;
      case 'dessert':   return Icons.cake;
      case 'soup':      return Icons.soup_kitchen;
      case 'salad':     return Icons.eco;
      case 'seafood':   return Icons.set_meal;
      case 'beef':
      case 'chicken':   return Icons.lunch_dining;
      default:          return Icons.fastfood;
    }
  }
}
