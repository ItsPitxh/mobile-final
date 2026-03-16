import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stats_provider.dart';
import '../utils/category_colors.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _touchedIndex = -1;

  // Collapsed state — all hidden by default except Overview
  bool _showFavRatio  = false;
  bool _showPieChart  = false;
  bool _showAppInfo   = false;

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EF),
      body: RefreshIndicator(
        color: const Color(0xFF5C3D8F),
        onRefresh: () => context.read<StatsProvider>().loadStats(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── App Bar ──────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF5C3D8F),
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Statistics',
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
                    child: Icon(Icons.pie_chart_rounded,
                        size: 90, color: Colors.white12),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () =>
                      context.read<StatsProvider>().loadStats(),
                ),
              ],
            ),

            if (stats.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF5C3D8F)),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    // ── Overview (always visible) ─────────────────────
                    const _SectionLabel(label: 'Overview'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            value: '${stats.totalRecipes}',
                            label: 'Total Recipes',
                            icon: Icons.menu_book_rounded,
                            color: const Color(0xFFE8523A),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            value: '${stats.totalFavorites}',
                            label: 'Favorites',
                            icon: Icons.favorite_rounded,
                            color: const Color(0xFFE91E8C),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            value: stats.avgIngredients.toStringAsFixed(1),
                            label: 'Avg Ingredients',
                            icon: Icons.shopping_basket_rounded,
                            color: const Color(0xFF43A047),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            value: '${stats.withCookTime}',
                            label: 'Have Cook Time',
                            icon: Icons.access_time_rounded,
                            color: const Color(0xFF1E88E5),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Favorites Ratio (collapsible) ─────────────────
                    _CollapsibleSection(
                      label: 'Favorites Ratio',
                      isExpanded: _showFavRatio,
                      onToggle: () =>
                          setState(() => _showFavRatio = !_showFavRatio),
                      child: _FavoritesRatioCard(
                        total: stats.totalRecipes,
                        favorites: stats.totalFavorites,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Recipes by Category (collapsible, pie chart) ──
                    _CollapsibleSection(
                      label: 'Recipes by Category',
                      isExpanded: _showPieChart,
                      onToggle: () =>
                          setState(() => _showPieChart = !_showPieChart),
                      child: stats.categoryBreakdown.isEmpty
                          ? const Center(
                              child: Padding(
                                padding:
                                    EdgeInsets.symmetric(vertical: 16),
                                child: Text('No recipes yet',
                                    style:
                                        TextStyle(color: Colors.grey)),
                              ),
                            )
                          : _CategoryPieCard(
                              breakdown: stats.categoryBreakdown,
                              total: stats.totalRecipes,
                              colorOf: CategoryColors.colorFor,
                              touchedIndex: _touchedIndex,
                              onTouch: (i) =>
                                  setState(() => _touchedIndex = i),
                            ),
                    ),

                    const SizedBox(height: 10),

                    // ── App Info (collapsible) ─────────────────────────
                    _CollapsibleSection(
                      label: 'App Info',
                      isExpanded: _showAppInfo,
                      onToggle: () =>
                          setState(() => _showAppInfo = !_showAppInfo),
                      child: _InfoCard(
                        items: [
                          _InfoRow(
                              icon: Icons.storage_rounded,
                              label: 'Storage',
                              value: 'Local SQLite DB'),
                          _InfoRow(
                              icon: Icons.architecture_rounded,
                              label: 'Architecture',
                              value: 'Provider + MVVM'),
                          _InfoRow(
                              icon: Icons.phone_android_rounded,
                              label: 'Platform',
                              value: 'Flutter (Android / iOS)'),
                          _InfoRow(
                              icon: Icons.category_rounded,
                              label: 'Categories',
                              value:
                                  '${stats.categoryBreakdown.length} in use'),
                          _InfoRow(
                              icon: Icons.info_outline_rounded,
                              label: 'Version',
                              value: '1.0.0'),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Collapsible Section ───────────────────────────────────────────────────────

class _CollapsibleSection extends StatelessWidget {
  final String label;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;

  const _CollapsibleSection({
    required this.label,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row — tap to toggle
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft:
                    Radius.circular(isExpanded ? 0 : 14),
                bottomRight:
                    Radius.circular(isExpanded ? 0 : 14),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5C3D8F),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.shade500,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Animated body
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Divider(
                    height: 1,
                    color: Colors.grey.shade100,
                    indent: 14,
                    endIndent: 14),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: child,
                ),
              ],
            ),
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 280),
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }
}

// ── Section Label (for Overview only) ────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF5C3D8F),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
      ],
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Favorites Ratio Card ──────────────────────────────────────────────────────

class _FavoritesRatioCard extends StatelessWidget {
  final int total;
  final int favorites;

  const _FavoritesRatioCard(
      {required this.total, required this.favorites});

  @override
  Widget build(BuildContext context) {
    final ratio   = total == 0 ? 0.0 : favorites / total;
    final percent = (ratio * 100).toStringAsFixed(0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite_rounded,
                    color: Color(0xFFE91E8C), size: 18),
                const SizedBox(width: 6),
                Text(
                  '$favorites of $total favorited',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E8C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$percent%',
                style: const TextStyle(
                  color: Color(0xFFE91E8C),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio.toDouble(),
            minHeight: 10,
            backgroundColor: Colors.grey.shade100,
            valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFE91E8C)),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _Legend(
                color: const Color(0xFFE91E8C), label: 'Favorited'),
            const SizedBox(width: 16),
            _Legend(
                color: Colors.grey.shade300,
                label: 'Not favorited'),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}

// ── Pie Chart Card ────────────────────────────────────────────────────────────

class _CategoryPieCard extends StatelessWidget {
  final Map<String, int> breakdown;
  final int total;
  final Color Function(String) colorOf;
  final int touchedIndex;
  final ValueChanged<int> onTouch;

  const _CategoryPieCard({
    required this.breakdown,
    required this.total,
    required this.colorOf,
    required this.touchedIndex,
    required this.onTouch,
  });

  @override
  Widget build(BuildContext context) {
    final entries = breakdown.entries.toList();

    final sections = entries.asMap().entries.map((e) {
      final i         = e.key;
      final entry     = e.value;
      final color     = colorOf(entry.key);
      final pct       = total == 0 ? 0.0 : entry.value / total * 100;
      final isTouched = i == touchedIndex;

      return PieChartSectionData(
        value: entry.value.toDouble(),
        color: color,
        radius: isTouched ? 72 : 60,
        title: isTouched ? '${pct.toStringAsFixed(0)}%' : '',
        titleStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
        ),
        badgeWidget: isTouched
            ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Text(
                  entry.key,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color),
                ),
              )
            : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();

    return Column(
      children: [
        // Donut chart
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 54,
                  sectionsSpace: 3,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        onTouch(-1);
                        return;
                      }
                      onTouch(response
                          .touchedSection!.touchedSectionIndex);
                    },
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  Text(
                    'recipes',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        Divider(height: 1, color: Colors.grey.shade100),
        const SizedBox(height: 14),

        // Legend chips
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: entries.asMap().entries.map((e) {
            final i      = e.key;
            final entry  = e.value;
            final color  = colorOf(entry.key);
            final pct    = total == 0
                ? '0%'
                : '${(entry.value / total * 100).toStringAsFixed(0)}%';
            final isActive = i == touchedIndex;

            return GestureDetector(
              onTap: () => onTouch(isActive ? -1 : i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? color.withOpacity(0.15)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? color
                        : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isActive
                            ? color
                            : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      pct,
                      style: TextStyle(
                        fontSize: 11,
                        color: isActive
                            ? color
                            : Colors.grey.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> items;
  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.asMap().entries.map((e) {
        final isLast = e.key == items.length - 1;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Icon(e.value.icon,
                      size: 20, color: const Color(0xFF5C3D8F)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e.value.label,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    e.value.value,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            if (!isLast)
              Divider(
                  height: 1,
                  indent: 32,
                  color: Colors.grey.shade100),
          ],
        );
      }).toList(),
    );
  }
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});
}
