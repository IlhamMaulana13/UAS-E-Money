import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum AppButtonVariant { primary, dark, soft, ghost, outline, outlineWhite, white, danger, success }
enum AppButtonSize { lg, md, sm }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool fullWidth;
  final Widget? icon;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.lg,
    this.fullWidth = true,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final (height, fontSize, radius, px) = switch (size) {
      AppButtonSize.lg => (54.0, 16.0, 16.0, 20.0),
      AppButtonSize.md => (46.0, 15.0, 14.0, 16.0),
      AppButtonSize.sm => (38.0, 13.5, 11.0, 13.0),
    };

    final (bg, fg, shadow, border) = _resolveStyle();
    final disabled = onPressed == null;

    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: disabled || isLoading ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: height,
          width: fullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: px),
          decoration: BoxDecoration(
            gradient: variant == AppButtonVariant.primary ? AppColors.primaryGradient : null,
            color: variant != AppButtonVariant.primary ? bg : null,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: shadow,
            border: border,
          ),
          child: Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(fg),
                  ),
                ),
                const SizedBox(width: 9),
              ] else if (icon != null) ...[
                icon!,
                const SizedBox(width: 9),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: fg,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (Color, Color, List<BoxShadow>, Border?) _resolveStyle() {
    return switch (variant) {
      AppButtonVariant.primary => (
          AppColors.primary,
          Colors.white,
          AppColors.shadowPrimary,
          null,
        ),
      AppButtonVariant.dark => (AppColors.ink, Colors.white, [], null),
      AppButtonVariant.soft => (AppColors.primarySurface, AppColors.primary, [], null),
      AppButtonVariant.ghost => (Colors.transparent, AppColors.slate600, [], null),
      AppButtonVariant.outline => (
          Colors.white,
          AppColors.ink,
          [],
          Border.all(color: AppColors.line, width: 1.5),
        ),
      AppButtonVariant.outlineWhite => (
          Colors.transparent,
          Colors.white,
          [],
          Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1.5),
        ),
      AppButtonVariant.white => (
          Colors.white,
          AppColors.primary,
          [BoxShadow(color: Colors.black.withValues(alpha: 0.14), blurRadius: 20, offset: const Offset(0, 8))],
          null,
        ),
      AppButtonVariant.danger => (AppColors.red, Colors.white, [], null),
      AppButtonVariant.success => (AppColors.green, Colors.white, [], null),
    };
  }
}
