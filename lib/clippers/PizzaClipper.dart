import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:ui';
import 'dart:math' as math;

class PizzaClipper extends CustomClipper<Path> {
  final int segments;
  final double radius;
  double padding = 0;

  PizzaClipper(this.segments, this.radius, {this.padding});

  @override
  Path getClip(Size size) {
    Path path = Path();
    double p1 = -radius * math.tan(math.pi / segments) + size.width / 2 + padding / 2;
    double p2 = size.width / 2 + radius * math.tan(math.pi / segments) - padding / 2;
    path.moveTo(size.width / 2, -radius + size.height); // move to center
    path.lineTo(p1, size.height);
    path.lineTo(p2, size.height);
    path.lineTo(size.width / 2, -radius + size.height);
    path.fillType = PathFillType.evenOdd;

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return oldClipper != this;
  }
}
