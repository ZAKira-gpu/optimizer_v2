import 'package:flutter/material.dart';

/// Gradient background widget
///
/// Creates beautiful animated gradient backgrounds
/// perfect for glassmorphism designs.
class GradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground> {
  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? _getDefaultColors();

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: widget.begin,
          end: widget.end,
          colors: colors,
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: widget.child,
    );
  }

  List<Color> _getDefaultColors() {
    return [
      const Color(0xFF667eea), // Soft blue
      const Color(0xFF764ba2), // Purple
      const Color(0xFFf093fb), // Pink
      const Color(0xFFf5576c), // Coral
    ];
  }
}

/// Liquid glass specific gradient background
///
/// A specialized gradient background optimized for glassmorphism designs
/// with soft, pastel colors that work well with translucent elements.
class LiquidGlassBackground extends StatelessWidget {
  final Widget child;

  const LiquidGlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      colors: const [
        Color(0xFF2196F3), // Material Blue
        Color(0xFF1976D2), // Darker Blue
        Color(0xFF1565C0), // Even Darker Blue
        Color(0xFF0D47A1), // Deep Blue
      ],
      child: child,
    );
  }
}

/// Floating particles background
///
/// Adds subtle floating particles to enhance the glassmorphism effect
class FloatingParticlesBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final Color particleColor;
  final double particleSize;
  final Duration animationDuration;

  const FloatingParticlesBackground({
    super.key,
    required this.child,
    this.particleCount = 20,
    this.particleColor = Colors.white,
    this.particleSize = 4.0,
    this.animationDuration = const Duration(seconds: 8),
  });

  @override
  State<FloatingParticlesBackground> createState() =>
      _FloatingParticlesBackgroundState();
}

class _FloatingParticlesBackgroundState
    extends State<FloatingParticlesBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _particleControllers;
  late List<Animation<Offset>> _particleAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _particleControllers = List.generate(
      widget.particleCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 3000 + (index * 200)),
        vsync: this,
      ),
    );

    _particleAnimations = _particleControllers.asMap().entries.map((entry) {
      final index = entry.key;
      final controller = entry.value;
      return Tween<Offset>(
        begin: Offset((index % 3) * 0.33, (index % 2) * 0.5),
        end: Offset(((index + 1) % 3) * 0.33, ((index + 1) % 2) * 0.5),
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    _animationController.repeat();
    for (var controller in _particleControllers) {
      controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _particleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ...List.generate(widget.particleCount, (index) {
          return AnimatedBuilder(
            animation: _particleAnimations[index],
            builder: (context, child) {
              return Positioned(
                left:
                    MediaQuery.of(context).size.width *
                    _particleAnimations[index].value.dx,
                top:
                    MediaQuery.of(context).size.height *
                    _particleAnimations[index].value.dy,
                child: Opacity(
                  opacity: 0.1 + (index % 3) * 0.1,
                  child: Container(
                    width: widget.particleSize,
                    height: widget.particleSize,
                    decoration: BoxDecoration(
                      color: widget.particleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
