import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:tgo_acudir/app_state.dart';
import 'package:tgo_acudir/backend/backend.dart';
import 'package:tgo_acudir/backend/schema/user_faces_record.dart';

class Recognizer {
  late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;
  static const int WIDTH = 112;
  static const int HEIGHT = 112;
  @override
  String get modelName => 'assets/tfmodels/mobile_face_net.tflite';

  Recognizer({int? numThreads}) {
    _interpreterOptions = InterpreterOptions();
    if (numThreads != null) {
      _interpreterOptions.threads = numThreads;
    }
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset(modelName);
    } catch (e) {
      print('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  List<dynamic> imageToArray(img.Image inputImage) {
    img.Image resizedImage = img.copyResize(inputImage!, width: WIDTH, height: HEIGHT);
    List<double> flattenedList = resizedImage.data!
        .expand((channel) => [channel.r, channel.g, channel.b])
        .map((value) => value.toDouble())
        .toList();
    Float32List float32Array = Float32List.fromList(flattenedList);
    int channels = 3;
    int height = HEIGHT;
    int width = WIDTH;
    Float32List reshapedArray = Float32List(1 * height * width * channels);
    for (int c = 0; c < channels; c++) {
      for (int h = 0; h < height; h++) {
        for (int w = 0; w < width; w++) {
          int index = c * height * width + h * width + w;
          reshapedArray[index] = (float32Array[c * height * width + h * width + w] - 127.5) / 127.5;
        }
      }
    }
    return reshapedArray.reshape([1, 112, 112, 3]);
  }

  Future<void> recognize(img.Image image, Rect location, bool register, String? name) async {
    //TODO crop face from image resize it and convert it to float array
    var input = imageToArray(image);
    print(input.shape.toString());

    //TODO output array
    List output = List.filled(1 * 192, 0).reshape([1, 192]);

    //TODO performs inference
    interpreter.run(input, output);

    //TODO convert dynamic list to double list
    List<double> outputArray = output.first.cast<double>();

    (register)
        ? await UserFacesRecord.collection.doc().set(createUserFacesRecordData(
              name: name,
              embedding: outputArray.toString(),
            ))
        : findNearest(outputArray);

    //TODO looks for the nearest embeeding in the database and returns the pair
    // Pair pair = findNearest(outputArray);
    // print("distance= ${pair.distance}");

    // return Recognition(pair.name, location, outputArray, pair.distance);
  }

  findNearest(List<double> emb) async {
    Pair pair = Pair("Unknown", -5);
    final usersFaces = FFAppState().usersFaces.toList();
    for (var userFace in usersFaces) {
      final usersFacesItem = await UserFacesRecord.getDocumentOnce(userFace);
      final String name = usersFacesItem.name;
      List<double> knownEmb = List.castFrom(jsonDecode(usersFacesItem.embedding));
      double distance = 0;
      for (int i = 0; i < emb.length; i++) {
        double diff = emb[i] - knownEmb[i];
        distance += diff * diff;
      }
      distance = sqrt(distance);
      // if (distance < pair.distance) {
      //   pair.distance = distance;
      //   pair.name = name;
      // }
      if (pair.distance == -5 || distance < pair.distance) {
        pair.distance = distance;
        pair.name = name;
      }
    }
    print('Nombre: ${pair.name}, Distancia: ${pair.distance}');
    // if (pair.distance == double.infinity) {
    //   print("Cara desconocida");
    // } else {
    //   print("Nombre: ${pair.name}, Distancia: ${pair.distance}");
    // }
    // return pair;
  }

  // findNearest(List<double> emb) async{
  //   Pair pair = Pair("Unknown", -5);
  //   final usersFaces = await queryUserFacesRecordOnce();
  //   for(var userFace in usersFaces) {
  //     final String name = userFace.name;
  //     List<double> knownEmb = List.castFrom(jsonDecode(userFace.embedding));
  //     double distance = 0;
  //     for (int i = 0; i < emb.length; i++) {
  //       double diff = emb[i] - knownEmb[i];
  //       distance += diff * diff;
  //     }
  //     distance = sqrt(distance);
  //     if (pair.distance == -5 || distance < pair.distance) {
  //       pair.distance = distance;
  //       pair.name = name;
  //     }

  //   }
  //   return pair;
  // }
}

class Pair {
  String name;
  double distance;
  Pair(this.name, this.distance);
}
