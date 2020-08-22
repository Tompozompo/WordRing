import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../clippers/PizzaClipper.dart';
import '../models/RingSegmentValueNotifier.dart';

class ColorSegment extends StatelessWidget {
  final RingSegmentModel segmentModel;
  final int segmentCount;

  ColorSegment(this.segmentModel, this.segmentCount);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: PizzaClipper(segmentCount, segmentModel.radius, padding: 5),
//      shadow: Shadow (
//          color: Colors.black54,
//          offset: Offset(0, 10),
//          blurRadius: 5
//      ),
      child: Container(
          width: segmentModel.width > 0 ? segmentModel.width : 1,
          height: segmentModel.thickness > 0 ? segmentModel.thickness : 1,
          decoration: new BoxDecoration(
              color: segmentModel.data,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
                height: math.min(segmentModel.thickness, segmentModel.width) * 0.5 > 0 ? math.min(segmentModel.thickness, segmentModel.width) * 0.5 : 1,
                width: math.min(segmentModel.thickness, segmentModel.width) * 0.5 > 0 ? math.min(segmentModel.thickness, segmentModel.width) * 0.5 : 1,
                child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    child: Transform.rotate(
                      origin: Offset(0, 0),
                      angle: -segmentModel.angle,
                      child: Stack(
                        children: <Widget>[
                          // Stroked text as border.
                          Text(
                            segmentModel.id.toString(),
                            style: TextStyle(
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 1
                                ..color = Colors.black,
                            ),
                          ),
                          // Solid text as fill.
                          Text(
                            segmentModel.id.toString(),
                            style: TextStyle(
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    )
                )
            ),
          )
      ),
    );
  }
}
