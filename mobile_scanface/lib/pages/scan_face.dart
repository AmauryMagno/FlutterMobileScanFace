import 'package:flutter/material.dart';
import 'package:mobile_scanface/services/camera_services.dart';
import 'package:mobile_scanface/utils/embeddings.dart';
import 'package:mobile_scanface/utils/math_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanFace extends StatelessWidget {
  final String title;
  final Color color;

  const ScanFace({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: CameraService(
        useFront: true,
        buttonColor: color,
        onFaceDetected: (faces) async {
          if (faces.length == 1) {
            final embedding = extractEmbedding(faces.first);
            final prefs = await SharedPreferences.getInstance();
            final saved = prefs.getString("face_embedding");

            if (saved != null) {
              final savedEmbedding = saved
                  .split(",")
                  .map((e) => double.parse(e))
                  .toList();
              print("Rosto que foi salvo: ${savedEmbedding}");
              final distance = euclideanDistance(embedding, savedEmbedding);

              if (distance < 0.6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Login bem-sucedido ✅")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Rosto não reconhecido ❌")),
                );
              }
            }
          }
        },
      ),
    );
  }
}
