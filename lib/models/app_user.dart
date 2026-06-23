import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.userId,
    required this.name,
    required this.createdAt,
  });

  final String userId;
  final String name;
  final DateTime? createdAt;

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      userId: map['userId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }
}

