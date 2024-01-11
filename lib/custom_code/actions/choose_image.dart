// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:image_picker/image_picker.dart';

Future<String> chooseImage() async {
  final _picker = ImagePicker();

  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  return image!.path;
  // Add your function code here!
}
