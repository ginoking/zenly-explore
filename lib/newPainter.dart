import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';
import 'dart:ui';

base class NewCirclePainter extends CirclePainter
{
  final List<CircleMarker> exceptCircles;

  NewCirclePainter({
    required super.circles,
    required super.camera,
    required super.hitNotifier,
    required this.exceptCircles,
  });

  static const _distance = Distance();

  @override
  bool elementHitTest(
    CircleMarker element, {
    required Point<double> point,
    required LatLng coordinate,
  }) {
    final circle = element; // Should be optimized out by compiler, avoids lint

    final center = camera.getOffsetFromOrigin(circle.point);
    final radius = circle.useRadiusInMeter
        ? (center -
                camera.getOffsetFromOrigin(
                    _distance.offset(circle.point, circle.radius, 180)))
            .distance
        : circle.radius;

    return pow(point.x - center.dx, 2) + pow(point.y - center.dy, 2) <=
        radius * radius;
  }

  @override
  Iterable<CircleMarker> get elements => circles;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.clipRect(rect);

    // Let's calculate all the points grouped by color and radius
    final points = <Color, Map<double, List<Offset>>>{};
    final exceptPoints = <Color, Map<double, List<Offset>>>{};
    final pointsFilledBorder = <Color, Map<double, List<Offset>>>{};
    final pointsBorder = <Color, Map<double, Map<double, List<Offset>>>>{};
    for (final circle in circles) {
      final center = camera.getOffsetFromOrigin(circle.point);
      final radius = circle.useRadiusInMeter
          ? (center -
                  camera.getOffsetFromOrigin(
                      _distance.offset(circle.point, circle.radius, 180)))
              .distance
          : circle.radius;
      points[circle.color] ??= {};
      points[circle.color]![radius] ??= [];
      points[circle.color]![radius]!.add(center);

      if (circle.borderStrokeWidth > 0) {
        // Check if color have some transparency or not
        // As drawPoints is more efficient than drawCircle
        if (circle.color.alpha == 0xFF) {
          double radiusBorder = circle.radius + circle.borderStrokeWidth;
          if (circle.useRadiusInMeter) {
            final rBorder = _distance.offset(circle.point, radiusBorder, 180);
            final deltaBorder = center - camera.getOffsetFromOrigin(rBorder);
            radiusBorder = deltaBorder.distance;
          }
          pointsFilledBorder[circle.borderColor] ??= {};
          pointsFilledBorder[circle.borderColor]![radiusBorder] ??= [];
          pointsFilledBorder[circle.borderColor]![radiusBorder]!.add(center);
        } else {
          double realRadius = circle.radius;
          if (circle.useRadiusInMeter) {
            final rBorder = _distance.offset(circle.point, realRadius, 180);
            final deltaBorder = center - camera.getOffsetFromOrigin(rBorder);
            realRadius = deltaBorder.distance;
          }
          pointsBorder[circle.borderColor] ??= {};
          pointsBorder[circle.borderColor]![circle.borderStrokeWidth] ??= {};
          pointsBorder[circle.borderColor]![circle.borderStrokeWidth]![
              realRadius] ??= [];
          pointsBorder[circle.borderColor]![circle.borderStrokeWidth]![
                  realRadius]!
              .add(center);
        }
      }
    }

    for (final circle in exceptCircles) {
      final center = camera.getOffsetFromOrigin(circle.point);
      final radius = circle.useRadiusInMeter
          ? (center -
                  camera.getOffsetFromOrigin(
                      _distance.offset(circle.point, circle.radius, 180)))
              .distance
          : circle.radius;
      exceptPoints[circle.color] ??= {};
      exceptPoints[circle.color]![radius] ??= [];
      exceptPoints[circle.color]![radius]!.add(center);
    }

    // Now that all the points are grouped, let's draw them
    final paintBorder = Paint()..style = PaintingStyle.stroke;
    for (final color in pointsBorder.keys) {
      final paint = paintBorder..color = color;
      for (final borderWidth in pointsBorder[color]!.keys) {
        final pointsByRadius = pointsBorder[color]![borderWidth]!;
        final radiusPaint = paint..strokeWidth = borderWidth;
        for (final radius in pointsByRadius.keys) {
          final pointsByRadiusColor = pointsByRadius[radius]!;
          for (final offset in pointsByRadiusColor) {
            _paintCircle(canvas, offset, radius, radiusPaint);
          }
        }
      }
    }

    // Then the filled border in order to be under the circle
    final paintPoint = Paint()
      ..isAntiAlias = false
      ..strokeCap = StrokeCap.round;
    for (final color in pointsFilledBorder.keys) {
      final paint = paintPoint..color = color;
      final pointsByRadius = pointsFilledBorder[color]!;
      for (final radius in pointsByRadius.keys) {
        final pointsByRadiusColor = pointsByRadius[radius]!;
        final radiusPaint = paint..strokeWidth = radius * 2;
        _paintPoints(canvas, pointsByRadiusColor, radiusPaint);
      }
    }

    canvas.saveLayer(null, paintPoint);
    // And then the circle
    for (final color in points.keys) {
      final paint = paintPoint..color = color;
      final pointsByRadius = points[color]!;
      for (final radius in pointsByRadius.keys) {
        final pointsByRadiusColor = pointsByRadius[radius]!;
        final radiusPaint = paint..strokeWidth = radius * 2;
        _paintPoints(canvas, pointsByRadiusColor, radiusPaint);
      }
    }

    for (final color in exceptPoints.keys) {
      final paint = paintPoint..color = color;
      final pointsByRadiusTest = exceptPoints[color]!;
      for (final radius in pointsByRadiusTest.keys) {
        final pointsByRadiusColor = pointsByRadiusTest[radius]!;
        final radiusPaint = paint..strokeWidth = radius * 2
                                ..blendMode = BlendMode.clear;
        _erasePoint(canvas, pointsByRadiusColor, radiusPaint);
      }
    }
    canvas.restore();
  }

  void _paintPoints(Canvas canvas, List<Offset> offsets, Paint paint) {
    canvas.drawPoints(PointMode.points, offsets, paint);
  }

  void _paintCircle(Canvas canvas, Offset offset, double radius, Paint paint) {
    canvas.drawCircle(offset, radius, paint);
  }

  void _erasePoint(Canvas canvas, List<Offset> offsets, Paint paint) {
    canvas.drawPoints(PointMode.points, offsets, paint);
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) =>
      circles != oldDelegate.circles || camera != oldDelegate.camera;
}

class CustomCircleLayer extends CircleLayer {
  final List<CircleMarker> exceptCircles;

  const CustomCircleLayer({
    super.key,
    required super.circles,
    super.hitNotifier,
    required this.exceptCircles,
  });

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);

    return MobileLayerTransformer(
      child: CustomPaint(
        painter: NewCirclePainter(
          circles: circles,
          camera: camera,
          hitNotifier: hitNotifier,
          exceptCircles: exceptCircles,
        ),
        size: Size(camera.size.x, camera.size.y),
        isComplex: true,
      ),
    );
  }
}
