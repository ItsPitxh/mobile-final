import 'package:flutter/material.dart';

/// Shared InputDecoration builders for form fields.
/// Keeps styling consistent and out of screen files.
class AppDecorations {
  AppDecorations._();

  static const Color _focusColor = Color(0xFFE8523A);

  static InputDecoration field(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: _focusColor, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      );

  /// Variant for multi-line expanding fields (no horizontal-only padding).
  static InputDecoration expandedField(String hint) =>
      field(hint).copyWith(
        contentPadding: const EdgeInsets.all(12),
        alignLabelWithHint: true,
      );
}
