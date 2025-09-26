import 'package:flutter/material.dart';
import 'package:mobile_scanface/services/camera_services.dart';

class ScanFace extends StatelessWidget {
  final String title;
  final Color color;

  const ScanFace({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: CameraService(useFront: true, buttonColor: color),
    );
  }
}
