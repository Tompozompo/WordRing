import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:ui';

class CircleClipper extends CustomClipper<Rect> {
  final double innerRadius;
  final double outerRadius;

  CircleClipper(this.innerRadius, this.outerRadius);

  @override
  Rect getClip(Size size) {
    return new Rect.fromCircle(
        center: new Offset(size.width / 2, -outerRadius + size.height),
        radius: outerRadius
    );
  }

  @override
  bool shouldReclip(CircleClipper oldClipper) {
    return this != oldClipper;
  }
}

