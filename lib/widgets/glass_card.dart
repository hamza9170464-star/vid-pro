import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color? color;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20.0,
    this.blur = 15.0,
    this.color,
    this.border,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fallbackColor = theme.brightness == Brightness.dark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.04);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color ?? fallbackColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ??
                Border.all(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.12)
                      : Colors.black.withOpacity(0.06),
                  width: 1.2,
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}
