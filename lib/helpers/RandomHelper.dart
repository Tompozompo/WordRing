import 'dart:math' as math;

class RandomHelper {
  static final math.Random _rnd = math.Random();

  static String getRandomString(int length) {
    var chars = 'AAAABCDEEEEFGHIIIIJKLMNOOOOPQRSTUUVWXYZ';
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(_rnd.nextInt(chars.length)))
    );
  }

  static int getRandomInt(int min, int max) {
    return min + _rnd.nextInt(max - min);
  }

  static double getRandomDouble(double max) {
    return max * _rnd.nextDouble();
  }
}