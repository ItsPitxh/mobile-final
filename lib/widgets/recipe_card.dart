import 'package:flutter/material.dart';
import '../model/recipe.dart';
import '../utils/category_colors.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final color = CategoryColors.colorFor(recipe.category);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category banner
            Container(
              height: 100,
              width: double.infinity,
              color: color.withOpacity(0.85),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      CategoryColors.iconFor(recipe.category),
                      size: 52,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onToggleFavorite,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          recipe.isFavorite == 1
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: recipe.isFavorite == 1
                              ? Colors.red
                              : Colors.grey,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info section
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      recipe.category,
                      style: TextStyle(
                        fontSize: 11,
                        color: color.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (recipe.cookTime != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 3),
                        Text(
                          recipe.cookTime!,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                        ),
                        if (recipe.servings != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.people,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 3),
                          Text(
                            'Serves ${recipe.servings}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
