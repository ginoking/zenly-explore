// FutureBuilder<LatLng>(
//           future: _latlng(),
//           builder: (BuildContext context, AsyncSnapshot snapshot) {
//             if (snapshot.hasData) {
//               // return Center(
//               //   child: Text('Location: ${snapshot.data.latitude}, ${snapshot.data.longitude}'),
//               // );
//               return FlutterMap(
//                 options: MapOptions(
//                     initialCenter: snapshot.data,
//                     initialZoom: 15.0,
//                     maxZoom: 20.0,
//                     minZoom: 5.0,
//                     cameraConstraint: CameraConstraint.containCenter(
//                       bounds: LatLngBounds(
//                         const LatLng(90.0, 180.0),
//                         const LatLng(-90.0, -180.0),
//                       ),
//                     ),
//                     // backgroundColor: Colors.black.withOpacity(0.5)
//                 ),
//                 children: [

//                   TileLayer(
//                     urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                     userAgentPackageName: 'dev.fleaflet.flutter_map.example',
//                     // zoomReverse: true
//                   ),
//                   // TileLayer(
//                   //   urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                   //   // zoomReverse: true
//                   // ),
//                   CircleLayer(
//                     circles: [
//                       CircleMarker(
//                         point: snapshot.data,
//                         radius: 100000,
//                         // useRadiusInMeter: true,
//                         color: Colors.black.withOpacity(0.5)
//                       ),
//                     ],
//                   ),
//                   // PolylineLayer(
//                   //   polylines: [
//                   //     Polyline(
//                   //       points: [
//                   //         snapshot.data, 
//                   //         const LatLng(24.988166709962165, 121.31983249528967), 
//                   //         const LatLng(24.988245114232143, 121.31972587749178)
//                   //       ],
//                   //       color: Colors.white.withOpacity(0.3),
//                   //     ),
//                   //   ],
//                   // ),
//                   CircleLayer(
//                     circles: [
//                       CircleMarker(
//                         point: snapshot.data,
//                         radius: 10,
//                         useRadiusInMeter: true,
//                         color: Colors.white.withOpacity(0.3)
//                       ),
//                       CircleMarker(
//                         point: const LatLng(24.988166709962165, 121.31983249528967),
//                         radius: 10,
//                         useRadiusInMeter: true,
//                         color: Colors.white.withOpacity(0.3)
//                       ),
//                       CircleMarker(
//                         point: const LatLng(24.988245114232143, 121.31972587749178),
//                         radius: 10,
//                         useRadiusInMeter: true,
//                         color: Colors.white.withOpacity(0.3)
//                       ),
//                     ],
//                   ),
//                   CurrentLocationLayer(
//                     style: const LocationMarkerStyle(
//                       marker: DefaultLocationMarker(
//                         child: Icon(
//                           Icons.navigation,
//                           color: Colors.white,
//                           size: 20.0,
//                         ),
//                       ),
//                       markerSize: Size(30, 30),
//                       markerDirection: MarkerDirection.heading,
//                     ),
//                   )
//                 ],
//               );
//             }
//             return const Align(
//               alignment: Alignment.center,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: const [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 8.0),
//                   Text("初始化中，請稍候")
//                 ],
//               ),
//             );
//           },
//         ),