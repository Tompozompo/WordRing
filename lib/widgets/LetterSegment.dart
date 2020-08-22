import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rotatingtest/widgets/BorderedLetter.dart';

import '../models/RingSegmentValueNotifier.dart';
import 'AnimatedLetter.dart';

class LetterSegment extends StatelessWidget {
  final RingSegmentModel segmentModel;

  LetterSegment(this.segmentModel);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: segmentModel.width > 0 ? segmentModel.width : 1,
        height: segmentModel.thickness > 0 ? segmentModel.thickness : 1,
        decoration: new BoxDecoration(
          color: Colors.transparent,
//                color: widget.segmentModel.id.isEven ? model.boardColor1 : model.boardColor2,
//                shape: BoxShape.rectangle,
//                border: Border.all(color: Colors.blueAccent),
//                borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: Transform.rotate(
                origin: Offset(0, 0),
                angle: -segmentModel.angle - math.pi / 2,
                child: segmentModel.controller != null ? AnimatedLetter(
                    segmentModel.controller,
                    segmentModel.data)
                    : BorderedLetter(segmentModel.data)
            )
        )
    );
  }
}
