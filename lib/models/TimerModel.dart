import 'dart:async' show Timer;
import 'package:flutter/widgets.dart';

class TimerModel extends ChangeNotifier {
  Stopwatch timer = new Stopwatch();

  TimerModel() {
    timer.start();
    Timer.periodic(
        Duration(seconds: 1),
            (timer) => notifyListeners()
    );
  }

  void restart() {
    timer.reset();
    notifyListeners();
  }
}