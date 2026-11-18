import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/data/data_failure.dart';
import '../../../core/models/user_profile.dart';

/// An entry on the Exam Office roster: Firestore `directory/{email}`.
class DirectoryEntry {
  const DirectoryEntry({required this.email, required this.idNumber, required this.role, this.name, this.faculty});

  final String email;
  final String idNumber;
  final UserRole role;
  final String? name;
  final String? faculty;

  static DirectoryEntry? fromMap(Map<String, dynamic> d) {
    final role = UserRoleX.parse(d['role']);
    if (role == null) return null;
    return DirectoryEntry(
      email: (d['email'] as String?) ?? '',
      idNumber: (d['idNumber'] as String?) ?? '',
      role: role,
      name: d['name'] as String?,
      faculty: d['faculty'] as String?,
    );
  }
}

/// What Complete profile writes to `users/{uid}`.
class NewProfile {
  const NewProfile({
    required this.email,
    required this.name,
    required this.idNumber,
    required this.role,
    required this.status,
    this.phone,
    this.faculty,
  });

  final String email;
  final String name;
  final String idNumber;
  final UserRole role;
  final ProfileStatus status;
  final String? phone;
  final String? faculty;
}

/// Registration data: the caller's own roster entry and their new profile.
/// Firestore rules only accept a profile that agrees with the roster.
abstract class RegistrationRepository {
  Future<DirectoryEntry?> getOwnDirectoryEntry(String email);
  Future<void> createProfile(String uid, NewProfile profile);
}

class FirestoreRegistrationRepository implements RegistrationRepository {
  FirestoreRegistrationRepository([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Future<DirectoryEntry?> getOwnDirectoryEntry(String email) => guardFirestore(() async {
        final s = await _db.collection('directory').doc(email.toLowerCase()).get();
        final d = s.data();
        return d == null ? null : DirectoryEntry.fromMap(d);
      });

  @override
  Future<void> createProfile(String uid, NewProfile p) => guardFirestore(() => _db.collection('users').doc(uid).set({
        'email': p.email,
        'name': p.name,
        'idNumber': p.idNumber,
        'role': p.role.name,
        'status': p.status.name,
        if (p.phone != null && p.phone!.isNotEmpty) 'phone': p.phone,
        if (p.faculty != null && p.faculty!.isNotEmpty) 'faculty': p.faculty,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }));
}
