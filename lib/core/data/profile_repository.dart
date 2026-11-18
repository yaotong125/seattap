import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

/// Reads the signed-in user's own profile (`users/{uid}`). Shared by the session,
/// dashboards and profile screens; each feature writes through its own repository.
abstract class ProfileRepository {
  Stream<UserProfile?> watchProfile(String uid);
}

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Stream<UserProfile?> watchProfile(String uid) => _db.collection('users').doc(uid).snapshots().map((s) {
        final d = s.data();
        return d == null ? null : UserProfile.fromMap(s.id, d);
      });
}
