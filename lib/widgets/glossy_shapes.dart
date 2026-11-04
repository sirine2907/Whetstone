import 'package:flutter/material.dart';

import '../theme.dart';

// A shiny ball. The radial gradient starts light at the top left, which makes
// it look lit from above, like a little 3D bubble.
class GlossyOrb extends StatelessWidget {
  const GlossyOrb({super.key, required this.size, this.child});

  final double size;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.35, -0.45),
          radius: 0.95,
          colors: [
            AppColors.orbHighlight,
            AppColors.orbPink,
            AppColors.orbMagenta,
            AppColors.orbViolet,
          ],
          stops: [0.0, 0.35, 0.72, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // A second, softer gradient on the bottom right edge looks like
          // light bouncing back, which makes the ball look round.
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(0.7, 0.8),
                radius: 0.6,
                colors: [
                  AppColors.orbViolet.withValues(alpha: 0.55),
                  AppColors.orbViolet.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          // The shiny spot near the top.
          Align(
            alignment: const Alignment(-0.38, -0.55),
            child: Container(
              width: size * 0.3,
              height: size * 0.2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.elliptical(size * 0.15, size * 0.1)),
                gradient: RadialGradient(
                  colors: [Colors.white.withValues(alpha: 0.7), Colors.white.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}

// A four pointed sparkle, drawn with curves that pinch in at the middle.
class GlossySparkle extends StatelessWidget {
  const GlossySparkle({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SparklePainter()),
    );
  }
}

class _SparklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // Each point of the star is a curve that bends towards the center.
    final path = Path()
      ..moveTo(w / 2, 0)
      ..quadraticBezierTo(w * 0.56, h * 0.44, w, h / 2)
      ..quadraticBezierTo(w * 0.56, h * 0.56, w / 2, h)
      ..quadraticBezierTo(w * 0.44, h * 0.56, 0, h / 2)
      ..quadraticBezierTo(w * 0.44, h * 0.44, w / 2, 0)
      ..close();

    final fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.orbHighlight, AppColors.orbPink, AppColors.orbViolet],
        stops: [0.0, 0.45, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawShadow(path, AppColors.orbMagenta.withValues(alpha: 0.5), w * 0.06, false);
    canvas.drawPath(path, fill);

    // A soft white shine on the top left part.
    final shine = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.3),
        radius: 0.4,
        colors: [Colors.white.withValues(alpha: 0.75), Colors.white.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: w / 2));
    canvas.drawPath(path, shine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
