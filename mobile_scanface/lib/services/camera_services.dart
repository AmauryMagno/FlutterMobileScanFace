import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeController = _initCamera();
  }

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

  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final photo = await _controller!.takePicture();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("📸 Foto tirada: ${photo.path}")));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
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
            // câmera ocupa toda a tela
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.previewSize!.height,
                  height: _controller!.value.previewSize!.width,
                  child: CameraPreview(_controller!),
                ),
              ),
            ),

            // botão de captura
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
                    size: 32,
                    color: Colors.white,
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
