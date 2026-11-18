import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/data/data_failure.dart';

/// Saves the fields a user may change on their own profile. Firestore rules refuse
/// changes to email, ID, role and status.
abstract class EditProfileRepository {
  Future<void> updateProfile(String uid, {required String name, String? phone, String? faculty, String? photoUrl});
}

class FirestoreEditProfileRepository implements EditProfileRepository {
  FirestoreEditProfileRepository([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Future<void> updateProfile(String uid, {required String name, String? phone, String? faculty, String? photoUrl}) =>
      guardFirestore(() => _db.collection('users').doc(uid).update({
            'name': name,
            'phone': (phone == null || phone.isEmpty) ? FieldValue.delete() : phone,
            'faculty': (faculty == null || faculty.isEmpty) ? FieldValue.delete() : faculty,
            'photoUrl': photoUrl ?? FieldValue.delete(),
            'updatedAt': FieldValue.serverTimestamp(),
          }));
}
