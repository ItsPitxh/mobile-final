import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/category.dart';
import '../providers/category_provider.dart';
import '../providers/recipe_provider.dart';
import '../utils/category_colors.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  // ── Add / Edit bottom sheet ────────────────────────────────────────────────

  void _showCategorySheet(BuildContext context, {Category? existing}) {
    final controller = TextEditingController(text: existing?.name ?? '');
    final isEditing  = existing != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  isEditing ? 'Edit Category' : 'New Category',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Category name',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: const Color(0xFFF8F4EF),
                    prefixIcon: const Icon(Icons.label_rounded,
                        color: Color(0xFF5C3D8F)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFF5C3D8F), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: Icon(
                      isEditing ? Icons.check_rounded : Icons.add_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      isEditing ? 'Save Changes' : 'Add Category',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C3D8F),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      Navigator.pop(sheetCtx);
                      final provider =
                          context.read<CategoryProvider>();

                      final error = isEditing
                          ? await provider.updateCategory(
                              existing!, controller.text)
                          : await provider.addCategory(controller.text);

                      if (error != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error),
                            backgroundColor: Colors.red.shade600,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEditing
                                ? 'Category updated!'
                                : 'Category added!'),
                            backgroundColor: const Color(0xFF5C3D8F),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Delete confirmation dialog ─────────────────────────────────────────────

  void _confirmDelete(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Category'),
        content: Text(
            'Delete "${category.name}"? Recipes using this category will keep their existing value.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final error = await context
                  .read<CategoryProvider>()
                  .deleteCategory(category);
              if (error != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EF),
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF5C3D8F),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Categories',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF5C3D8F), Color(0xFF9C6FD6)],
                  ),
                ),
                child: const Align(
                  alignment: Alignment(0.85, 0.2),
                  child: Icon(Icons.label_rounded,
                      size: 90, color: Colors.white12),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: provider.loadCategories,
              ),
            ],
          ),

          // Body
          if (provider.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF5C3D8F)),
              ),
            )
          else if (provider.categories.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.label_off_rounded,
                        size: 72, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'No categories yet.\nTap + to add one.',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = provider.categories[index];
                    final color =
                        CategoryColors.colorFor(category.name);
                    final icon =
                        CategoryColors.iconFor(category.name);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          // Tap the row to filter recipes by this category
                          onTap: () {
                            context
                                .read<RecipeProvider>()
                                .setCategoryFilter(category.name);
                            Navigator.pop(context);
                          },
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: color, size: 22),
                          ),
                          title: Text(
                            category.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          subtitle: Text(
                            'Tap to filter recipes',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Edit
                              IconButton(
                                icon: Icon(Icons.edit_rounded,
                                    color: Colors.grey.shade500,
                                    size: 20),
                                onPressed: () => _showCategorySheet(
                                    context,
                                    existing: category),
                                tooltip: 'Edit',
                              ),
                              // Delete
                              IconButton(
                                icon: const Icon(Icons.delete_rounded,
                                    color: Colors.red, size: 20),
                                onPressed: () =>
                                    _confirmDelete(context, category),
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: provider.categories.length,
                ),
              ),
            ),
        ],
      ),

      // FAB — add new category
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategorySheet(context),
        backgroundColor: const Color(0xFF5C3D8F),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Category',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
