import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';

class MlkitMeshService {
  late final FaceMeshDetector _meshDetector;

  MlkitMeshService() {
    _meshDetector = FaceMeshDetector(option: FaceMeshDetectorOptions.faceMesh);
  }

  FaceMeshDetector get detector => _meshDetector;

  Future<List<FaceMesh>> processImage(InputImage inputImage) async {
    return await _meshDetector.processImage(inputImage);
  }

  void dispose() {
    _meshDetector.close();
  }
}
