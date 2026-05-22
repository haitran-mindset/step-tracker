import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUserService {
  FirestoreUserService._();
  static final FirestoreUserService instance = FirestoreUserService._();

  final _db = FirebaseFirestore.instance;
  static const _collection = 'users';

  /// Creates a minimal user document in Firestore when a new user registers.
  /// Profile info (name, height, weight, etc.) will be filled in by the user
  /// on the SetupProfilePage.
  Future<void> createUserDocument({
    required String uid,
    required String email,
  }) async {
    final docRef = _db.collection(_collection).doc(uid);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      await docRef.set({
        'uid': uid,
        'email': email,
        'profileComplete': false,
        'totalLifetimeSteps': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Reads a user's profile from Firestore.
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final snapshot = await _db.collection(_collection).doc(uid).get();
    return snapshot.data();
  }

  /// Streams a user's profile in real-time.
  Stream<Map<String, dynamic>?> streamUserProfile(String uid) {
    return _db
        .collection(_collection)
        .doc(uid)
        .snapshots()
        .map((snap) => snap.data());
  }

  /// Updates user profile fields in Firestore.
  Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    final docRef = _db.collection(_collection).doc(uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      // If the document does not exist (e.g. legacy account or failed creation),
      // initialize it with default values and merge the profile data.
      await docRef.set({
        'uid': uid,
        'totalLifetimeSteps': 0,
        'createdAt': FieldValue.serverTimestamp(),
        ...data,
      });
    } else {
      // If it already exists, safely merge the new fields without affecting existing ones.
      await docRef.set(data, SetOptions(merge: true));
    }
  }
}
