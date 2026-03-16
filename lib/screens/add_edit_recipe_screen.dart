import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/recipe.dart';
import '../providers/recipe_provider.dart';
import '../providers/category_provider.dart';
import '../utils/app_constants.dart';
import '../utils/app_decorations.dart';

class AddEditRecipeScreen extends StatefulWidget {
  final Recipe? recipe;

  const AddEditRecipeScreen({super.key, this.recipe});

  @override
  State<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _ingredientsController;
  late TextEditingController _instructionsController;
  late TextEditingController _cookTimeController;
  late TextEditingController _servingsController;

  String _selectedCategory = AppConstants.defaultCategory;
  DateTime _selectedDate   = DateTime.now();
  bool _isSaving = false;

  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    _titleController       = TextEditingController(text: r?.title ?? '');
    _ingredientsController = TextEditingController(text: r?.ingredients ?? '');
    _instructionsController= TextEditingController(text: r?.instructions ?? '');
    _cookTimeController    = TextEditingController(text: r?.cookTime ?? '');
    _servingsController    = TextEditingController(text: r?.servings ?? '');
    _selectedCategory      = r?.category ?? AppConstants.defaultCategory;
    // Parse stored date or default to today
    if (r?.createdAt != null) {
      try { _selectedDate = DateTime.parse(r!.createdAt!); } catch (_) {}
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFE8523A),
            onPrimary: Colors.white,
            onSurface: Color(0xFF2D2D2D),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final recipe = Recipe(
      id: widget.recipe?.id,
      title: _titleController.text.trim(),
      category: _selectedCategory,
      ingredients: _ingredientsController.text.trim(),
      instructions: _instructionsController.text.trim(),
      isFavorite: widget.recipe?.isFavorite ?? 0,
      cookTime: _cookTimeController.text.trim().isEmpty
          ? null : _cookTimeController.text.trim(),
      servings: _servingsController.text.trim().isEmpty
          ? null : _servingsController.text.trim(),
      createdAt: _selectedDate.toIso8601String().substring(0, 10),
    );

    final provider = context.read<RecipeProvider>();
    if (_isEditing) {
      await provider.updateRecipe(recipe);
    } else {
      await provider.addRecipe(recipe);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Recipe updated successfully!'
              : 'Recipe added successfully!'),
          backgroundColor: const Color(0xFFE8523A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Live category list from provider (falls back to AppConstants if empty)
    final categoryNames = context.watch<CategoryProvider>().categoryNames;
    final categories = categoryNames.isNotEmpty
        ? categoryNames
        : AppConstants.categories;
    // Ensure _selectedCategory is always a valid option
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.contains(AppConstants.defaultCategory)
          ? AppConstants.defaultCategory
          : categories.first;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8523A),
        foregroundColor: Colors.white,
        title: Text(
          _isEditing ? 'Edit Recipe' : 'New Recipe',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Row 1: Title + Category ──────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _FieldLabel(
                      label: 'Recipe Name',
                      child: TextFormField(
                        controller: _titleController,
                        decoration: AppDecorations.field('e.g. Spaghetti Carbonara'),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Required' : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child: _FieldLabel(
                      label: 'Category',
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: AppDecorations.field(''),
                        items: categories.map((cat) =>
                          DropdownMenuItem(value: cat, child: Text(cat)),
                        ).toList(),
                        onChanged: (val) => setState(() =>
                            _selectedCategory = val ?? AppConstants.defaultCategory),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Row 2: Cook Time + Servings ──────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _FieldLabel(
                      label: 'Cook Time',
                      child: TextFormField(
                        controller: _cookTimeController,
                        decoration: AppDecorations.field('e.g. 30 mins'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _FieldLabel(
                      label: 'Servings',
                      child: TextFormField(
                        controller: _servingsController,
                        decoration: AppDecorations.field('e.g. 4'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Row 3: Date picker ───────────────────────────────────
              _FieldLabel(
                label: 'Date',
                child: GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 16, color: Color(0xFFE8523A)),
                        const SizedBox(width: 8),
                        Text(
                          '${_selectedDate.day.toString().padLeft(2, '0')} / '
                          '${_selectedDate.month.toString().padLeft(2, '0')} / '
                          '${_selectedDate.year}',
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF2D2D2D)),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_drop_down_rounded,
                            color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Ingredients (fills half remaining space) ─────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LabelText(text: 'Ingredients', sub: 'one per line'),
                    const SizedBox(height: 5),
                    Expanded(
                      child: TextFormField(
                        controller: _ingredientsController,
                        decoration: AppDecorations.expandedField(
                            '200g spaghetti\n2 eggs\n...'),
                        expands: true,
                        maxLines: null,
                        minLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ── Instructions (fills half remaining space) ─────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LabelText(text: 'Instructions', sub: 'one step per line'),
                    const SizedBox(height: 5),
                    Expanded(
                      child: TextFormField(
                        controller: _instructionsController,
                        decoration: AppDecorations.expandedField(
                            '1. Boil water\n2. Cook pasta\n...'),
                        expands: true,
                        maxLines: null,
                        minLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Save Button ──────────────────────────────────────────
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveRecipe,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_rounded,
                          color: Colors.white),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : (_isEditing ? 'Update Recipe' : 'Save Recipe'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8523A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldLabel({required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF2D2D2D))),
          const SizedBox(height: 5),
          child,
        ],
      );
}

class _LabelText extends StatelessWidget {
  final String text;
  final String sub;
  const _LabelText({required this.text, required this.sub});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(text,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF2D2D2D))),
          const SizedBox(width: 5),
          Text('($sub)',
              style: TextStyle(
                  fontSize: 11, color: Colors.grey.shade500)),
        ],
      );
}
