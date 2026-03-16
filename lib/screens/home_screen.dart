import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_list_tile.dart';
import 'recipe_detail_screen.dart';
import 'category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EF),
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFE8523A),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'My Recipe Book',
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
                    colors: [Color(0xFFE8523A), Color(0xFFFF8A65)],
                  ),
                ),
                child: const Align(
                  alignment: Alignment(0.9, 0.2),
                  child: Icon(Icons.menu_book,
                      size: 80, color: Colors.white24),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => provider.loadRecipes(),
              ),
            ],
          ),

          // Search & Filter bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  // Search field
                  TextField(
                    controller: _searchController,
                    onChanged: provider.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search recipes...',
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                provider.setSearchQuery('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                            color: Color(0xFFE8523A), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Active category filter banner
                  if (provider.categoryFilter != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5C3D8F).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF5C3D8F).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.filter_list_rounded,
                              size: 16, color: Color(0xFF5C3D8F)),
                          const SizedBox(width: 8),
                          Text(
                            'Filtered: ${provider.categoryFilter}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5C3D8F),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () =>
                                provider.setCategoryFilter(null),
                            child: const Icon(Icons.close_rounded,
                                size: 18, color: Color(0xFF5C3D8F)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Filter chips
                  Row(
                    children: [
                      _FilterChip(
                        label: 'All Recipes',
                        icon: Icons.restaurant_menu,
                        selected: provider.currentFilter == RecipeFilter.all &&
                            provider.categoryFilter == null,
                        onTap: () {
                          provider.setCategoryFilter(null);
                          provider.setFilter(RecipeFilter.all);
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Favorites',
                        icon: Icons.favorite,
                        selected: provider.currentFilter ==
                            RecipeFilter.favorites,
                        onTap: () =>
                            provider.setFilter(RecipeFilter.favorites),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Categories',
                        icon: Icons.label_rounded,
                        selected: false,
                        activeColor: const Color(0xFF5C3D8F),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CategoryScreen()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Count label + Sort dropdown + View toggle
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  // Recipe count
                  Text(
                    '${provider.recipes.length} recipe${provider.recipes.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  // Sort dropdown
                  _SortDropdown(
                    current: provider.currentSort,
                    onChanged: provider.setSortOrder,
                  ),
                  const SizedBox(width: 8),
                  // Grid / List toggle
                  _ViewToggle(
                    isGridView: _isGridView,
                    onToggle: () =>
                        setState(() => _isGridView = !_isGridView),
                  ),
                ],
              ),
            ),
          ),

          // Content
          if (provider.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.recipes.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.no_food,
                        size: 72, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      provider.searchQuery.isNotEmpty
                          ? 'No recipes match "${provider.searchQuery}"'
                          : provider.currentFilter ==
                                  RecipeFilter.favorites
                              ? 'No favorite recipes yet'
                              : 'No recipes yet. Add one!',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else if (_isGridView)
            // --- GRID VIEW ---
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final recipe = provider.recipes[index];
                    return RecipeCard(
                      recipe: recipe,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RecipeDetailScreen(recipe: recipe),
                        ),
                      ).then((_) => provider.loadRecipes()),
                      onToggleFavorite: () =>
                          provider.toggleFavorite(recipe),
                    );
                  },
                  childCount: provider.recipes.length,
                ),
              ),
            )
          else
            // --- LIST VIEW ---
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final recipe = provider.recipes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: RecipeListTile(
                        recipe: recipe,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RecipeDetailScreen(recipe: recipe),
                          ),
                        ).then((_) => provider.loadRecipes()),
                        onToggleFavorite: () =>
                            provider.toggleFavorite(recipe),
                      ),
                    );
                  },
                  childCount: provider.recipes.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Sort Dropdown ─────────────────────────────────────────────────────────────

class _SortDropdown extends StatelessWidget {
  final RecipeSort current;
  final ValueChanged<RecipeSort> onChanged;

  const _SortDropdown({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<RecipeSort>(
          value: current,
          isDense: true,
          icon: Icon(Icons.sort_rounded,
              size: 16, color: Colors.grey.shade500),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
          items: RecipeSort.values.map((sort) {
            return DropdownMenuItem(
              value: sort,
              child: Text(sort.label),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }
}

// ── View Toggle Widget ────────────────────────────────────────────────────────

class _ViewToggle extends StatelessWidget {
  final bool isGridView;
  final VoidCallback onToggle;

  const _ViewToggle({required this.isGridView, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            icon: Icons.grid_view_rounded,
            active: isGridView,
            onTap: isGridView ? null : onToggle,
            tooltip: 'Grid view',
          ),
          Container(width: 1, height: 22, color: Colors.grey.shade200),
          _ToggleButton(
            icon: Icons.view_list_rounded,
            active: !isGridView,
            onTap: isGridView ? onToggle : null,
            tooltip: 'List view',
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback? onTap;
  final String tooltip;

  const _ToggleButton({
    required this.icon,
    required this.active,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFFE8523A)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 18,
            color: active ? Colors.white : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.activeColor = const Color(0xFFE8523A),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? activeColor : Colors.grey.shade300,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: selected
                    ? Colors.white
                    : Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
