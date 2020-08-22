import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class RingSegmentValueNotifier extends ValueNotifier<RingSegmentModel> {
  RingSegmentValueNotifier(RingSegmentModel value) : super(value);

  updateAngle(double angle) {
    value.angle = value.previousAngle + angle;
    notifyListeners();
  }

  updateRadius(double radius) {
    value.radius = value.previousRadius + radius;
    notifyListeners();
  }

  setValue(RingSegmentModel v) {
    value = v;
    notifyListeners();
  }
}

class RingSegmentModel {
  final int id;
  var data;

  double previousAngle;
  double _angle;

  double previousRadius;
  double thickness;
  double radius;
  double height;
  double width;
  AnimationController controller;

  double get outerRadius {
    return radius + thickness;
  }

  double get degreesAngle {
    return angle * 180 / math.pi;
  }

  double get angle {
    return (_angle % (2 * math.pi));
  }

  set angle(value) {
    _angle = value;
  }

  RingSegmentModel(this.id, this._angle, this.data) {
    previousAngle = angle;
    previousRadius = radius;
  }

  RingSegmentModel._clone(this.id, this._angle, this.radius, this.thickness, this.height, this.width, this.data, this.previousAngle, this.previousRadius);

  RingSegmentModel clone() {
    return RingSegmentModel._clone(id, _angle, radius, thickness, height, width, data, previousAngle, previousRadius);
  }
}

class OverflowSegment {
  RingSegmentModel model;
  double offset;

  OverflowSegment(this.model, this.offset);
}

class UndoSegment {
  RingSegmentModel model;
  bool rotation;

  UndoSegment(this.model, this.rotation);
}

