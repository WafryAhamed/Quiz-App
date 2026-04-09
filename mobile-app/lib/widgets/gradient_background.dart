import 'package:flutter/material.dart';

/// Screen wrapper with gradient background
class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
    this.showDecorations = true,
  });

  final Widget child;
  final bool showDecorations;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF8FDFB),
            const Color(0xFFF0F9F4).withValues(alpha: 0.8),
            const Color(0xFFFCFDEF).withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          if (showDecorations) ...[
            // Top right decoration
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFB7E36D).withValues(alpha: 0.1),
                      const Color(0xFF6EDC8C).withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom left decoration
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF9FE870).withValues(alpha: 0.08),
                      const Color(0xFF6EDC8C).withValues(alpha: 0.04),
                    ],
                  ),
                ),
              ),
            ),
          ],
          child,
        ],
      ),
    );
  }
}
