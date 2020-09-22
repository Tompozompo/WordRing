import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'LetterSegment.dart';
import 'StaticCircle.dart';
import '../models/RingPuzzleModel.dart';
import '../models/RingSegmentValueNotifier.dart';

class RingPuzzle extends StatelessWidget {
  final RingPuzzleModel model;
  final GlobalKey containerKey = GlobalKey();

  RingPuzzle(this.model);

  List<Widget> _getSegments(double ringSize) {
    var circles = List<Widget>();
    for (int i = model.ringCount - 1; i >= 0; i--) {
      for (int j = model.segmentCount - 1; j >= 0; j--) {
        int id = i * model.segmentCount + j;
        RingSegmentValueNotifier segmentValueNotifier = model.segmentsValueNotifiers[id];
        circles.add(
            ValueListenableBuilder(
                valueListenable: segmentValueNotifier,
                builder: (context, segmentModel, child) {
                  return RingSegment(model, segmentModel, containerKey,
                      child: LetterSegment(segmentModel)
                  );
                }
            )
        );
      }
    }
    return circles;
  }

  List<Widget> _getRings(double ringSize) {
    var circles = List<Widget>();
    for (int i = model.ringCount - 1; i >= 0; i--) {
      int id = i * model.segmentCount;
      RingSegmentValueNotifier segmentValueNotifier = model.segmentsValueNotifiers[id];
      double lower = segmentValueNotifier.value.radius * math.cos(math.pi / model.segmentCount);
      double radius = (segmentValueNotifier.value.outerRadius + lower); // is actually / 2 for average, * 2 for diameter
      circles.add(
        Container (
          width: radius,
          height: radius,
          decoration: new BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
              shape: BoxShape.circle
          ),
        ),
      );
    }
    return circles;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;
          double radius = min(width, height) / 2;
          return FutureBuilder(
            future: model.setDimensions(radius),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                debugPrint("Done");
                return Stack(
                    overflow: Overflow.visible,
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                          key: containerKey,
                          width: model.radius * 2,
                          height: model.radius * 2,
                          decoration: new BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                          )
                      ),
                      Container(
                        width: model.radius * 2,
                        height: 1,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.5),
                        ),
                      ),
                      Container(
                        width: model.radius * 2,
                        height: model.ringSize,
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            vertical: BorderSide(
                              width: 1,
                              color: Colors.red.withOpacity(0.7)
                            ),
                          ),
                        ),
                      ),
                      StaticCircle(model.ringSize - model.padding, model.centerLetter, model.centerController),
//                      Transform.rotate(
//                        angle: math.pi / 2,
//                        child: ClipPath(
//                          clipper: PizzaClipper(model.segmentCount, radius, padding: 0),
//                          child: Container(
//                            height: radius * 2,
//                            width: radius * 2,
//                            decoration: BoxDecoration(
//                                boxShadow: [
//                                  BoxShadow(
//                                      color: Colors.yellow,
//                                      blurRadius: 100,
//                                      spreadRadius: 1
//                                  ),
//                                ],
//                                color: Colors.transparent
//                            ),
//                          ),
//                        ),
//                      ),
//                      Transform.rotate(
//                        angle: -math.pi / 2,
//                        child: ClipPath(
//                          clipper: PizzaClipper(model.segmentCount, radius, padding: 0),
//                          child: Container(
//                            height: radius * 2,
//                            width: radius * 2,
//                            decoration: BoxDecoration(
//                                boxShadow: [
//                                  BoxShadow(
//                                      color: Colors.yellow,
//                                      blurRadius: 100,
//                                      spreadRadius: 1
//                                  ),
//                                ],
//                                color: Colors.transparent,
//                            ),
//                          ),
//                        ),
//                      ),
                    ]..addAll(_getRings(model.ringSize)
                    )..addAll(_getSegments(model.ringSize)
                    )
                );
              } else {
                debugPrint("Loading");
                return Container(
                  width: 2*radius,
                  height: 2*radius,
                  child: Center(
                      child: CircularProgressIndicator()
                  )
                );
              }
            },
          );
        }
    );
  }
}

class RingSegment extends StatelessWidget {
  final RingPuzzleModel puzzleModel;
  final RingSegmentModel segmentModel;
  final GlobalKey containerKey;
  final Widget child;

  RingSegment(this.puzzleModel, this.segmentModel, this.containerKey, {this.child});

  @override
  Widget build(BuildContext context) {
    double lower = segmentModel.radius * math.cos(math.pi / puzzleModel.segmentCount);
    double avg = (segmentModel.outerRadius + lower) / 2;
    return Transform.translate(
        offset: Offset(0, avg),
        child: Transform.rotate(
          origin: Offset(0, -avg),
          angle: segmentModel.angle + math.pi / 2,
          child: GestureDetector(
              behavior: HitTestBehavior.opaque,
//            onLongPressStart: (details) => _longPressStart(context, details),
//            onLongPressMoveUpdate: (details) => _longPressUpdate(context, details),
//            onLongPressEnd: (details) => _longPressEnd(context, details),
              onPanStart: (details) => _panStart(context, details),
              onPanUpdate: (details) => _panUpdate(context, details),
              onPanEnd: (details) => _panEnd(context, details),
              onPanCancel: () => _panCancel(context),
              child: child
//              child: ClipPath(
//                clipper: PizzaClipper(puzzleModel.segmentCount, segmentModel.outerRadius, padding: 0),
//                  child: child
//              )
          ),
        )
    );
  }

  //#region Drag Events

  /*
  void _longPressStart(BuildContext context, LongPressStartDetails details) {
    RenderBox box = RingPuzzle.containerKey.currentContext.findRenderObject();
    Offset localPos = box.globalToLocal(details.globalPosition);
    puzzleModel.translationStart(localPos, id);
  }

  void _longPressUpdate(BuildContext context, LongPressMoveUpdateDetails details) {
    RenderBox box = RingPuzzle.containerKey.currentContext.findRenderObject();
    Offset localPos = box.globalToLocal(details.globalPosition);
    puzzleModel.translationUpdate(localPos);
  }

  void _longPressEnd(BuildContext context, LongPressEndDetails details) {
    puzzleModel.translationEnd(controller);
  }
  */

  void _panUpdate(BuildContext context, DragUpdateDetails details) {
    RenderBox box = containerKey.currentContext.findRenderObject();
    Offset localPos = box.globalToLocal(details.globalPosition);
    puzzleModel.rotationUpdate(localPos);
  }

  void _panStart(BuildContext context, DragStartDetails details) {
    RenderBox box = containerKey.currentContext.findRenderObject();
    Offset localPos = box.globalToLocal(details.globalPosition);
    puzzleModel.rotationStart(localPos, segmentModel.id);
  }

  void _panEnd(BuildContext context, DragEndDetails details) {
    puzzleModel.rotationEnd();
  }

  void _panCancel(BuildContext context) {
    puzzleModel.rotationCancel();
  }

  //#endregion Drag Events
}
