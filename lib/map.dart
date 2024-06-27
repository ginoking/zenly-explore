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
  bool init = true;

  List<CircleMarker> points = [];

  Position? _userPosition;
  Exception? _exception;
  late bool serviceEnabled = false;
  late LocationPermission permission;

  void _handlePositionStream(Position position) {
    setState(() {
      _userPosition = position;
    });

    points.add(_createCircleMarker(LatLng(_userPosition!.latitude, _userPosition!.longitude)));

    if (!init) {
      _animatedMapController.animateTo(
        dest: LatLng(position.latitude, position.longitude)
      );
    }

    if (init) {
      init = false;
    }
  }

  CircleMarker _createCircleMarker(LatLng point) {
    return CircleMarker(
        point: point,
        radius: 100,
        useRadiusInMeter: true,
        color: Colors.transparent // color is not used
    );
  }

  @override
  void initState() {
    super.initState();
    _gps.startPositionStream(_handlePositionStream).catchError((e) {
      setState(() {
        _exception = e;
      });
    });

    points = [
      // _createCircleMarker(LatLng(_userPosition!.latitude, _userPosition!.longitude)),
      _createCircleMarker(const LatLng(24.99052761433441, 121.3113866653879)),
      _createCircleMarker(const LatLng(24.989151607287504, 121.30797489578778)),
      _createCircleMarker(const LatLng(24.989579483918508, 121.31011529837208)),
      _createCircleMarker(const LatLng(24.989404443658554, 121.30943938176651)),
    ];
  }

  @override
  void dispose() {
    _animatedMapController.dispose();
    super.dispose();
  }

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
        appBar: AppBar(
          title: Text(
              "latLng: ${_userPosition!.latitude}, ${_userPosition!.longitude}"),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.my_location),
          onPressed: () {
            _animatedMapController.animateTo(
              dest: LatLng(_userPosition!.latitude, _userPosition!.longitude)
            );
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
            CustomCircleLayer(
              circles: [
                CircleMarker(
                    point:
                        LatLng(_userPosition!.latitude, _userPosition!.longitude),
                    radius: 100000000,
                    color: Colors.black.withOpacity(0.7))
              ], 
              exceptCircles: points
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
        ),
      );
    }
    return child;
  }
}
