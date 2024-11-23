import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mobile_app/Screens/get_started.dart';

class AnimationScreen extends StatefulWidget {
  const AnimationScreen({super.key});

  @override
  _AnimationScreenState createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeOutAnimation;
  bool _showGetStartedScreen = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    ); // Makes the animation loop infinitely

    // Fade-out animation starts at 80% of the animation timeline
    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Navigate to GetStartedScreen after animation and fading
    Timer(const Duration(seconds: 6), () {
      setState(() {
        _showGetStartedScreen = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Food animations and logo animation
          if (!_showGetStartedScreen)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeOutAnimation.value,
                  child: Stack(
                    children: [
                      _buildFoodItem(
                        screenSize,
                        'images/pizza.png',
                        Offset(0.2, 0.8),
                        rotate: true,
                      ),
                      _buildFoodItem(
                        screenSize,
                        'images/burger.png',
                        Offset(0.7, 0.5),
                        flowDirection: Axis.horizontal,
                      ),
                      _buildFoodItem(
                        screenSize,
                        'images/cupcake.png',
                        Offset(0.5, 0.2),
                        rotate: true,
                        flowDirection: Axis.vertical,
                      ),
                      _buildFoodItem(
                        screenSize,
                        'images/sushi.png',
                        Offset(0.3, 0.4),
                        scaleEffect: true,
                      ),
                      _buildFoodItem(
                        screenSize,
                        'images/fruits.png',
                        Offset(0.8, 0.6),
                        flowDirection: Axis.vertical,
                        rotate: true,
                      ),
                      Center(
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _controller,
                              curve: Curves.easeOut,
                            ),
                          ),
                          child: Image.asset(
                            'images/cookify.png',
                            height: 200,
                            width: 200,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          // Get Started Screen when transition finishes
          if (_showGetStartedScreen)
            const GetStartedScreen(), // Your target screen
        ],
      ),
    );
  }
  /// Helper method to create animated food items
  Widget _buildFoodItem(
    Size screenSize,
    String imagePath,
    Offset position, {
    bool rotate = false,
    Axis flowDirection = Axis.vertical,
    bool scaleEffect = false,
  }) {
    return Positioned(
      top: position.dy * screenSize.height,
      left: position.dx * screenSize.width,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          Widget animatedChild = child!;
          if (rotate) {
            animatedChild = Transform.rotate(
              angle: _controller.value * 2 * 3.14,
              child: child,
            );
          }
          if (scaleEffect) {
            animatedChild = Transform.scale(
              scale: 1 + 0.2 * (1 - _controller.value),
              child: child,
            );
          }
          return animatedChild;
        },
        child: Image.asset(
          imagePath,
          height: 100,
          width: 100,
        ),
      ),
    );
  }
}