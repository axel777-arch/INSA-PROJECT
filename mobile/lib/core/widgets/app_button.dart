import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outlined, text, destructive }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;
  final AppButtonVariant variant;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
    this.variant = AppButtonVariant.primary,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
  }) : variant = AppButtonVariant.outlined;

  const AppButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
  }) : variant = AppButtonVariant.text;

  const AppButton.destructive({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
  }) : variant = AppButtonVariant.destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color? buttonBg;
    Color? buttonFg;
    BorderSide? borderSide;

    switch (variant) {
      case AppButtonVariant.primary:
        buttonBg = isDark ? AppColors.primaryDarkTheme : AppColors.primary;
        buttonFg = isDark ? const Color(0xFF1B2E1D) : Colors.white;
        break;
      case AppButtonVariant.secondary:
        buttonBg = isDark ? AppColors.secondaryDarkTheme : AppColors.secondary;
        buttonFg = isDark ? const Color(0xFF1B2E1D) : Colors.white;
        break;
      case AppButtonVariant.outlined:
        buttonBg = Colors.transparent;
        buttonFg = isDark ? AppColors.primaryDarkTheme : AppColors.primary;
        borderSide = BorderSide(color: buttonFg, width: 2);
        break;
      case AppButtonVariant.text:
        buttonBg = Colors.transparent;
        buttonFg = isDark ? AppColors.primaryDarkTheme : AppColors.primary;
        break;
      case AppButtonVariant.destructive:
        buttonBg = AppColors.error;
        buttonFg = Colors.white;
        break;
    }

    final VoidCallback? activeOnPressed = isLoading ? null : onPressed;

    Widget buttonChild;
    if (isLoading) {
      buttonChild = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(buttonFg),
        ),
      );
    } else {
      final textWidget = Text(label);
      if (icon != null) {
        buttonChild = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppSizes.iconSmall + 2),
            const SizedBox(width: AppSizes.p8),
            textWidget,
          ],
        );
      } else {
        buttonChild = textWidget;
      }
    }

    Widget innerButton;
    if (variant == AppButtonVariant.outlined) {
      innerButton = OutlinedButton(
        onPressed: activeOnPressed,
        style: OutlinedButton.styleFrom(
          side: borderSide,
          foregroundColor: buttonFg,
          minimumSize: Size(
            isFullWidth ? double.infinity : 0,
            AppSizes.buttonHeight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12),
          ),
        ),
        child: buttonChild,
      );
    } else if (variant == AppButtonVariant.text) {
      innerButton = TextButton(
        onPressed: activeOnPressed,
        style: TextButton.styleFrom(
          foregroundColor: buttonFg,
          minimumSize: Size(
            isFullWidth ? double.infinity : 0,
            AppSizes.buttonHeightSmall,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12),
          ),
        ),
        child: buttonChild,
      );
    } else {
      innerButton = ElevatedButton(
        onPressed: activeOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBg,
          foregroundColor: buttonFg,
          disabledBackgroundColor: buttonBg.withValues(alpha: 0.5),
          disabledForegroundColor: buttonFg.withValues(alpha: 0.5),
          elevation: variant == AppButtonVariant.destructive ? 0 : 1,
          minimumSize: Size(
            isFullWidth ? double.infinity : 0,
            AppSizes.buttonHeight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12),
          ),
        ),
        child: buttonChild,
      );
    }

    return AnimatedSize(
      duration: AppSizes.dShort,
      child: innerButton,
    );
  }
}
