import 'package:flutter/material.dart';
import 'dart:ui';

/// Glassmorphism container widget
///
/// Creates a beautiful frosted glass effect with backdrop blur,
/// transparency, and subtle borders for modern UI design.
class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color borderColor;
  final double borderWidth;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassmorphismContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 20.0,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.borderColor = Colors.white,
    this.borderWidth = 1.0,
    this.gradient,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient:
                  gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(opacity),
                      Colors.white.withOpacity(opacity * 0.5),
                    ],
                  ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor.withOpacity(0.2),
                width: borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Glassmorphism input field
///
/// A specialized glassmorphism container for form inputs
/// with enhanced styling for better user experience.
class GlassmorphismInputField extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;

  const GlassmorphismInputField({
    super.key,
    required this.child,
    this.borderRadius = 15.0,
    this.blur = 8.0,
    this.opacity = 0.15,
    this.borderColor = Colors.white,
    this.borderWidth = 1.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphismContainer(
      borderRadius: borderRadius,
      blur: blur,
      opacity: opacity,
      borderColor: borderColor,
      borderWidth: borderWidth,
      padding: padding,
      child: child,
    );
  }
}

/// Glassmorphism button
///
/// A specialized glassmorphism container for buttons
/// with hover effects and enhanced visual appeal.
class GlassmorphismButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final bool isEnabled;

  const GlassmorphismButton({
    super.key,
    required this.child,
    this.onPressed,
    this.borderRadius = 15.0,
    this.blur = 8.0,
    this.opacity = 0.2,
    this.borderColor = Colors.white,
    this.borderWidth = 1.0,
    this.padding,
    this.isEnabled = true,
  });

  @override
  State<GlassmorphismButton> createState() => _GlassmorphismButtonState();
}

class _GlassmorphismButtonState extends State<GlassmorphismButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isEnabled
          ? (_) => _animationController.forward()
          : null,
      onTapUp: widget.isEnabled ? (_) => _animationController.reverse() : null,
      onTapCancel: widget.isEnabled
          ? () => _animationController.reverse()
          : null,
      onTap: widget.isEnabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassmorphismContainer(
              borderRadius: widget.borderRadius,
              blur: widget.blur,
              opacity: widget.isEnabled ? widget.opacity : widget.opacity * 0.5,
              borderColor: widget.isEnabled ? widget.borderColor : Colors.grey,
              borderWidth: widget.borderWidth,
              padding: widget.padding,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
