// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersFacesStruct extends FFFirebaseStruct {
  UsersFacesStruct({
    String? name,
    String? embedding,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _name = name,
        _embedding = embedding,
        super(firestoreUtilData);

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;
  bool hasName() => _name != null;

  // "embedding" field.
  String? _embedding;
  String get embedding => _embedding ?? '';
  set embedding(String? val) => _embedding = val;
  bool hasEmbedding() => _embedding != null;

  static UsersFacesStruct fromMap(Map<String, dynamic> data) =>
      UsersFacesStruct(
        name: data['name'] as String?,
        embedding: data['embedding'] as String?,
      );

  static UsersFacesStruct? maybeFromMap(dynamic data) => data is Map
      ? UsersFacesStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'name': _name,
        'embedding': _embedding,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'embedding': serializeParam(
          _embedding,
          ParamType.String,
        ),
      }.withoutNulls;

  static UsersFacesStruct fromSerializableMap(Map<String, dynamic> data) =>
      UsersFacesStruct(
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
        embedding: deserializeParam(
          data['embedding'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'UsersFacesStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is UsersFacesStruct &&
        name == other.name &&
        embedding == other.embedding;
  }

  @override
  int get hashCode => const ListEquality().hash([name, embedding]);
}

UsersFacesStruct createUsersFacesStruct({
  String? name,
  String? embedding,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    UsersFacesStruct(
      name: name,
      embedding: embedding,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

UsersFacesStruct? updateUsersFacesStruct(
  UsersFacesStruct? usersFaces, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    usersFaces
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addUsersFacesStructData(
  Map<String, dynamic> firestoreData,
  UsersFacesStruct? usersFaces,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (usersFaces == null) {
    return;
  }
  if (usersFaces.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && usersFaces.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final usersFacesData = getUsersFacesFirestoreData(usersFaces, forFieldValue);
  final nestedData = usersFacesData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = usersFaces.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getUsersFacesFirestoreData(
  UsersFacesStruct? usersFaces, [
  bool forFieldValue = false,
]) {
  if (usersFaces == null) {
    return {};
  }
  final firestoreData = mapToFirestore(usersFaces.toMap());

  // Add any Firestore field values
  usersFaces.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getUsersFacesListFirestoreData(
  List<UsersFacesStruct>? usersFacess,
) =>
    usersFacess?.map((e) => getUsersFacesFirestoreData(e, true)).toList() ?? [];
