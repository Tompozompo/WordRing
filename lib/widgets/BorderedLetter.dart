import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BorderedLetter extends StatelessWidget {
  final String letter;

  BorderedLetter(this.letter);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Stroked text as border.
        Text(
          letter,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = Colors.black,
          ),
        ),
        // Solid text as fill.
        Text(
          letter,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                  color: Colors.black54,
                  offset: Offset(1.0, 1.0),
                  blurRadius: 10.0
              )
            ],
          ),
        ),
      ],
    );
  }
}
