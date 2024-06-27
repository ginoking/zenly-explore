// import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'map.dart';

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
        body: const Map(),
      ),
      // supportedLocales: const [Locale('zh', 'TW')],
    );
  }
}



