import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../constants/app_constants.dart';

/// Reusable stylized icon button with customizable background and size.
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final String? tooltip;
  final bool isCircle;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 44.0,
    this.iconSize = AppConstants.iconSizeMd,
    this.tooltip,
    this.isCircle = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppColors.surfaceElevated;
    final effectiveIconColor = iconColor ?? AppColors.textPrimary;

    Widget button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveBg,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : AppConstants.borderRadiusMd,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: isCircle
              ? const CircleBorder()
              : const RoundedRectangleBorder(borderRadius: AppConstants.borderRadiusMd),
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: effectiveIconColor,
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
