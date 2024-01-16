import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  List<DocumentReference> _usersFaces = [];
  List<DocumentReference> get usersFaces => _usersFaces;
  set usersFaces(List<DocumentReference> _value) {
    _usersFaces = _value;
  }

  void addToUsersFaces(DocumentReference _value) {
    _usersFaces.add(_value);
  }

  void removeFromUsersFaces(DocumentReference _value) {
    _usersFaces.remove(_value);
  }

  void removeAtIndexFromUsersFaces(int _index) {
    _usersFaces.removeAt(_index);
  }

  void updateUsersFacesAtIndex(
    int _index,
    DocumentReference Function(DocumentReference) updateFn,
  ) {
    _usersFaces[_index] = updateFn(_usersFaces[_index]);
  }

  void insertAtIndexInUsersFaces(int _index, DocumentReference _value) {
    _usersFaces.insert(_index, _value);
  }
}

LatLng? _latLngFromString(String? val) {
  if (val == null) {
    return null;
  }
  final split = val.split(',');
  final lat = double.parse(split.first);
  final lng = double.parse(split.last);
  return LatLng(lat, lng);
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
