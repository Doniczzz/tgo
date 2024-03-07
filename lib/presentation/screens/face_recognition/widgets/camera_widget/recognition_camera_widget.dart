import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tgo_acudir/flutter_flow/flutter_flow_util.dart';
import 'package:tgo_acudir/presentation/screens/face_recognition/recognizer.dart';
import 'package:tgo_acudir/presentation/screens/face_recognition/widgets/camera_widget/face_detector_painter.dart';

import 'package:image/image.dart' as img;

class RecognitionCameraWidget extends StatefulWidget {
  const RecognitionCameraWidget({super.key});

  @override
  State<RecognitionCameraWidget> createState() => _RecognitionCameraWidgetState();
}

class _RecognitionCameraWidgetState extends State<RecognitionCameraWidget> {
  late Size size;
  dynamic controller;
  dynamic _scanResults;

  late CameraDescription description = cameras[1];
  late List<CameraDescription> cameras;
  CameraImage? frame;
  CameraLensDirection camDirec = CameraLensDirection.front;

  late FaceDetector faceDetector;
  late Recognizer recognizer;

  bool isBusy = false;
  img.Image? image;

  int stage = 0;
  bool isSnackbarShowing = false;
  bool warningSnackbarShowing = false;

  Widget buildResult() {
    if (_scanResults == null || controller == null || !controller.value.isInitialized) {
      return const Center(child: Text('Camara no inicializada'));
    }
    final Size imageSize = Size(
      controller.value.previewSize!.height,
      controller.value.previewSize!.width,
    );
    CustomPainter painter = FaceDetectorPainter(imageSize, _scanResults, camDirec);
    return CustomPaint(
      painter: painter,
    );
  }

  initializeCamera() async {
    cameras = await availableCameras();
    controller = CameraController(
      description,
      ResolutionPreset.medium,
    );
    await controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.startImageStream((image) => {
            if (!isBusy) {isBusy = true, frame = image, doFaceDetectionOnFrame()}
          });
    });
  }

  InputImage getInputImage() {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in frame!.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize = Size(frame!.width.toDouble(), frame!.height.toDouble());
    final camera = description;
    final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    // if (imageRotation == null) return;

    final inputImageFormat = InputImageFormatValue.fromRawValue(frame!.format.raw);
    // if (inputImageFormat == null) return null;

    final planeData = frame!.planes.map(
      (Plane plane) {
        return InputImageMetadata(
          bytesPerRow: plane.bytesPerRow,
          format: inputImageFormat!,
          rotation: imageRotation!,
          size: imageSize,
        );
      },
    ).toList();

    final inputImageData = InputImageMetadata(
      size: imageSize,
      bytesPerRow: planeData[0].bytesPerRow,
      format: inputImageFormat!,
      rotation: imageRotation!,
    );

    final inputImage = InputImage.fromBytes(bytes: bytes, metadata: inputImageData);

    return inputImage;
  }

  img.Image convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final yRowStride = cameraImage.planes[0].bytesPerRow;
    final uvRowStride = cameraImage.planes[1].bytesPerRow;
    final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    final image = img.Image(width: width, height: height);

    for (var w = 0; w < width; w++) {
      for (var h = 0; h < height; h++) {
        final uvIndex = uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
        final index = h * width + w;
        final yIndex = h * yRowStride + w;

        final y = cameraImage.planes[0].bytes[yIndex];
        final u = cameraImage.planes[1].bytes[uvIndex];
        final v = cameraImage.planes[2].bytes[uvIndex];

        image.data!.setPixelR(w, h, yuv2rgb(y, u, v)); //= yuv2rgb(y, u, v);
      }
    }
    return image;
  }

  int yuv2rgb(int y, int u, int v) {
    // Convert yuv pixel to rgb
    var r = (y + v * 1436 / 1024 - 179).round();
    var g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
    var b = (y + u * 1814 / 1024 - 227).round();

    // Clipping RGB values to be inside boundaries [ 0 , 255 ]
    r = r.clamp(0, 255);
    g = g.clamp(0, 255);
    b = b.clamp(0, 255);

    return 0xff000000 | ((b << 16) & 0xff0000) | ((g << 8) & 0xff00) | (r & 0xff);
  }

  doFaceDetectionOnFrame() async {
    //TODO convert frame into InputImage format

    InputImage inputImage = getInputImage();

    //TODO pass InputImage to face detection model and detect faces

    List<Face> faces = await faceDetector.processImage(inputImage);

    if (faces.length == 1) {
      for (Face face in faces) {
        switch (stage) {
          case 0:
            if (face.smilingProbability! > 0.85) {
              stage = 1;
              if (isSnackbarShowing) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                isSnackbarShowing = false;
              }
            } else if (!isSnackbarShowing) {
              isSnackbarShowing = true;
              // ignore: use_build_context_synchronously
              showSnackbar(context, 'Sonríe para la camara');
            }
            break;
          case 1:
            if (face.leftEyeOpenProbability! < 0.10 && face.rightEyeOpenProbability! > 0.80) {
              stage = 2;
              if (isSnackbarShowing) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                isSnackbarShowing = false;
              }
            } else if (!isSnackbarShowing) {
              isSnackbarShowing = true;
              // ignore: use_build_context_synchronously
              showSnackbar(context, 'Cierra el ojo derecho');
            }
            break;
          case 2:
            performFaceRecognition(faces);
            if (!isSnackbarShowing) {
              // ignore: use_build_context_synchronously
              showSnackbar(context, 'Analizando rostro...');
              isSnackbarShowing = true;
            }
            break;
          default:
        }
      }
    } else if (faces.length > 1) {
      warningSnackbarShowing = true;
      if (warningSnackbarShowing) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        warningSnackbarShowing = false;
      }
      isSnackbarShowing = false;
      stage = 0;
    } else {
      isSnackbarShowing = false;
      stage = 0;
    }

    if (mounted) {
      setState(() {
        _scanResults = faces;
        isBusy = false;
      });
    }
  }

  Future<void> testAction(String? name)async{
    // showSnackbar(context, 'Bienvenido $name');
    // context.pop();
    if(context.mounted) {
      showSnackbar(context, 'Bienvenido $name');
      context.pushReplacementNamed('face_recognition_screen');
    }
  }

  performFaceRecognition(List<Face> faces) async {
    //TODO convert CameraImage to Image and rotate it so that our frame will be in a portrait
    image = convertYUV420ToImage(frame!);
    image = img.copyRotate(image!, angle: camDirec == CameraLensDirection.front ? 270 : 90);

    for (Face face in faces) {
      Rect faceRect = face.boundingBox;
      //TODO crop face
      img.Image croppedFace = img.copyCrop(image!,
          x: faceRect.left.toInt() + 1,
          y: faceRect.top.toInt() + 1,
          width: faceRect.width.toInt() + 1,
          height: faceRect.height.toInt() + 1);

      //TODO pass cropped face to face recognition model
      await recognizer.recognize(croppedFace, faceRect, false, null, testAction);
      // ignore: use_build_context_synchronously
      // context.safePop();
      // ignore: use_build_context_synchronously
      // showDialog(
      //     context: context,
      //     builder: (context) => AlertDialog(
      //           title: const Text('Face Recognition'),
      //           content: Image.memory(img.encodeJpg(croppedFace)),
      //           actions: <Widget>[
      //             TextButton(
      //               child: const Text('Cancel'),
      //               onPressed: () {
      //                 Navigator.of(context).pop();
      //               },
      //             ),
      //             TextButton(
      //               child: const Text('Register'),
      //               onPressed: () async {
      //                 // ignore: use_build_context_synchronously
      //                 context.pushReplacementNamed('face_recognition_screen');
      //                 // print(croppedFace.data);
      //                 // Navigator.of(context).pop();
      //               },
      //             ),
      //           ],
      //         ));

      // await showDialog(
      //     context: context,
      //     builder: (context) => GestureDetector(
      //           child: Padding(
      //             padding: MediaQuery.viewInsetsOf(context),
      //             child: FaceCroppedWidget(
      //               userFace: Image.memory(img.encodeJpg(croppedFace)),
      //             ),
      //           ),
      //         ));

      // return GestureDetector(
      //       child: Padding(
      //         padding: MediaQuery.viewInsetsOf(context),
      //         child: FaceCroppedWidget(
      //           userFace: Image.memory(img.encodeJpg(croppedFace)),
      //         ),
      //       ),
      //     );

      //TODO show face registration dialogue
    }

    // setState(() {
    //   isBusy = false;
    //   _scanResults = recognitions;
    // });
  }

  @override
  void initState() {
    super.initState();

    //TODO initialize face detector
    faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );

    //TODO initialize face recognizer
    recognizer = Recognizer();

    //TODO initialize camera footage
    initializeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];
    size = MediaQuery.of(context).size;
    if (controller != null) {
      //TODO View for displaying the live camera footage
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height,
          child: Container(
            child: (controller.value.isInitialized)
                ? AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: CameraPreview(controller),
                  )
                : Container(),
          ),
        ),
      );

      //TODO View for displaying rectangles around detected aces
      stackChildren.add(
        Positioned(top: 0.0, left: 0.0, width: size.width, height: size.height, child: buildResult()),
      );
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
            margin: const EdgeInsets.only(top: 0),
            color: Colors.black,
            child: Stack(
              children: stackChildren,
            )),
      ),
    );
  }
}
