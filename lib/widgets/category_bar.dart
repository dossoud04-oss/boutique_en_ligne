import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class CategoryBar extends StatelessWidget {
  final Function(String) onCategorySelected;
  final String? selectedCategory;

  const CategoryBar({
    super.key,
    required this.onCategorySelected,
    this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final categories = [
      {'name': 'Tous', 'icon': Icons.grid_view},
      {'name': 'Électronique', 'icon': Icons.phone_android},
      {'name': 'Vêtements', 'icon': Icons.checkroom},
      {'name': 'Maison', 'icon': Icons.home},
      {'name': 'Beauté', 'icon': Icons.spa},
    ];

    final iconSize = r.space(55);
    final width = r.space(75);

    return SizedBox(
      height: r.space(95),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: r.space(12)),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat['name'] == (selectedCategory ?? 'Tous');
          return GestureDetector(
            onTap: () => onCategorySelected(cat['name'] as String),
            child: Container(
              width: width,
              margin: EdgeInsets.symmetric(horizontal: r.space(4)),
              child: Column(
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: r.space(8),
                          offset: Offset(0, r.space(2)),
                        ),
                      ],
                    ),
                    child: Icon(
                      cat['icon'] as IconData,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      size: r.fontSize(24),
                    ),
                  ),
                  SizedBox(height: r.space(6)),
                  Text(
                    cat['name'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: r.fontSize(11),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
