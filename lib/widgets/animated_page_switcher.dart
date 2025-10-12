import 'package:flutter/material.dart';

class AnimatedPageSwitcher extends StatefulWidget {
  final List<Widget> children;
  final int currentIndex;
  final Duration duration;

  const AnimatedPageSwitcher({
    super.key,
    required this.children,
    required this.currentIndex,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedPageSwitcher> createState() => _AnimatedPageSwitcherState();
}

class _AnimatedPageSwitcherState extends State<AnimatedPageSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(AnimatedPageSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentIndex != widget.currentIndex) {
      setState(() {
        _previousIndex = widget.currentIndex;
      });
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.children[_previousIndex],
    );
  }
}
