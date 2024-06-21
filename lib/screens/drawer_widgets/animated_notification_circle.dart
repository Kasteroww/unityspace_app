import 'package:flutter/material.dart';

class AnimatedNotificationBadge extends StatefulWidget {
  const AnimatedNotificationBadge({super.key});

  @override
  State<AnimatedNotificationBadge> createState() =>
      _AnimatedNotificationBadgeState();
}

class _AnimatedNotificationBadgeState extends State<AnimatedNotificationBadge>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: const Duration(milliseconds: 750),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFEF4444),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
