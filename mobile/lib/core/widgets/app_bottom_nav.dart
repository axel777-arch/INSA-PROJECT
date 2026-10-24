import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../theme/app_colors.dart';

class AppNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const AppNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// Bottom navigation bar styled to match the reference design: flat icons
/// with a label underneath, the active item tinted green with a small
/// underline indicator beneath the label.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<AppNavItem> items;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = isDark
        ? AppColors.textSecondaryDarkTheme
        : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor == AppColors.background
            ? Colors.white
            : (isDark ? AppColors.surfaceDarkTheme : Colors.white),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDarkTheme : AppColors.divider,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.only(top: AppSizes.p8, bottom: AppSizes.p8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final selected = index == currentIndex;
            final color = selected ? activeColor : inactiveColor;

            return Expanded(
              child: InkWell(
                onTap: () => onTap(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selected ? item.selectedIcon : item.icon,
                      color: color,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: AppSizes.dShort,
                      height: 3,
                      width: selected ? 22 : 0,
                      decoration: BoxDecoration(
                        color: activeColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
