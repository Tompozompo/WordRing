import 'dart:async';

import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:rotatingtest/background/SpaceBackground.dart';
import 'package:rotatingtest/models/RingPuzzleModel.dart';
import 'package:rotatingtest/pages/PuzzleListPage.dart';
import 'package:rotatingtest/routes/FadeRoute.dart';
import 'package:rotatingtest/routes/ScaleRoute.dart';
import 'package:rotatingtest/widgets/BorderedLetter.dart';
import 'package:rotatingtest/widgets/RingPuzzle.dart';

import 'GamePage.dart';

class MainMenu extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu> with TickerProviderStateMixin {
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
        2, 4, "", _transformController, null, (ringIndex, segmentIndex, id) => words[ringIndex][segmentIndex]
    );
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
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
        backgroundColor: const Color(0xFF000000),
        body: AnimatedBackground(
          behaviour: false ? SpaceBehaviour() : RandomParticleBehaviour(
            options: ParticleOptions(
              baseColor: Colors.white,
              spawnOpacity: 0.2,
              opacityChangeRate: 0.1,
              minOpacity: 0.2,
              maxOpacity: 0.5,
              spawnMinSpeed: 0.5,
              spawnMaxSpeed: 2.0,
              spawnMinRadius: 1.0,
              spawnMaxRadius: 1.5,
              particleCount: 100,
            ),
            paint: Paint()
              ..style = PaintingStyle.fill
              ..strokeWidth = 1.0,
          ),
          vsync: this,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Spacer(),
              Row(
                children: [
                  Spacer(),
                  Expanded(
                    flex: 6,
                    child: IgnorePointer(
                      child: RingPuzzle(_iconModel),
                    ),
                  ),
                  Spacer(),
                ],
              ),
              Spacer(flex: 2),
              Row(
                  children: <Widget>[
                    Spacer(),
                    Expanded(
                      flex: 3,
                      child: RaisedButton(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                          side: BorderSide(),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: SizedBox(
                            height: 50,
                            child: FittedBox(
                                fit: BoxFit.contain,
                                child: BorderedLetter('Play')
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(context, FadeRoute(
                          builder: (context) => GamePage(
                            1
                          )));
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
          ),
        )
    );
  }
}
