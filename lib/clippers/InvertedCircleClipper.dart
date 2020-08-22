import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:ui';

class InvertedCircleClipper extends CustomClipper<Path> {
  final double innerRadius;
  final double outerRadius;

  InvertedCircleClipper(this.innerRadius, this.outerRadius);

  @override
  Path getClip(Size size) {
    return new Path()
      ..addOval(new Rect.fromCircle(
          center: new Offset(size.width / 2, -outerRadius + size.height),
          radius: innerRadius))
      ..addRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return oldClipper != this;
  }
}
