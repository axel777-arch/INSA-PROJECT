import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import 'app_button.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String title;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const EmptyState({
    super.key,
    required this.message,
    this.title = 'No Data Found',
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppSizes.iconXLarge + 16,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSizes.p16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.p8),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: AppSizes.p24),
              SizedBox(
                width: 180,
                child: AppButton(
                  label: actionLabel!,
                  onPressed: onActionPressed,
                  isFullWidth: false,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
