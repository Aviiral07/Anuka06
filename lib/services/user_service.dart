import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class UserService {
  UserService._();

  static final UserService instance = UserService._();

  final CollectionReference<Map<String, dynamic>> _users =
      FirebaseFirestore.instance.collection('users');

  Stream<AppUser?> watchUser(String userId) {
    return _users.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return AppUser.fromMap(snapshot.data() ?? <String, dynamic>{});
    });
  }

  Future<void> saveOnboarding({
    required User firebaseUser,
    required String name,
  }) async {
    final docRef = _users.doc(firebaseUser.uid);
    final snapshot = await docRef.get();
    final existingCreatedAt = snapshot.data()?['createdAt'];

    await docRef.set({
      'userId': firebaseUser.uid,
      'name': name.trim(),
      'createdAt': existingCreatedAt ?? FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
