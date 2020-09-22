import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';

class TimeDisplay extends StatefulWidget {
  @override
  _TimeDisplayState createState() => _TimeDisplayState();
}

class _TimeDisplayState extends State<TimeDisplay> {
  Stopwatch _stopwatch = new Stopwatch();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _timer = Timer.periodic(
        Duration(seconds: 1),
            (timer) => setState(() { })
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
          Text(getTimerString())
      ],
    );
  }

  String getTimerString() {
    final f = new NumberFormat("00");
    String seconds = f.format(_stopwatch.elapsed.inSeconds % 60);
    String minutes = f.format(_stopwatch.elapsed.inMinutes % 60);
    return "$minutes:$seconds";
  }
}
