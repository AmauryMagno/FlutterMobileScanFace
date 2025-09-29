import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Function to extract point of landmarks
List<double> extractEmbedding(FaceMesh faceMesh) {
  return faceMesh.points
      .map((p) => [p.x, p.y, p.z])
      .expand((coords) => coords)
      .toList();
}

//Function to register face
Future<void> registerFace(FaceMesh faceMesh) async {
  final embedding = extractEmbedding(faceMesh);

  //Use SharedPreferences to save face embedding
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("face_embedding", embedding.join(","));
  print("Rosto registrado: ${prefs}");
}
