import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:mobile_scanface/components/error_popup.dart';
import 'package:mobile_scanface/services/mlkitmesh_service.dart';
import 'package:mobile_scanface/utils/effects/face_painter.dart';
import 'package:mobile_scanface/utils/embeddings.dart';

class CameraService extends StatefulWidget {
  final bool useFront;
  final Color buttonColor;
  final Function(List<FaceMesh>)? onFaceDetected;

  const CameraService({
    super.key,
    this.useFront = true,
    this.buttonColor = Colors.blue,
    this.onFaceDetected,
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
      if (widget.onFaceDetected != null) {
        print("Faces detectadas ${meshes.length}");
        widget.onFaceDetected!(meshes);
      }
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
