// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';

Future doFaceDetection(String userImagePath) async {
  final options = FaceDetectorOptions();
  final faceDetector = FaceDetector(options: options);

  InputImage inputImage = InputImage.fromFilePath(userImagePath);

  // InputImage inputImage = InputImage.fromBytes(
  //     bytes: userImage.bytes!,
  //     metadata: InputImageMetadata(
  //       bytesPerRow: 10,
  //       format: InputImageFormat.bgra8888,
  //       rotation: InputImageRotation.rotation0deg,
  //       size: Size(
  //         150,
  //         150,
  //       ),
  //     ));

  final List<Face> faces = await faceDetector.processImage(inputImage);

  for (Face face in faces) {
    final Rect boundingBox = face.boundingBox;
    print('será que finciona? = ${boundingBox.toString}');
  }
  // Add your function code here!
}
