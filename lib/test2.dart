// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// class MapWithCustomCircles extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Map with Custom Circles')),
//       body: FlutterMap(
//         options: MapOptions(
//           center: LatLng(51.5, -0.09),
//           zoom: 13.0,
//         ),
//         layers: [
//           TileLayerOptions(
//             urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//             subdomains: ['a', 'b', 'c'],
//           ),
//           CustomCircleLayerOptions(
//             circles: [
//               CustomCircleMarker(
//                 point: LatLng(51.5, -0.09),
//                 color: Colors.red.withOpacity(0.3),
//                 borderColor: Colors.red,
//                 borderStrokeWidth: 2,
//                 radius: 100,
//               ),
//               CustomCircleMarker(
//                 point: LatLng(51.5005, -0.0905),
//                 color: Colors.blue.withOpacity(0.3),
//                 borderColor: Colors.blue,
//                 borderStrokeWidth: 2,
//                 radius: 100,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CustomCircleMarker {
//   final LatLng point;
//   final Color color;
//   final Color borderColor;
//   final double borderStrokeWidth;
//   final double radius;

//   CustomCircleMarker({
//     required this.point,
//     required this.color,
//     required this.borderColor,
//     required this.borderStrokeWidth,
//     required this.radius,
//   });
// }

// class CustomCircleLayerOptions extends LayerOptions {
//   final List<CustomCircleMarker> circles;

//   CustomCircleLayerOptions({required this.circles});
// }

// class CustomCircleLayer extends StatelessWidget {
//   final CustomCircleLayerOptions options;

//   CustomCircleLayer(this.options);

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return Stack(
//           children: options.circles.map((circle) {
//             // 在此處檢查和避免重疊
//             return Positioned(
//               left: circle.point.longitude,
//               top: circle.point.latitude,
//               child: CustomPaint(
//                 painter: CirclePainter(circle),
//               ),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
// }

// class CirclePainter extends CustomPainter {
//   final CustomCircleMarker circle;

//   CirclePainter(this.circle);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = circle.color
//       ..style = PaintingStyle.fill;

//     final borderPaint = Paint()
//       ..color = circle.borderColor
//       ..strokeWidth = circle.borderStrokeWidth
//       ..style = PaintingStyle.stroke;

//     final center = Offset(size.width / 2, size.height / 2);
//     canvas.drawCircle(center, circle.radius, paint);
//     canvas.drawCircle(center, circle.radius, borderPaint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }

// void main() => runApp(MaterialApp(
//   home: MapWithCustomCircles(),
// ));