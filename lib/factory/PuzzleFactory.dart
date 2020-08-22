import '../models/RingPuzzleModel.dart';

abstract class PuzzleFactory {
   Future<RingPuzzleModel> randomPuzzle(int ringCount, int segmentCount);
}