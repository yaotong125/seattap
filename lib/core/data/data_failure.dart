import 'package:cloud_firestore/cloud_firestore.dart';

/// A Firestore problem with a message that can be shown on screen.
class DataFailure implements Exception {
  const DataFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Runs a Firestore call and turns Firebase errors into [DataFailure].
Future<T> guardFirestore<T>(Future<T> Function() run) async {
  try {
    return await run();
  } on FirebaseException catch (e) {
    throw DataFailure(firestoreMessage(e.code));
  }
}

String firestoreMessage(String code) => switch (code) {
      'permission-denied' => "SeatTap couldn't save this. Check your details and try again.",
      'unavailable' => 'No internet connection. Check your connection and try again.',
      'not-found' => 'That record no longer exists.',
      _ => 'Something went wrong ($code). Try again.',
    };
