import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/data/data_failure.dart';
import '../../../core/models/user_profile.dart';

/// Pending invigilator sign-ups and the Exam Officer's decision on them.
abstract class StaffApprovalsRepository {
  Stream<List<UserProfile>> watchPendingStaff();
  Future<void> reviewStaff({required String reviewerUid, required UserProfile staff, required bool approve});
}

class FirestoreStaffApprovalsRepository implements StaffApprovalsRepository {
  FirestoreStaffApprovalsRepository([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Stream<List<UserProfile>> watchPendingStaff() => _db
      .collection('users')
      .where('status', isEqualTo: 'pending')
      .orderBy('createdAt')
      .snapshots()
      .map((q) => q.docs.map((d) => UserProfile.fromMap(d.id, d.data())).whereType<UserProfile>().toList());

  @override
  Future<void> reviewStaff({required String reviewerUid, required UserProfile staff, required bool approve}) =>
      guardFirestore(() {
        final batch = _db.batch();
        batch.update(_db.collection('users').doc(staff.uid), {
          'status': approve ? 'active' : 'rejected',
          'reviewedBy': reviewerUid,
          'reviewedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        if (approve) {
          // Approved invigilators join the roster, as if the Exam Office had listed them.
          batch.set(_db.collection('directory').doc(staff.email), {
            'email': staff.email,
            'idNumber': staff.idNumber,
            'name': staff.name,
            'role': 'invigilator',
            'addedBy': reviewerUid,
            'addedAt': FieldValue.serverTimestamp(),
          });
        }
        return batch.commit();
      });
}
