import 'package:flutter/material.dart';
import '../model/recipe.dart';
import '../utils/category_colors.dart';

class RecipeListTile extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const RecipeListTile({
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
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Left color accent strip + icon
            Container(
              width: 56,
              height: 64,
              color: color.withOpacity(0.85),
              child: Center(
                child: Icon(
                  CategoryColors.iconFor(recipe.category),
                  size: 24,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF2D2D2D),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            recipe.category,
                            style: TextStyle(
                              fontSize: 10,
                              color: color.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (recipe.cookTime != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.access_time,
                              size: 10, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text(
                            recipe.cookTime!,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          ),
                        ],
                        if (recipe.servings != null) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.people,
                              size: 10, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text(
                            recipe.servings!,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Favorite button
            GestureDetector(
              onTap: onToggleFavorite,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  recipe.isFavorite == 1
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: recipe.isFavorite == 1 ? Colors.red : Colors.grey.shade300,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
