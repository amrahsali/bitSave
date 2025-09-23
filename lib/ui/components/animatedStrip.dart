import 'package:flutter/material.dart';

import '../common/app_colors.dart';

class AnimatedRedStrip extends StatefulWidget {
  @override
  _AnimatedRedStripState createState() => _AnimatedRedStripState();
}

class _AnimatedRedStripState extends State<AnimatedRedStrip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;

  @override
  void initState() {
    super.initState();

    /// 🔄 Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    /// 🎯 Moving the Red Strip Up & Down
    _positionAnimation = Tween<double>(begin: 0, end: 80).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _positionAnimation,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.only(top: _positionAnimation.value),
          child: Container(
            width: 5,
            height: 100, // Full height of banner
            decoration: BoxDecoration(
              color: Colors.deepOrangeAccent,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        );
      },
    );
  }
}
