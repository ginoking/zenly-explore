import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationWidget extends StatefulWidget {
  const LocationWidget({super.key});

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  late Position _currentPosition; // 将 _currentPosition 声明为可空类型
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // 获取当前位置信息
    _listenLocationChanges();
  }

  _getCurrentLocation() {
    Geolocator.getCurrentPosition(
            // 使用 Geolocator 获取当前位置信息
            desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        // 更新当前位置信息
        _currentPosition = position;
      });
    }).catchError((e) {
      // 捕获错误
      print(e);
    });
  }

  _listenLocationChanges() {
    _positionStreamSubscription = Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.best, distanceFilter: 10))
        .listen((Position position) {
      setState(() {
        _currentPosition = position;
      });
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return _currentPosition;
    return Center(
      child: Text(// 返回文本小部件
          'Location: ${_currentPosition.latitude}, ${_currentPosition.longitude}'
      ), // 显示当前位置的经纬度信息
    );
  }
}