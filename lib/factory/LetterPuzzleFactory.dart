import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';

import 'package:rotatingtest/helpers/RandomHelper.dart';
import 'package:rotatingtest/helpers/WordManager.dart';

import '../models/RingPuzzleModel.dart';
import 'PuzzleFactory.dart';

class LetterPuzzleFactory implements PuzzleFactory {
  @override
  Future<RingPuzzleModel> randomPuzzle(int ringCount, int segmentCount) async {
    debugPrint("randomPuzzle");
    var centerLetter = RandomHelper.getRandomString(1);
    List<String> rings = new List.generate(ringCount, (index) => RandomHelper.getRandomString(segmentCount));
    rings.forEach(debugPrint);
    RingPuzzleModel m = new RingPuzzleModel(
        ringCount, segmentCount, centerLetter, (ringIndex, segmentIndex, id) => rings[ringIndex][segmentIndex]
    );

    for (int i = 0; i < 0; i++) {
      int id = RandomHelper.getRandomInt(0, ringCount * segmentCount);
      int segments = RandomHelper.getRandomInt(1, segmentCount - 1);
      debugPrint("rotate $id, segments $segments");
      m.rotateRing(id, segments * 2 * math.pi / segmentCount);
    }

    m.segmentsValueNotifiers.forEach((element) {
      m.initSegments.add(element.value.clone());
    });

    var possibleArrangements = allPossibilities(ringCount - 1, ringCount, segmentCount, rings, centerLetter);
    m.words = WordManager.findWords(possibleArrangements);
    m.words.forEach(debugPrint);

    return m;
  }

  static List<String> allPossibilities(int ringIndex, int ringCount, int segmentCount, List<String> rings, String centerLetter) {
    if (ringIndex < 0) {
      //check all words in this configuration
      return new List<String>()..add(centerLetter);
    }
    var result = new List<String>();
    var p = allPossibilities(ringIndex-1, ringCount, segmentCount, rings, centerLetter);
    for (int s = 0; s < segmentCount; s++) {
      var mirror = (s + segmentCount / 2).floor() % segmentCount;
      var ring = rings[ringIndex];
      result.addAll(p.map((e) => ring[s] + e + ring[mirror]));
    }
    return result;
  }

}