import 'package:flame/components.dart';

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

extension ToOffset on Vector2 {
  Offset toOffset() {
    return Offset(x, y);
  }
}

extension ToVector on Offset {
  Vector2 toVector2() {
    return Vector2(dx, dy);
  }
}

class Point extends PositionComponent {
  Point({this.locked = false}) {
    width = 10;
    height = 10;
  }

  Vector2? prevPosition;
  bool locked;
  double weight = 1.0;

  Paint lockedPainter = Paint()..color = Colors.red;
  Paint unlockedPainter = Paint()..color = Colors.white;
  @override
  render(Canvas c) {
    if (locked) {
      c.drawCircle(Offset(center.x, center.y), width / 2, lockedPainter);
    } else {
      c.drawCircle(Offset(center.x, center.y), width / 2, unlockedPainter);
    }

    super.render(c);
  }

  @override
  String toString() {
    // TODO: implement toString
    return "Point -> $position -> $prevPosition \n";
  }
}

class Stick extends PositionComponent {
  Stick(this.pointA, this.pointB, this.length);

  Point pointA;
  Point pointB;
  double length;

  Paint linePainter = Paint()
    ..color = Colors.green
    ..strokeWidth = 2;

  @override
  void render(Canvas canvas) {
    canvas.drawLine(Offset(pointA.center.x, pointA.center.y),
        Offset(pointB.center.x, pointB.center.y), linePainter);
    super.render(canvas);
  }

  @override
  String toString() {
    return "STICK -> PtA($pointA) PtB($pointB) $length  \n";
  }
}

extension VectorMultiply on Vector2 {
  Vector2 m2(Vector2 v2) => clone()..multiply(v2);
}

class StringGame extends FlameGame with PanDetector {
  final down = Vector2(0, 1);
  final gravity = Vector2(0, 100);
  final numIterations = 10;

  List<Point> points = [];
  List<Stick> sticks = [];

  addPoint(Point pt) {
    add(pt);
    points.add(pt);
  }

  addStick(Stick stick) {
    add(stick);
    sticks.add(stick);
  }

  @override
  Future<void>? onLoad() {
    var pt1 = Point()..position = Vector2(100, 100);
    pt1.locked = true;

    var pt2 = Point()
      ..position = Vector2(200, 100)
      ..weight = 1;
    addStick(Stick(pt1, pt2, 50));

    var pt3 = Point()
      ..position = Vector2(300, 100)
      ..weight = 1;
    addStick(Stick(pt2, pt3, 50));

    var pt4 = Point()
      ..position = Vector2(400, 100)
      ..weight = 1;
    addStick(Stick(pt3, pt4, 50));

    var pt5 = Point()
      ..position = Vector2(500, 100)
      ..weight = 1;
    addStick(Stick(pt4, pt5, 50));

    var pt6 = Point()
      ..position = Vector2(600, 100)
      ..weight = 1;
    addStick(Stick(pt5, pt6, 50));

    addPoint(pt1);
    addPoint(pt2);
    addPoint(pt3);
    addPoint(pt4);
    addPoint(pt5);
    addPoint(pt6);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    for (var p in points) {
      final _position = p.position;
      final _prevPosition = p.prevPosition;
      if (_prevPosition == null) {
        p.prevPosition = _position;
        continue;
      }

      if (!p.locked) {
        Vector2 positionBeforeUpdate = _position;
        p.position += (_position - _prevPosition);
        p.position += down.m2(gravity) * dt * p.weight;
        p.prevPosition = positionBeforeUpdate;
      }
    }

    for (int i = 0; i < numIterations; i++) {
      for (var stick in sticks) {
        Vector2 stickCenter =
            (stick.pointA.position + stick.pointB.position) / 2;
        Vector2 stickDir =
            (stick.pointA.position - stick.pointB.position).normalized();

        if (!stick.pointA.locked) {
          stick.pointA.position = stickCenter + stickDir * stick.length / 2;
        }

        if (!stick.pointB.locked) {
          stick.pointB.position = stickCenter - stickDir * stick.length / 2;
        }
      }
    }

    super.update(dt);
  }

  Point? pointUnderDrag;
  @override
  void onPanEnd(DragEndInfo info) {
    pointUnderDrag = null;
    super.onPanEnd(info);
  }

  @override
  void onPanStart(DragStartInfo info) {
    print("PAN");

    try {
      final pt = points.firstWhere(
          (p) => p.containsPoint(info.raw.globalPosition.toVector2()));

      pointUnderDrag = pt;
    } catch (e) {
      //noop
    }

    super.onPanStart(info);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    print("PAN DELTA ${info.delta}");
    pointUnderDrag?.position += info.delta.global;

    // TODO: implement onPanUpdate
    super.onPanUpdate(info);
  }
}
