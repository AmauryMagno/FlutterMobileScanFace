import 'package:flutter/material.dart';
import 'package:mobile_scanface/services/camera_services.dart';
import 'package:mobile_scanface/utils/embeddings.dart';

class RegisterFace extends StatelessWidget {
  final String title;
  final Color color;

  const RegisterFace({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: CameraService(
        useFront: true,
        buttonColor: color,
        onFaceDetected: (faces) async {
          if (faces.length == 1) {
            await registerFace(faces.first);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Rosto registrado com sucesso!")),
            );
          }
        },
      ),
    );
  }
}
