import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:mobile_scanface/components/error_popup.dart';
import 'package:mobile_scanface/services/mlkitmesh_service.dart';

class CameraService extends StatefulWidget {
  final bool useFront;
  final Color buttonColor;

  const CameraService({
    super.key,
    this.useFront = true,
    this.buttonColor = Colors.blue,
  });

  @override
  State<CameraService> createState() => _CameraServiceState();
}

class _CameraServiceState extends State<CameraService> {
  CameraController? _controller;
  late Future<void> _initializeController;

  late MlkitMeshService _mlkitMeshService;
  List<FaceMesh> _faces = [];
  XFile? _lastPhoto;
  Size? _imageSize;

  @override
  void initState() {
    super.initState();
    _initializeController = _initCamera();
    _mlkitMeshService = MlkitMeshService();
  }

  //Start camera with configurations
  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final camera = widget.useFront
        ? cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first,
          )
        : cameras.first;

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize();
  }

  //Function to transform photo in image and capture landmark
  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final photo = await _controller!.takePicture();
    _lastPhoto = photo;

    final inputImage = InputImage.fromFilePath(photo.path);
    final List<FaceMesh> meshes = await _mlkitMeshService.processImage(
      inputImage,
    );

    //Verify quantity of detected faces in photo
    if (meshes.length > 1) {
      await showErrorPopup(context, "Mais de um rosto detectado!!");
    } else if (meshes.isEmpty) {
      await showErrorPopup(context, "Nenhum rosto detectdo!!");
    } else {
      print("Faces detectadas ${meshes.length}");
    }

    if (mounted) {
      setState(() {
        _faces = meshes;
        _imageSize = Size(
          _controller!.value.previewSize!.height,
          _controller!.value.previewSize!.width,
        ); // Ajusta o tamanho da imagem para o painter
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _mlkitMeshService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeController,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            Positioned.fill(child: CameraPreview(_controller!)),
            if (_imageSize != null)
              Positioned.fill(
                child: CustomPaint(painter: FacePainter(_faces, _imageSize!)),
              ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: widget.buttonColor,
                  ),
                  onPressed: _takePhoto,
                  child: const Icon(
                    Icons.camera_alt,
                    color: Color.fromARGB(255, 255, 255, 255),
                    size: 32,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Painter para desenhar FaceMesh
class FacePainter extends CustomPainter {
  final List<FaceMesh> faces;
  final Size imageSize;

  FacePainter(this.faces, this.imageSize);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint boxPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final Paint pointPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    // Escala para ajustar a proporção entre imagem da câmera e o widget da tela
    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;

    for (final face in faces) {
      // Desenhar boundingBox
      final rect = Rect.fromLTRB(
        face.boundingBox.left * scaleX,
        face.boundingBox.top * scaleY,
        face.boundingBox.right * scaleX,
        face.boundingBox.bottom * scaleY,
      );
      canvas.drawRect(rect, boxPaint);

      // Desenhar todos os pontos da mesh
      for (final point in face.points) {
        final dx = point.x * scaleX;
        final dy = point.y * scaleY;
        canvas.drawCircle(Offset(dx, dy), 1.5, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant FacePainter oldDelegate) {
    return oldDelegate.faces != faces;
  }
}
