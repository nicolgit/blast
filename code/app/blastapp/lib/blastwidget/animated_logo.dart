import 'package:flutter/material.dart';

class AnimatedLogo extends StatefulWidget {
  final double width;
  final double height;
  final String? assetPath;
  final Image? image;

  const AnimatedLogo({
    super.key,
    this.width = 120,
    this.height = 120,
    this.assetPath,
    this.image,
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo> with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _rotationAnimationController;
  late Animation<double> _logoAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the logo scale animation
    _logoAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeInOut,
    ));

    // Initialize the rotation animation (20 degrees = ~0.349 radians)
    _rotationAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: -0.349, // -20 degrees in radians
      end: 0.349, // +20 degrees in radians
    ).animate(CurvedAnimation(
      parent: _rotationAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start both animations
    _logoAnimationController.repeat(reverse: true);
    _rotationAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _rotationAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _logoAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value, // 20 degrees left and right
            child: widget.image ??
                Image(
                  image: AssetImage(widget.assetPath ?? 'assets/general/icon-v01.png'),
                  width: widget.width,
                  height: widget.height,
                ),
          ),
        );
      },
    );
  }
}
