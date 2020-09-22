import 'package:flutter/animation.dart';

import '../models/RingPuzzleModel.dart';

abstract class PuzzleFactory {
   Future<RingPuzzleModel> randomPuzzle(int ringCount, int segmentCount, AnimationController transformController, AnimationController centerController);
}