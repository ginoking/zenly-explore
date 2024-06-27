import 'package:flutter/material.dart';
import 'package:flutter_application_1/newPainter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'helpers/gps.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> with TickerProviderStateMixin {
  final GPS _gps = GPS();
  late final _animatedMapController = AnimatedMapController(vsync: this);
  double _currentZoom = 15.0;

  Position? _userPosition;
  Exception? _exception;
  late bool serviceEnabled = false;
  late LocationPermission permission;

  void _handlePositionStream(Position position) {
    setState(() {
      _userPosition = position;
    });
  }

  // LatLng? getLatlng(Position? position) {
  //   if (!position) {
  //     return null;
  //   }
  //   return LatLng(position.latitude, position.longitude);
  // }

  @override
  void initState() {
    super.initState();
    _gps.startPositionStream(_handlePositionStream).catchError((e) {
      setState(() {
        _exception = e;
      });
    });
  }

  @override
  void dispose() {
    _animatedMapController.dispose();
    super.dispose();
  }

  // Future<Position> _determinePosition() async {
  //   if (serviceEnabled &&
  //       permission != LocationPermission.denied &&
  //       permission != LocationPermission.deniedForever) {
  //     return await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.best,
  //     );
  //   }
  //   // bool serviceEnabled;
  //   // LocationPermission permission;

  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     return Future.error('Location services are disabled.');
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return Future.error('Location permissions are denied');
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     // Android預設若拒絕兩次則會永久關閉(deniedForever)，使用者需至設定中手動開啟
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }

  //   // 如成功取得權限，使用以下function取得位置
  //   return await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.best,
  //   );
  // }

  // Future<LatLng> _latlng() async {
  //   try {
  //     final position = await _latlng();
  //     return LatLng(position.latitude, position.longitude);
  //   } catch (e) {
  //     // return const LatLng(23.973875, 120.982024);
  //     //如出現錯誤則跳出對話方塊提示使用者
  //     late LatLng _latlng;
  //     await showDialog(
  //         context: context,
  //         builder: (context) => SimpleDialog(
  //               contentPadding: const EdgeInsets.all(8.0),
  //               children: [
  //                 const Text("請開啟定位功能與權限"),
  //                 TextButton(
  //                     onPressed: () async {
  //                       final permission = await Geolocator.requestPermission();
  //                       if (permission == LocationPermission.deniedForever) {
  //                         _latlng = const LatLng(23.973875, 120.982024);
  //                         // 如為deniedForever就直接提供一個預設值
  //                       } else {
  //                         final _position =
  //                             await Geolocator.getCurrentPosition();
  //                         _latlng =
  //                             LatLng(_position.latitude, _position.longitude);
  //                       }
  //                       Navigator.pop(context);
  //                     },
  //                     child: const Text("確定"))
  //               ],
  //             ));
  //     return _latlng;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_exception != null) {
      child = const Text("請開放定位權限");
    } else if (_userPosition == null) {
      child = const Center(child: CircularProgressIndicator());
    } else {
      // child = Center(child: Text(_userPosition.toString()));
      child = Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.my_location),
          onPressed: () {
            _animatedMapController.mapController.move(LatLng(_userPosition!.latitude, _userPosition!.longitude), _currentZoom);
          },
        ),
        body: FlutterMap(
          mapController: _animatedMapController.mapController,
          options: MapOptions(
            initialCenter:
                LatLng(_userPosition!.latitude, _userPosition!.longitude),
            initialZoom: _currentZoom,
            maxZoom: 20.0,
            minZoom: 5.0,
            cameraConstraint: CameraConstraint.containCenter(
              bounds: LatLngBounds(
                const LatLng(90.0, 180.0),
                const LatLng(-90.0, -180.0),
              ),
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            ),
            CustomCircleLayer(circles: [
              CircleMarker(
                  point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
                  radius: 100000,
                  // useRadiusInMeter: true,
                  color: Colors.black.withOpacity(0.7))
            ], exceptCircles: [
              CircleMarker(
                  point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
                  radius: 100,
                  useRadiusInMeter: true,
                  color: Colors.transparent // color is not used
                  ),
              const CircleMarker(
                  point: LatLng(24.99052761433441, 121.3113866653879),
                  radius: 100,
                  useRadiusInMeter: true,
                  color: Colors.transparent // color is not used
                  ),
              const CircleMarker(
                  point: LatLng(24.989151607287504, 121.30797489578778),
                  radius: 100,
                  useRadiusInMeter: true,
                  color: Colors.transparent // color is not used
                  ),
              const CircleMarker(
                  point: LatLng(24.989579483918508, 121.31011529837208),
                  radius: 100,
                  useRadiusInMeter: true,
                  color: Colors.transparent // color is not used
                  ),
              const CircleMarker(
                  point: LatLng(24.989404443658554, 121.30943938176651),
                  radius: 100,
                  useRadiusInMeter: true,
                  color: Colors.transparent // color is not used
                  ),
            ]),
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
        ),
      );
    }
    return child;
  }
}
