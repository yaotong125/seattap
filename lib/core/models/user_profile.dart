import 'dart:convert';
import 'dart:typed_data';

enum UserRole { student, invigilator, examOfficer }

extension UserRoleX on UserRole {
  String get label => switch (this) {
        UserRole.student => 'Student',
        UserRole.invigilator => 'Invigilator',
        UserRole.examOfficer => 'Exam Officer',
      };

  String get idLabel => this == UserRole.student ? 'Matric No.' : 'Staff ID';

  static UserRole? parse(Object? value) => switch (value) {
        'student' => UserRole.student,
        'invigilator' => UserRole.invigilator,
        'examOfficer' => UserRole.examOfficer,
        _ => null,
      };
}

enum ProfileStatus { active, pending, rejected }

ProfileStatus? parseStatus(Object? value) => switch (value) {
      'active' => ProfileStatus.active,
      'pending' => ProfileStatus.pending,
      'rejected' => ProfileStatus.rejected,
      _ => null,
    };

/// A SeatTap account profile: Firestore `users/{uid}`.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.idNumber,
    required this.role,
    required this.status,
    this.phone,
    this.faculty,
    this.photoUrl,
    this.createdAt,
  });

  final String uid;
  final String email;
  final String name;
  final String idNumber;
  final UserRole role;
  final ProfileStatus status;
  final String? phone;
  final String? faculty;

  /// A small `data:image/...;base64,...` picture, or null.
  final String? photoUrl;
  final DateTime? createdAt;

  /// Null when the stored data isn't a valid profile (unknown role or status).
  static UserProfile? fromMap(String uid, Map<String, dynamic> d) {
    final role = UserRoleX.parse(d['role']);
    final status = parseStatus(d['status']);
    if (role == null || status == null) return null;
    final created = d['createdAt'];
    return UserProfile(
      uid: uid,
      email: (d['email'] as String?) ?? '',
      name: (d['name'] as String?) ?? '',
      idNumber: (d['idNumber'] as String?) ?? '',
      role: role,
      status: status,
      phone: d['phone'] as String?,
      faculty: d['faculty'] as String?,
      photoUrl: d['photoUrl'] as String?,
      // Firestore Timestamps expose toDate(); kept dynamic so this file needs no Firebase import.
      createdAt: created == null ? null : (created as dynamic).toDate() as DateTime,
    );
  }

  /// Up to two initials for the avatar: "Dr. Farah Hanim" gives "FH".
  String get initials {
    final words = name
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && !w.endsWith('.'))
        .toList();
    if (words.isEmpty) return email.isEmpty ? '?' : email[0].toUpperCase();
    final first = words.first[0];
    final last = words.length > 1 ? words.last[0] : '';
    return (first + last).toUpperCase();
  }

  /// The decoded profile picture, or null.
  Uint8List? get photoBytes => decodePhoto(photoUrl);
}

Uint8List? decodePhoto(String? dataUrl) {
  if (dataUrl == null) return null;
  final comma = dataUrl.indexOf(',');
  if (comma < 0) return null;
  try {
    return base64Decode(dataUrl.substring(comma + 1));
  } on FormatException {
    return null;
  }
}
