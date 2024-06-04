import 'dart:async';
// import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

final mapController = MapController();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('GPS Location'),
        ),
        // body: const LocationWidget(),
        body: FutureBuilder<LatLng>(
          future: _latlng(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              // return Center(
              //   child: Text('Location: ${snapshot.data.latitude}, ${snapshot.data.longitude}'),
              // );
              return FlutterMap(
                options: MapOptions(
                    initialCenter: snapshot.data,
                    initialZoom: 15.0,
                    maxZoom: 20.0,
                    minZoom: 5.0,
                    cameraConstraint: CameraConstraint.containCenter(
                      bounds: LatLngBounds(
                        const LatLng(90.0, 180.0),
                        const LatLng(-90.0, -180.0),
                      ),
                    ),
                    // backgroundColor: Colors.black.withOpacity(0.5)
                ),
                children: [

                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                    // zoomReverse: true
                  ),
                  // TileLayer(
                  //   urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  //   // zoomReverse: true
                  // ),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: snapshot.data,
                        radius: 100000,
                        // useRadiusInMeter: true,
                        color: Colors.black.withOpacity(0.5)
                      ),
                    ],
                  ),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: snapshot.data,
                        radius: 10,
                        useRadiusInMeter: true,
                        color: Colors.white.withOpacity(0.3)
                      ),
                      CircleMarker(
                        point: const LatLng(24.988166709962165, 121.31983249528967),
                        radius: 10,
                        useRadiusInMeter: true,
                        color: Colors.white.withOpacity(0.3)
                      ),
                      CircleMarker(
                        point: const LatLng(24.988245114232143, 121.31972587749178),
                        radius: 10,
                        useRadiusInMeter: true,
                        color: Colors.white.withOpacity(0.3)
                      ),
                    ],
                  ),
                  CurrentLocationLayer(
                    style: const LocationMarkerStyle(
                      marker: DefaultLocationMarker(
                        child: Icon(
                          Icons.navigation,
                          color: Colors.white,
                          size: 20.0,
                        ),
                      ),
                      markerSize: Size(30, 30),
                      markerDirection: MarkerDirection.heading,
                    ),
                  )
                ],
              );
            }
            return const Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 8.0),
                  Text("初始化中，請稍候")
                ],
              ),
            );
          },
        ),
        // new LocationWidget(),
      ),
      // supportedLocales: const [Locale('zh', 'TW')],
    );
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // 先檢查有無開啟定位功能
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    //錯誤排除
    return Future.error('Location services are disabled.');
  }

  // 接著檢查有無開啟定位權限
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // 錯誤排除
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Android預設若拒絕兩次則會永久關閉(deniedForever)，使用者需至設定中手動開啟
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // 如成功取得權限，使用以下function取得位置
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.best,
  );
}

Future<LatLng> _latlng() async {
  try {
    final position = await _determinePosition();
    return LatLng(position.latitude, position.longitude);
  } catch (e) {
    return LatLng(23.973875, 120.982024);
    // //如出現錯誤則跳出對話方塊提示使用者
    // late LatLng _latlng;
    // await showDialog(
    //     context: context,
    //     builder: (context) => SimpleDialog(
    //           contentPadding: const EdgeInsets.all(8.0),
    //           children: [
    //             const Text("請開啟定位功能與權限以定位附近販售點"),
    //             TextButton(
    //                 onPressed: () async {
    //                   final permission = await Geolocator.requestPermission();
    //                   if (permission == LocationPermission.deniedForever) {
    //                     _latlng = LatLng(23.973875, 120.982024);
    //                     // 如為deniedForever就直接提供一個預設值
    //                   } else {
    //                     final _position = await Geolocator.getCurrentPosition();
    //                     _latlng =
    //                         LatLng(_position.latitude, _position.longitude);
    //                   }
    //                   Navigator.pop(context);
    //                 },
    //                 child: const Text("確定"))
    //           ],
    //         ));
    // return _latlng;
  }
}

// class LocationWidget extends StatefulWidget {
//   const LocationWidget({super.key});

//   @override
//   State<LocationWidget> createState() => _LocationWidgetState();
// }

// class _LocationWidgetState extends State<LocationWidget> {
//   late Position _currentPosition; // 将 _currentPosition 声明为可空类型
//   StreamSubscription<Position>? _positionStreamSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation(); // 获取当前位置信息
//     _listenLocationChanges();
//   }

//   _getCurrentLocation() {
//     Geolocator.getCurrentPosition(
//             // 使用 Geolocator 获取当前位置信息
//             desiredAccuracy: LocationAccuracy.best)
//         .then((Position position) {
//       setState(() {
//         // 更新当前位置信息
//         _currentPosition = position;
//       });
//     }).catchError((e) {
//       // 捕获错误
//       print(e);
//     });
//   }

//   _listenLocationChanges() {
//     _positionStreamSubscription = Geolocator.getPositionStream(
//             locationSettings: const LocationSettings(
//                 accuracy: LocationAccuracy.best, distanceFilter: 10))
//         .listen((Position position) {
//       setState(() {
//         _currentPosition = position;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _positionStreamSubscription?.cancel();
//     super.dispose();
//   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   return _currentPosition;
//   //   return Center(
//   //     child: Text(// 返回文本小部件
//   //         'Location: ${_currentPosition.latitude}, ${_currentPosition.longitude}'
//   //     ), // 显示当前位置的经纬度信息
//   //   );
//   // }
// }

