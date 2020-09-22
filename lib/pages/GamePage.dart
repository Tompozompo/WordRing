import 'package:flutter/material.dart';
import 'package:rotatingtest/background/SpaceBackground.dart';
import 'package:rotatingtest/factory/DatabasePuzzleFactory.dart';
import 'package:rotatingtest/routes/ScaleRoute.dart';
import 'package:rotatingtest/widgets/BorderedLetter.dart';
import 'package:rotatingtest/widgets/CustomDialog.dart';
import 'package:rotatingtest/widgets/WordsDisplay.dart';
import 'package:animated_background/animated_background.dart';

import '../widgets/RingPuzzle.dart';
import '../models/RingPuzzleModel.dart';

class GamePage extends StatefulWidget {
  final DatabasePuzzleFactory factory = new DatabasePuzzleFactory();
  final int puzzleId;

  GamePage(this.puzzleId);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  AnimationController _transformController;
  AnimationController _transitionController;
  AnimationController _centerController;
  Animation<double> _transition;
  RingPuzzleModel model;
  Future <RingPuzzleModel> modelFuture;

  @override
  void initState() {
    super.initState();
    _transformController = new AnimationController(
        duration: new Duration(milliseconds: 200),
        vsync: this
    );
    _transitionController = new AnimationController(
        duration: new Duration(seconds: 1),
        vsync: this
    );
    _centerController = new AnimationController(
        duration: new Duration(milliseconds: 500),
        vsync: this
    );
    _transition = CurvedAnimation(parent: _transitionController, curve: Curves.bounceInOut);
    modelFuture = widget.factory.getPuzzle(widget.puzzleId, _transformController, _centerController, _showEndDialog);
  }

  @override
  void dispose() {
    _transformController.dispose();
    _transitionController.dispose();
    model?.segmentsValueNotifiers?.forEach((element) => element.value.controller.dispose());
    super.dispose();
  }

  void _showPauseDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        useSafeArea: true,
        builder: (BuildContext context) {
          return CustomDialog(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                ),
                Spacer(),
                FractionallySizedBox(
                  widthFactor: 0.6,
                  child: FittedBox(
                      fit: BoxFit.contain,
                      child: BorderedLetter("Paused!")
                  ),
                ),
                Spacer(),
                FractionallySizedBox(
                  widthFactor: 0.6,
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
                            child: BorderedLetter('Quit')
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                ),
                Spacer(),
              ],
            ),
          );
        }
    );
  }

  void _showEndDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        useSafeArea: true,
        builder: (BuildContext context) {
          return CustomDialog(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    )
                ),
                FractionallySizedBox(
                  widthFactor: 0.6,
                  child: FittedBox(
                      fit: BoxFit.contain,
                      child: BorderedLetter("Great Job!")
                  ),
                ),
                Spacer(),
                FractionallySizedBox(
                  widthFactor: 0.6,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Icon(
                        Icons.sentiment_very_satisfied
                    ),
                  ),
                ),
                Spacer(),
                FractionallySizedBox(
                  widthFactor: 0.6,
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
                              child: BorderedLetter('Next')
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                            context,
                            ScaleRoute(page: GamePage(widget.puzzleId + 1))
                        );
                      }
                  ),
                ),
                Spacer(),
              ],
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    _transitionController.forward();
    return WillPopScope(
      onWillPop: () async {
        _showPauseDialog(); return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        body: AnimatedBackground(
          behaviour: RandomParticleBehaviour(
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
          child: FutureBuilder(
              future: modelFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  debugPrint("GamePage Done");
                  model = snapshot.data;
                  model.segmentsValueNotifiers.forEach((element) {
                    element.value.controller = new AnimationController(
                        duration: new Duration(milliseconds: 500),
                        vsync: this
                    );
                  });
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Stack(
                          children:[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: Icon(Icons.pause_circle_filled),
                                onPressed: () {
                                  _showPauseDialog();
                                },
                              ),
                            ),
                            Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: BorderedLetter("Puzzle ${widget.puzzleId}"),
                                )
                            ),
                          ]
                        ),
                        Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                                child: WordsDisplay(model)
                            )
                        ),
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                            ),
                            ScaleTransition(
                                scale: _transition,
                                child: RingPuzzle(model)
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: RaisedButton(
                                child: Icon(
                                    Icons.shuffle,
                                    color: Colors.white
                                ),
                                color: Theme
                                    .of(context)
                                    .primaryColor,
                                shape: CircleBorder(),
                                elevation: 2,
                                padding: EdgeInsets.all(10.0),
                                onPressed: () {
                                  model.shuffle();
                                },
                              ),
                            ),
                            Positioned(
                              left: 0,
                              bottom: 0,
                              child: RaisedButton(
                                child: Icon(
                                    Icons.zoom_in,
                                    color: Colors.white
                                ),
                                color: Theme
                                    .of(context)
                                    .primaryColor,
                                shape: CircleBorder(),
                                elevation: 2,
                                padding: EdgeInsets.all(10.0),
                                onPressed: () {
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                } else {
                  debugPrint("GamePage Loading");
                  return Center(child: CircularProgressIndicator());
                }
              }
          ),
        ),
      ),
    );
  }
}

