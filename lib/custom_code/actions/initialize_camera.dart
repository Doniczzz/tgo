// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:camera/camera.dart';

Future initializeCamera() async {
  List<CameraDescription> cameras = await availableCameras();

  final cameraDescription = cameras[1];

  final controller =
      CameraController(cameraDescription, ResolutionPreset.medium);

  await controller.initialize().then((_) {
    controller.startImageStream(
      (image) {
        print('camara encendida: ${image.width}');
      },
    );
  });
  // Add your function code here!
}
