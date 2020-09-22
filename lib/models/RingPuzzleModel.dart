import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rotatingtest/helpers/RandomHelper.dart';

import 'RingSegmentValueNotifier.dart';

class RingPuzzleModel {
  final int padding = 5;
  final _streamController = StreamController<List<String>>.broadcast();

  //Params
  final int ringCount;
  final int segmentCount;
  final String centerLetter;
  final AnimationController transformController;
  final AnimationController centerController;
  double radius;
  List<Function> endCallbacks = List<Function>();

  //State
  Queue<UndoSegment> undoQueue = Queue<UndoSegment>();
  List<RingSegmentModel> initSegments = List<RingSegmentModel>();
  List<RingSegmentValueNotifier> segmentsValueNotifiers = List<RingSegmentValueNotifier>();
  Set<String> words = Set<String>();
  Set<String> foundWords = Set<String>();

  //Rotation+Translation
  Animation<double> _animation;
  RingSegmentModel selectedSegment;
  List<OverflowSegment> overflowSegments = List<OverflowSegment>();
  List<OverflowSegment> underflowSegments = List<OverflowSegment>();
  double startingAngle;
  Offset startingOffset;

  RingPuzzleModel(this.ringCount, this.segmentCount, this.centerLetter, this.transformController, this.centerController, Function(int, int, int) getData) {
    for (int i = 0; i < ringCount; i++) {
      for (int j = 0; j < segmentCount; j++) {
        double angle = (j * 2 * math.pi / segmentCount);
        int id = i * segmentCount + j;
        segmentsValueNotifiers.add(RingSegmentValueNotifier(RingSegmentModel(id, angle, getData(i, j, id))));
      }
    }
    segmentsValueNotifiers.forEach((element) {
      initSegments.add(element.value.clone());
    });
  }

  void dispose() {
    _streamController.close();
  }

  Future<void> setDimensions(double radius) async {
    this.radius = radius;
    for (int i = 0; i < ringCount; i++) {
      double innerRadius = ringSize * (i + 1);
      double thickness = ringSize - padding;
      for (int j = 0; j < segmentCount; j++) {
        int id = i * segmentCount + j;
        var segment = segmentsValueNotifiers[id].value;
        segment.radius = innerRadius;
        segment.thickness = thickness;
        segment.height = segment.outerRadius - math.cos(math.pi / segmentCount) * innerRadius;
        segment.width = 2 * segment.outerRadius * math.sin(math.pi / segmentCount);
      }
    }
  }

  //#region Getters

  get ringSize {
    return radius / (ringCount + 1);
  }

  get center {
    return Offset(radius, radius);
  }

  Iterable<RingSegmentValueNotifier> get selectedRing {
    return selectedSegment == null ? new List<RingSegmentValueNotifier>() : segmentsValueNotifiers.where((x) =>
    (selectedSegment.radius - x.value.radius).abs() < ringSize / 4);
  }

  Iterable<RingSegmentValueNotifier> get selectedRow {
    return selectedSegment == null ? new List<RingSegmentValueNotifier>() : segmentsValueNotifiers.where((x) =>
        _closeEnoughWrapping(x.value.angle, selectedSegment.angle, math.pi / segmentCount / 4, 2 * math.pi));
  }

  Iterable<RingSegmentValueNotifier> get mirrorRow {
    return selectedSegment == null ? new List<RingSegmentValueNotifier>() : segmentsValueNotifiers.where((x) =>
        _closeEnoughWrapping(x.value.angle, (selectedSegment.angle + math.pi) % (2 * math.pi), math.pi / segmentCount / 4, 2 * math.pi));
  }

  Stream<List<String>> get foundWordsStream => _streamController.stream;

  //#endregion Getters

  //#region Word Processing

  void checkWords() {
    selectedSegment = null;
    var r = segmentsValueNotifiers.firstWhere((element) => _closeEnoughWrapping(element.value.angle, 0,  math.pi / segmentCount / 8, math.pi * 2));
    debugPrint("id ${r.value.id}");
    debugPrint("id ${r.value.angle}");
    _selectSegment(r.value.id);
    String l1 = selectedRow.map((e) => e.value.data).join();
    String l2 = mirrorRow.map((e) => e.value.data).join();
    var forward = (l1.split('').reversed.join() + centerLetter + l2).toLowerCase();
    var found = words.where((element) =>
    forward.indexOf(element) != -1 && forward.indexOf(element) > ringCount - element.length && forward.indexOf(element) <= ringCount
    ).toSet();
    debugPrint("found $found");
    foundWords = foundWords.union(found);
    if(found.isNotEmpty) {
      found.forEach((element) {
        debugPrint(element);
        _streamController.sink.add(foundWords.toList());
        int index = forward.indexOf(element);
        for (int i = index; i < index + element.length; i++) {
          if(i == ringCount) {
            centerController.reset();
            centerController.forward();
          } else if (i < ringCount) {
            selectedRow.elementAt(ringCount - i - 1).value.controller.reset();
            selectedRow.elementAt(ringCount - i - 1).value.controller.forward();
          } else {
            mirrorRow.elementAt(i - ringCount - 1).value.controller.reset();
            mirrorRow.elementAt(i - ringCount - 1).value.controller.forward();
          }
        }
      });
    }
    selectedSegment = null;
    if(foundWords.length == words.length) {
      endCallbacks.forEach((element) => element());
    }
  }


  //#endregion Word Processing

  //#region Functions

  void undo() {
    //TODO: does not work after shuffle
    if (undoQueue.isNotEmpty && !transformController.isAnimating) {
      UndoSegment undoSegment = undoQueue.removeFirst();
      RingSegmentModel previousState = undoSegment.model;
      _selectSegment(previousState.id);
      if (undoSegment.rotation) {
        _animation = new Tween<double>(
          begin: 0,
          end: (previousState.previousAngle - selectedSegment.angle + math.pi) % (2*math.pi) - math.pi,
        ).animate(transformController)
          ..addListener(_rotationAnimationUpdate)
          ..addStatusListener(_rotationAnimationComplete);
      } else {
        debugPrint("undo translate");
        _animation = new Tween<double>(
          begin: 0,
          end: previousState.previousRadius - selectedSegment.radius,
        ).animate(transformController)
          ..addListener(_translateAnimationUpdate)
          ..addStatusListener(_translateAnimationComplete);
      }
      transformController.reset();
      transformController.forward();
    }
  }

  void shuffle() {
    if(!transformController.isAnimating) {
      _shuffle(0);
    }
  }

  void _shuffle(int id) {
    int random = RandomHelper.getRandomInt(1, segmentCount);
    double angle = random * 2 * math.pi / segmentCount;
    _selectSegment(id);
    _animation = new Tween<double>(
      begin: 0,
      end: angle,
    ).animate(transformController)
      ..addListener(_rotationAnimationUpdate)
      ..addStatusListener(_shuffleRotationAnimationComplete);
    transformController.reset();
    transformController.forward();
  }

  void animatedRotateRing(int id, int segments) {
    double angle = segments * 2 * math.pi / segmentCount;
    _selectSegment(id);
    _animation = new Tween<double>(
      begin: 0,
      end: angle,
    ).animate(transformController)
      ..addListener(_rotationAnimationUpdate)
      ..addStatusListener(_rotationAnimationComplete);
    transformController.reset();
    transformController.forward();
  }

  void restart() {
    //TODO: Casues crash, but not needed right now, so look into it later.
//    undoQueue.clear();
//    initSegments.asMap().forEach((key, value) {
//      segmentsValueNotifiers[key].setValue(initSegments[key].clone());
//    });
  }

  void rotateRing(int id, double angle) {
    _selectSegment(id);
    selectedRing.forEach((element) {
      element.updateAngle(angle);
      element.value.previousAngle = element.value.angle;
    });
  }

  void translate(int id, double radius) {
    _selectSegment(id);
    _updateAllRadii(radius);
    selectedRow.forEach((element) {
      element.value.previousRadius = element.value.radius;
    });
    mirrorRow.forEach((element) {
      element.value.previousRadius = element.value.radius;
    });
  }

  //#endregion Functions

  //#region Rotation Events

  void rotationStart(Offset position, int id) {
    _selectSegment(id);
    startingAngle = (position - center).direction;
  }

  void rotationUpdate(Offset position) {
    double newAngle = (position - center).direction;
    double diff = newAngle - startingAngle;
    selectedRing.forEach((element) {
      element.updateAngle(diff);
    });
  }

  void rotationEnd() {
    if (selectedSegment == null) return;
    int closest = (selectedSegment.angle * segmentCount / (2 * math.pi)).round();
    double closestAngle = (closest * 2 * math.pi / segmentCount);
    if (!_closeEnoughWrapping(closestAngle, selectedSegment.previousAngle, math.pi / segmentCount / 4, math.pi*2)) {
      undoQueue.addFirst(UndoSegment(selectedSegment.clone(), true));
    }
    selectedRing.forEach((element) {
      element.value.previousAngle = element.value.angle;
    });
    _animation = new Tween<double>(
      begin: 0,
      end: closestAngle - selectedSegment.angle,
    ).animate(transformController)
      ..addListener(_rotationAnimationUpdate)
      ..addStatusListener(_rotationAnimationComplete)
      ..addStatusListener(_checkWordsOnComplete);

    transformController.reset();
    transformController.forward();
  }

  void rotationCancel() {
    if (selectedSegment == null || selectedRing == null) return;
    selectedRing.forEach((element) {
      element.updateAngle(0);
    });
  }

  //#endregion Rotation

  //#region Translation

  void translationStart(Offset position, int id) {
    _selectSegment(id);
    startingOffset = position - center;
  }

  void translationUpdate(Offset position) {
    Offset newPos = position - center;
    Offset diff = newPos - startingOffset;
    double offset = (diff.direction * startingOffset.direction) > 0 ? diff.distance : -diff.distance;
    _updateAllRadii(offset);
  }

  void translationEnd() {
    int closest = (selectedSegment.radius / ringSize).round();
    double closestRadius = (closest * ringSize);
    if (!_closeEnough(closestRadius, selectedSegment.previousRadius, math.pi / segmentCount / 4)) {
      undoQueue.addFirst(UndoSegment(selectedSegment.clone(), false));
    }
    selectedRow.forEach((element) {
      element.value.previousRadius = element.value.radius;
    });
    mirrorRow.forEach((element) {
      element.value.previousRadius = element.value.radius;
    });
    _animation = new Tween<double>(
      begin: 0,
      end: closestRadius - selectedSegment.radius,
    ).animate(transformController)
      ..addListener(_translateAnimationUpdate)
      ..addStatusListener(_translateAnimationComplete);

    transformController.reset();
    transformController.forward();
  }

  //#endregion Translation

  //#region Animation

  void _rotationAnimationUpdate() {
    selectedRing.forEach((element) {
      element.updateAngle(_animation.value);
    });
  }

  void _rotationAnimationComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      selectedRing.forEach((element) {
        element.value.previousAngle = element.value.angle;
      });
      _animation.removeStatusListener(_rotationAnimationComplete);
      _animation.removeListener(_rotationAnimationUpdate);
      selectedSegment = null;
    }
  }

  void _checkWordsOnComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _animation.removeStatusListener(_checkWordsOnComplete);
      checkWords();
      selectedSegment = null;
    }
  }

  void _shuffleRotationAnimationComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      selectedRing.forEach((element) {
        element.value.previousAngle = element.value.angle;
      });
      _animation.removeStatusListener(_shuffleRotationAnimationComplete);
      _animation.removeListener(_rotationAnimationUpdate);
      int nextId = selectedSegment.id + segmentCount;
      if(nextId >= segmentCount * ringCount) {
        checkWords();
        selectedSegment = null;
      } else {
        selectedSegment = null;
        _selectSegment(nextId);
        _shuffle(nextId);
      }
    }
  }


  void _translateAnimationUpdate() {
    _updateAllRadii(_animation.value);
  }

  void _translateAnimationComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      selectedRow.forEach((element) {
        element.value.previousRadius = element.value.radius;
      });
      mirrorRow.forEach((element) {
        element.value.previousRadius = element.value.radius;
      });
      _animation.removeStatusListener(_translateAnimationComplete);
      _animation.removeListener(_translateAnimationUpdate);
      selectedSegment = null;
    }
  }

  void _updateAllRadii(double offset) {
    selectedRow.forEach((element) {
      _updateRadiusWithOverflow(element, offset);
    });
    mirrorRow.forEach((element) {
      _updateRadiusWithOverflow(element, -offset);
    });
    while (overflowSegments.length != 0) {
      var segment = overflowSegments.first;
      overflowSegments.remove(segment);
      var match = underflowSegments.where((element) => element.offset.round() == segment.offset.round());
      if (match.length != 1) {
        debugPrint("match.length ${match.length}");
        debugPrint("overflow value ${segment.offset}");
        for (var value in underflowSegments) {
          debugPrint("underflow value ${value.offset}");
        }
        throw new Exception("Multiple matching underflow segments, unsure how to swap.");
      }
      var temp = match.first.model.data;
      match.first.model.data = segment.model.data;
      segment.model.data = temp;
    }
    overflowSegments.clear();
    underflowSegments.clear();
  }

  void _updateRadiusWithOverflow(RingSegmentValueNotifier element, double offset) {
    double minRadius = ringSize / 2;
    double maxRadius = radius - minRadius;
    double newRadius = element.value.previousRadius + offset;
    if (newRadius < minRadius || newRadius > maxRadius) {
      if (newRadius > maxRadius) {
        element.value.previousRadius = element.value.previousRadius - maxRadius + minRadius;
        overflowSegments.add(OverflowSegment(element.value, newRadius - maxRadius));
      } else if (newRadius < minRadius) {
        element.value.previousRadius = element.value.previousRadius + maxRadius - minRadius;
        underflowSegments.add(OverflowSegment(element.value, minRadius - newRadius));
      }
    }
    element.updateRadius(offset);
  }

  //#endregion Animation

  //#region Helper

  void _selectSegment(int id) {
    if(selectedSegment == null)
      selectedSegment = segmentsValueNotifiers[id].value;
  }

  bool _closeEnough(double d1, double d2, double delta) {
    return (d1 - d2).abs() < delta;
  }

  bool _closeEnoughWrapping(double d1, double d2, double delta, double max) {
    return _closeEnough(d1, d2, delta) || _closeEnough((d1 - d2).abs(), max, delta);
  }

  //#endregion Helper

}
