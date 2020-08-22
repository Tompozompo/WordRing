import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rotatingtest/factory/LetterPuzzleFactory.dart';
import 'package:rotatingtest/models/RingPuzzleModel.dart';
import 'package:rotatingtest/widgets/RingPuzzle.dart';

import 'GamePage.dart';

import '../factory/PuzzleFactory.dart';
import '../models/TimerModel.dart';
import '../widgets/BrightnessToggle.dart';
import '../widgets/ColorPicker.dart';
import '../models/ThemeModel.dart';

class MainMenu extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu> with TickerProviderStateMixin {
  double ringCount = 3;
  double segmentCount = 8;
  PuzzleFactory factory = new LetterPuzzleFactory();
  AnimationController _transformController;
  RingPuzzleModel _iconModel;
  Timer timer;

  @override
  void initState() {
    _transformController = new AnimationController(
        duration: new Duration(milliseconds: 200),
        vsync: this
    );
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var words = ["OIRN", "WRDG"];
    _iconModel = new RingPuzzleModel(
        2, 4, "", (ringIndex, segmentIndex, id) => words[ringIndex][segmentIndex]
    );
    _iconModel.transformController = _transformController;
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      debugPrint("${t.tick}");
      if (t.tick % 4 == 1) {
        _iconModel.animatedRotateRing(0, -1);
      } else if (t.tick % 4 == 2) {
        _iconModel.animatedRotateRing(4, -1);
      } else if (t.tick % 4 == 3) {
        _iconModel.animatedRotateRing(0, 1);
      } else {
        _iconModel.animatedRotateRing(4, 1);
      }
    });
    return Scaffold(
        appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Theme
                .of(context)
                .scaffoldBackgroundColor,
            actions: <Widget>[
              BrightnessToggle(),
              ColorPicker(),
            ]
        ),
        body: Consumer<ThemeModel>(
            builder: (context, theme, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  IgnorePointer(
                    child: Container(
                        width: 300,
                        height: 300,
                      child: RingPuzzle(_iconModel, _transformController, null)
                    ),
                  ),
                  Slider.adaptive(
                    value: ringCount,
                    onChanged: (count) {
                      setState(() => ringCount = count);
                    },
                    divisions: 3,
                    min: 3,
                    max: 6,
                    label: '$ringCount',
                  ),
                  Slider.adaptive(
                    value: segmentCount,
                    onChanged: (count) {
                      setState(() => segmentCount = count);
                    },
                    divisions: 4,
                    min: 6,
                    max: 14,
                    label: '${segmentCount.round()}',
                  ),
                  Spacer(),
                  Row(
                      children: <Widget>[
                        Spacer(),
                        Expanded(
                          flex: 2,
                          child: RaisedButton(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                              side: BorderSide(),
                            ),
                            child: Text('Play',
                              style: Theme.of(context).textTheme.headline3
                            ),
                            onPressed: () {
                              Provider.of<TimerModel>(context, listen: false).restart();
                              factory.randomPuzzle(ringCount.round(), segmentCount.round()).then((value) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      return GamePage(value);
                                    })
                                );
                              });
                            },
                          ),
                        ),
                        Spacer(),
                      ]
                  ),
                  Spacer(
                    flex: 1,
                  ),
                ],
              );
            }
        )
    );
  }
}
