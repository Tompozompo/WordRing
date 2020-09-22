import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:rotatingtest/helpers/RandomHelper.dart';

import '../models/RingPuzzleModel.dart';
import 'PuzzleFactory.dart';

class ColorPuzzleFactory implements PuzzleFactory {
  static List<Color> rainbow = [Colors.blue, Colors.green, Colors.yellow, Colors.orange, Colors.red, Colors.purple];

  @override
  Future<RingPuzzleModel> randomPuzzle(int ringCount, int segmentCount, AnimationController transformController, AnimationController centerController) async {
    RingPuzzleModel m = new RingPuzzleModel(ringCount, segmentCount, "", transformController, centerController, (i, j, id) => rainbow[i]);

    for(int i = 0; i < 15; i++) {
      int id = RandomHelper.getRandomInt(0, ringCount * segmentCount);
      int which = RandomHelper.getRandomInt(0, 2);
      if(which.isEven) {
        int rings = RandomHelper.getRandomInt(1, ringCount - 1);
        debugPrint("translate $id, rings $rings");
        m.translate(id, rings * m.ringSize);
      } else {
        int segments = RandomHelper.getRandomInt(1, segmentCount - 1);
        debugPrint("rotate $id, segments $segments");
        m.rotateRing(id, segments * 2 * math.pi / segmentCount);
      }
    }

    m.segmentsValueNotifiers.forEach((element) {
      m.initSegments.add(element.value.clone());
    });

    return m;
  }

}

