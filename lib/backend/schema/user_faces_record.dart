import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UserFacesRecord extends FirestoreRecord {
  UserFacesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "embedding" field.
  String? _embedding;
  String get embedding => _embedding ?? '';
  bool hasEmbedding() => _embedding != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _embedding = snapshotData['embedding'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('user_faces');

  static Stream<UserFacesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UserFacesRecord.fromSnapshot(s));

  static Future<UserFacesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UserFacesRecord.fromSnapshot(s));

  static UserFacesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      UserFacesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UserFacesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UserFacesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UserFacesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UserFacesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUserFacesRecordData({
  String? name,
  String? embedding,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'embedding': embedding,
    }.withoutNulls,
  );

  return firestoreData;
}

class UserFacesRecordDocumentEquality implements Equality<UserFacesRecord> {
  const UserFacesRecordDocumentEquality();

  @override
  bool equals(UserFacesRecord? e1, UserFacesRecord? e2) {
    return e1?.name == e2?.name && e1?.embedding == e2?.embedding;
  }

  @override
  int hash(UserFacesRecord? e) =>
      const ListEquality().hash([e?.name, e?.embedding]);

  @override
  bool isValidKey(Object? o) => o is UserFacesRecord;
}
