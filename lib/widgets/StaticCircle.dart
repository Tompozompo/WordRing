import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rotatingtest/widgets/BorderedLetter.dart';

import '../models/ThemeModel.dart';
import 'AnimatedLetter.dart';

class StaticCircle extends StatefulWidget {
  final double radius;
  final String letter;
  final AnimationController segmentController;

  StaticCircle(this.radius, this.letter, this.segmentController);

  @override
  _StaticCircleState createState() => _StaticCircleState();
}

class _StaticCircleState extends State<StaticCircle> with TickerProviderStateMixin {
  Animation<double> _glowRadius;
  Animation<Color> _glowColor;
  AnimationController _glowRadiusController;
  AnimationController _glowColorController;

  @override
  void initState() {
    super.initState();
    _glowRadiusController = new AnimationController(
        duration: new Duration(seconds: 5),
        vsync: this
    );
    _glowColorController = new AnimationController(
        duration: new Duration(minutes: 1),
        vsync: this
    );

    _glowRadius = Tween<double>(begin: 0, end: widget.radius).animate(_glowRadiusController);
    _glowRadiusController.repeat(reverse: true);
    _glowColor = ColorTween(begin: Colors.red, end: Colors.green)
        .animate(_glowColorController);
    _glowColorController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowRadiusController.dispose();
    _glowColorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
        builder: (context, model, child) {
          return AnimatedBuilder(
              animation: _glowColorController,
              child: Center(
                child: SizedBox(
                    height: widget.radius,
                    width: widget.radius,
                    child: FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        child: widget.segmentController != null ? AnimatedLetter(
                            widget.segmentController,
                            widget.letter) : BorderedLetter(widget.letter)
                    )
                ),
              ),
              builder: (context, child) {
                return Container(
                    width: 2 * widget.radius,
                    height: 2 * widget.radius,
                    decoration: new BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: _glowColor.value,
                            blurRadius: 2 * widget.radius,
                            spreadRadius: _glowRadius.value
                        ),
                      ],
                    ),
                    child: child
                );
              }
          );
        }
    );
  }
}

