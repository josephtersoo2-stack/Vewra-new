import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../constants/app_constants.dart';

enum AppCardVariant { standard, elevated, outlined, gradient }

/// Reusable surface container card with clean borders, gradients, and interactive ripple.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final AppCardVariant variant;
  final Color? backgroundColor;
  final BorderSide? border;
  final double? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.variant = AppCardVariant.standard,
    this.backgroundColor,
    this.border,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final double radius = borderRadius ?? AppConstants.radiusLg;
    final effectiveBorderRadius = BorderRadius.circular(radius);

    BoxDecoration decoration;

    switch (variant) {
      case AppCardVariant.standard:
        decoration = BoxDecoration(
          color: backgroundColor ?? AppColors.surface,
          borderRadius: effectiveBorderRadius,
          border: border != null
              ? Border.fromBorderSide(border!)
              : Border.all(color: AppColors.border, width: 1),
        );
        break;

      case AppCardVariant.elevated:
        decoration = BoxDecoration(
          color: backgroundColor ?? AppColors.surfaceElevated,
          borderRadius: effectiveBorderRadius,
          border: border != null
              ? Border.fromBorderSide(border!)
              : Border.all(color: AppColors.borderLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        );
        break;

      case AppCardVariant.outlined:
        decoration = BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: effectiveBorderRadius,
          border: border != null
              ? Border.fromBorderSide(border!)
              : Border.all(color: AppColors.border, width: 1.5),
        );
        break;

      case AppCardVariant.gradient:
        decoration = BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: effectiveBorderRadius,
          border: border != null
              ? Border.fromBorderSide(border!)
              : Border.all(color: AppColors.border, width: 1),
        );
        break;
    }

    Widget content = Container(
      margin: margin,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppConstants.space16),
            child: child,
          ),
        ),
      ),
    );

    return content;
  }
}
