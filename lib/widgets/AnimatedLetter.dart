import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'BorderedLetter.dart';

class AnimatedLetter extends StatefulWidget {
  final AnimationController controller;
  final String letter;

  AnimatedLetter(this.controller, this.letter);

  @override
  _AnimatedLetterState createState() => _AnimatedLetterState();
}

class _AnimatedLetterState extends State<AnimatedLetter> {
  Animation<double> scaleUpAnimation;
  Animation<double> scaleDownAnimation;
  Animation<double> rotateAnimation1;
  Animation<double> rotateAnimation2;
  Animation<double> rotateAnimation3;
  double scale = 1.2;
  double angle = math.pi / 32;

  @override
  void initState() {
    super.initState();
    scaleUpAnimation = Tween<double>(begin: 1.0, end: scale).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(
          0.0,
          0.8,
          curve: Cubic(0.25, 0.46, 0.45, 0.94),
        ),
      ),
    );
    scaleDownAnimation = Tween<double>(begin: 1.0, end: 1.0 / scale).animate(
        CurvedAnimation(
          parent: widget.controller,
          curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
        )
    );
    rotateAnimation1 = Tween<double>(begin: 0, end: angle).animate(
        CurvedAnimation(
          parent: widget.controller,
          curve: const Interval(0.0, 0.2, curve: Curves.bounceInOut),
        )
    );
    rotateAnimation2 = Tween<double>(begin: angle, end: -angle).animate(
        CurvedAnimation(
          parent: widget.controller,
          curve: const Interval(0.2, 0.4, curve: Curves.bounceInOut),
        )
    );
    rotateAnimation3 = Tween<double>(begin: -angle, end: 0).animate(
        CurvedAnimation(
          parent: widget.controller,
          curve: const Interval(0.4, 0.6, curve: Curves.bounceInOut),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: widget.controller,
        child: BorderedLetter(widget.letter),
        builder: (context, child) {
          return Transform(
              transform: Matrix4.identity()
                ..scale(scaleDownAnimation.value)..scale(scaleUpAnimation.value)
                ..rotateZ(rotateAnimation1.value)..rotateZ(rotateAnimation2.value)..rotateZ(rotateAnimation3.value),
              child: child
          );
        }
    );
  }
}
