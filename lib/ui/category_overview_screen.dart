import 'package:flutter/material.dart';

/// A simple UI that shows:
/// - Four hard-coded group headers (coral bars)
/// - The category list beneath each group (tap to select)
///
/// Navigation is handled by `onCategorySelected`.

class CategoryOverviewScreen extends StatelessWidget {
  final void Function(String category) onCategorySelected;

  const CategoryOverviewScreen({
    super.key,
    required this.onCategorySelected,
  });

  // --- Group + Categories Map ---
  static const Map<String, List<String>> groups = {
    "Introduction": [
      "Core Words",
    ],
    "Eating Out": [
      "Dishes",
      "Drinks",
      "Snacks",
      "Descriptions",
      "Items",
      "Phrases",
    ],
    "Ingredients": [
      "Basics",
      "Vegetables",
      "Fruits",
      "Proteins",
      "Nuts & Seeds",
      "Rice, Noodles & Grains",
      "Herbs, Aromatics & Spices",
      "Sauces & Seasonings",
    ],
    "Extras": [
      "Numbers",
      "Dietary Requirements",
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        bottom: false,
        child: ListView(
          children: [
            const SizedBox(height: 12),

            // --- Back button ---
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 26),
                color: Colors.black87,
                onPressed: () => Navigator.pop(context),
              ),
            ),

            const SizedBox(height: 8),

            // --- All groups + category rows ---
            for (final entry in groups.entries) ...[
              _buildGroupHeader(entry.key),
              ...entry.value.map((cat) => _buildCategoryRow(context, cat)),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Coral group header ---
  Widget _buildGroupHeader(String title) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFF6B3D),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  // --- Tapable category row ---
  Widget _buildCategoryRow(BuildContext context, String category) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => onCategorySelected(category),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Text(
            category,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

