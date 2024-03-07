import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tgo_acudir/flutter_flow/flutter_flow_icon_button.dart';
import 'package:tgo_acudir/flutter_flow/flutter_flow_util.dart';
import 'package:tgo_acudir/presentation/screens/face_recognition/recognizer.dart';
import 'package:tgo_acudir/presentation/screens/face_recognition/widgets/camera_widget/face_detector_painter.dart';

import 'package:image/image.dart' as img;
import 'package:tgo_acudir/presentation/screens/face_recognition/widgets/face_cropped/face_cropped_widget.dart';

class CameraWidget extends StatefulWidget {
  const CameraWidget({super.key});

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  late List<CameraDescription> cameras;
  dynamic controller;
  bool isBusy = false;
  late Size size;
  late CameraDescription description = cameras[1];
  CameraLensDirection camDirec = CameraLensDirection.front;

  late FaceDetector faceDetector;
  late Recognizer recognizer;

  dynamic _scanResults;
  CameraImage? frame;

  img.Image? image;


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

  void toggleCameraDirection() async {
    if (camDirec == CameraLensDirection.back) {
      camDirec = CameraLensDirection.front;
      description = cameras[1];
    } else {
      camDirec = CameraLensDirection.back;
      description = cameras[0];
    }
    await controller.stopImageStream();
    setState(() {
      controller;
    });
    initializeCamera();
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

  Future<void> performFaceRecognition(List<Face> faces) async {
    //TODO convert CameraImage to Image and rotate it so that our frame will be in a portrait
    image = convertYUV420ToImage(frame!);
    image = img.copyRotate(image!, angle: camDirec == CameraLensDirection.front ? 270 : 90);

    for (Face face in faces) {
      Rect faceRect = face.boundingBox;
      //TODO crop face
      img.Image croppedFace = img.copyCrop(image!,
          x: faceRect.left.toInt(),
          y: faceRect.top.toInt(),
          width: faceRect.width.toInt(),
          height: faceRect.height.toInt());

      //TODO pass cropped face to face recognition model
      // var rec = recognizer.recognize(croppedFace, faceRect, false);
      // ignore: use_build_context_synchronously
      await showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: false,
        context: context,
        builder: (context) {
          return FaceCroppedWidget(
            userFace: croppedFace,
            faceRect: faceRect,
            register: true,
          );
        },
      ).then((value) => safeSetState(() {}));

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
      //               onPressed: () async{
      // await recognizer.recognize(croppedFace, faceRect, true);
      //                 // ignore: use_build_context_synchronously
      //                 context.pushReplacementNamed('face_recognition_screen');
      //                 // print(croppedFace.data);
      //                 // Navigator.of(context).pop();
      //               },
      //             ),
      //           ],
      //         )
      //     );

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

  List<dynamic> imageToArray(img.Image inputImage) {
    img.Image resizedImage = img.copyResize(inputImage, width: 120, height: 120);
    List<double> flattenedList = resizedImage.data!
        .expand((channel) => [channel.r, channel.g, channel.b])
        .map((value) => value.toDouble())
        .toList();
    Float32List float32Array = Float32List.fromList(flattenedList);
    int channels = 3;
    int height = 120;
    int width = 120;
    Float32List reshapedArray = Float32List(1 * height * width * channels);
    for (int c = 0; c < channels; c++) {
      for (int h = 0; h < height; h++) {
        for (int w = 0; w < width; w++) {
          int index = c * height * width + h * width + w;
          reshapedArray[index] = (float32Array[c * height * width + h * width + w] - 127.5) / 127.5;
        }
      }
    }
    return reshapedArray.reshape([1, height, width, channels]);
  }

  // void notificationSnackbar(String title, String subTitle) {
  //   showOverlayNotification(
  //     key: flushKey,
  //     (context) {
  //       return Card(
  //         color: Colors.green,
  //         margin: const EdgeInsets.fromLTRB(12, 24, 12, 0),
  //         child: Row(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             const Padding(
  //               padding: EdgeInsets.only(left: 10),
  //               child: Icon(
  //                 Icons.notifications_active,
  //                 color: Colors.white,
  //                 size: 32,
  //               ),
  //             ),
  //             Expanded(
  //               child: Padding(
  //                 padding: const EdgeInsets.all(12.0),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       title,
  //                       textAlign: TextAlign.start,
  //                       style: const TextStyle(
  //                         fontSize: 15,
  //                         fontWeight: FontWeight.bold,
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                     Text(
  //                       subTitle,
  //                       textAlign: TextAlign.start,
  //                       style: const TextStyle(
  //                         fontSize: 13,
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //     duration: const Duration(days: 1),
  //   );
  // }

  doFaceDetectionOnFrame() async {
    //TODO convert frame into InputImage format

    InputImage inputImage = getInputImage();

    //TODO pass InputImage to face detection model and detect faces

    List<Face> faces = await faceDetector.processImage(inputImage);

    // for (Face face in faces) {
    //   switch (stage) {
    //     case 0:
    //       if (face.smilingProbability! > 0.85) {
    //         stage = 1;
    //         if (isSnackbarShowing) {
    //           // ignore: use_build_context_synchronously
    //           OverlaySupportEntry.of(context)!.dismiss();
    //           isSnackbarShowing = false;
    //         }
    //       } else if (!isSnackbarShowing) {
    //         isSnackbarShowing = true;
    //         notificationSnackbar('Sonríe para la camara', 'Subtitulo');
            
    //       }
    //       break;
    //     case 1:
    //       if (face.leftEyeOpenProbability! < 0.10 && face.rightEyeOpenProbability! > 0.80) {
    //         // ignore: use_build_context_synchronously
    //         OverlaySupportEntry.of(context)!.dismiss();
    //       } else {
    //         isSnackbarShowing = true;
    //         notificationSnackbar('Cierra el ojo derecho', 'Subtitulo');
    //       }
    //       break;
    //     default:
    //   }
    // }

    if (mounted) {
      setState(() {
        _scanResults = faces;
        isBusy = false;
      });
    }
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

  Widget buildResult() {
    if (_scanResults == null || controller == null || !controller.value.isInitialized) {
      return const Center(child: Text('Camera is not initialized'));
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

  @override
  void initState() {
    super.initState();

    //TODO initialize face detector
    faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        performanceMode: FaceDetectorMode.fast,
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

      stackChildren.add(
        Align(
          alignment: const AlignmentDirectional(0, 1),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
            child: Container(
              width: double.infinity,
              height: 86,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FlutterFlowIconButton(
                      borderRadius: 90,
                      borderWidth: 1,
                      buttonSize: 50,
                      fillColor: const Color(0xAC747474),
                      icon: const Icon(
                        Icons.cameraswitch_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        toggleCameraDirection();
                      },
                    ),
                    FlutterFlowIconButton(
                      borderColor: Colors.transparent,
                      borderRadius: 90,
                      borderWidth: 1,
                      buttonSize: 50,
                      fillColor: const Color(0xAC747474),
                      icon: const Icon(
                        Icons.camera,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () async{
                        await performFaceRecognition(_scanResults);
                      },
                    ),
                    FlutterFlowIconButton(
                      borderColor: Colors.transparent,
                      borderRadius: 90,
                      borderWidth: 1,
                      buttonSize: 50,
                      fillColor: const Color(0xAC747474),
                      icon: const Icon(
                        Icons.exit_to_app,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () async {
                        context.safePop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
