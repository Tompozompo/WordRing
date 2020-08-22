import 'package:flutter/material.dart';
import 'package:rotatingtest/widgets/WordsDisplay.dart';

import '../widgets/RingPuzzle.dart';
import '../widgets/Timer.dart';
import '../models/RingPuzzleModel.dart';

class GamePage extends StatefulWidget {
  final RingPuzzleModel model;

  GamePage(this.model);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  AnimationController _transformController;
  AnimationController _transitionController;
  AnimationController _centerController;
  Animation<double> _transition;

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
    widget.model.segmentsValueNotifiers.forEach((element) {
      element.value.controller = new AnimationController(
          duration: new Duration(milliseconds: 500),
          vsync: this
      );
    });
    widget.model.transformController = _transformController;
    widget.model.centerController = _centerController;

    _transition = CurvedAnimation(parent: _transitionController, curve: Curves.bounceInOut);
  }

  @override
  void dispose() {
    _transformController.dispose();
    _transitionController.dispose();
    widget.model.segmentsValueNotifiers.forEach((element) => element.value.controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _transitionController.forward();
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Timer()
              ),
              Expanded(child: WordsDisplay(widget.model)),
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                  ),
                  ScaleTransition(
                      scale: _transition,
                      child: RingPuzzle(widget.model, _transformController, _centerController)
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
                        widget.model.shuffle();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

