import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme.dart';

// The soft gradient behind every screen, with two blurry color blobs.
class GlowBackground extends StatelessWidget {
  const GlowBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final glass = GlassColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blobStrength = isDark ? 0.35 : 0.55;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [glass.backgroundTop, glass.backgroundBottom],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _Blob(size: 260, color: AppColors.orbPink.withValues(alpha: blobStrength)),
          ),
          Positioned(
            bottom: 80,
            left: -100,
            child: _Blob(size: 280, color: AppColors.orbViolet.withValues(alpha: blobStrength)),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

// A frosted card: it blurs whatever is behind it and adds a white tint.
// Set solid to true for a plain white card, like a chat bubble.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 26,
    this.solid = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool solid;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final glass = GlassColors.of(context);
    final shape = BorderRadius.circular(radius);

    return ClipRRect(
      borderRadius: shape,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: solid ? glass.bubble : glass.glass,
          shape: RoundedRectangleBorder(
            borderRadius: shape,
            side: BorderSide(color: glass.glassBorder),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

// The round white buttons in the corners, like back or help.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 46,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final glass = GlassColors.of(context);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: glass.bubble,
        shape: CircleBorder(side: BorderSide(color: glass.glassBorder)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: size * 0.44, color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}

// Header for pushed screens: back button, small centered title, and an
// optional button on the right.
class GlassHeader extends StatelessWidget {
  const GlassHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          RoundIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          // Keeps the title centered when there is no button on the right.
          trailing ?? const SizedBox(width: 46),
        ],
      ),
    );
  }
}
