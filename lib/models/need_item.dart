import 'package:cloud_firestore/cloud_firestore.dart';

enum NeedStatus { open, helping, completed }

extension NeedStatusX on NeedStatus {
  String get value {
    switch (this) {
      case NeedStatus.open:
        return 'open';
      case NeedStatus.helping:
        return 'helping';
      case NeedStatus.completed:
        return 'completed';
    }
  }

  String get label {
    switch (this) {
      case NeedStatus.open:
        return 'Open';
      case NeedStatus.helping:
        return 'Someone Helping';
      case NeedStatus.completed:
        return 'Completed';
    }
  }

  static NeedStatus fromValue(String? value) {
    switch (value) {
      case 'helping':
        return NeedStatus.helping;
      case 'completed':
        return NeedStatus.completed;
      default:
        return NeedStatus.open;
    }
  }
}

class NeedItem {
  const NeedItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.createdBy,
    required this.helperId,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String createdBy;
  final String? helperId;
  final NeedStatus status;
  final DateTime? createdAt;

  bool get isOpen => status == NeedStatus.open;
  bool get isHelping => status == NeedStatus.helping;
  bool get isCompleted => status == NeedStatus.completed;

  factory NeedItem.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? <String, dynamic>{};
    return NeedItem(
      id: doc.id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      location: map['location'] as String? ?? '',
      createdBy: map['createdBy'] as String? ?? '',
      helperId: map['helperId'] as String?,
      status: NeedStatusX.fromValue(map['status'] as String?),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'createdBy': createdBy,
      'helperId': helperId,
      'status': status.value,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }
}

