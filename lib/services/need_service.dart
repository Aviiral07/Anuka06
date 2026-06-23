import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/need_item.dart';

class NeedService {
  NeedService._();

  static final NeedService instance = NeedService._();

  final CollectionReference<Map<String, dynamic>> _needs =
      FirebaseFirestore.instance.collection('needs');

  Stream<List<NeedItem>> watchNeeds() {
    return _needs.orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) {
        return snapshot.docs.map(NeedItem.fromDocument).toList();
      },
    );
  }

  Future<void> createNeed({
    required String title,
    required String description,
    required String category,
    required String location,
    required String createdBy,
  }) async {
    await _needs.add({
      'title': title.trim(),
      'description': description.trim(),
      'category': category,
      'location': location.trim(),
      'createdBy': createdBy,
      'helperId': null,
      'status': NeedStatus.open.value,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> claimNeed({
    required String needId,
    required String helperId,
  }) async {
    final docRef = _needs.doc(needId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = snapshot.data();
      if (data == null) {
        throw Exception('Need not found.');
      }

      final currentStatus = data['status'] as String? ?? NeedStatus.open.value;
      final currentHelperId = data['helperId'] as String?;
      final createdBy = data['createdBy'] as String? ?? '';

      if (currentStatus != NeedStatus.open.value || currentHelperId != null) {
        throw Exception('This need already has a helper.');
      }

      if (createdBy == helperId) {
        throw Exception('You cannot help on your own need.');
      }

      transaction.update(docRef, {
        'status': NeedStatus.helping.value,
        'helperId': helperId,
      });
    });
  }

  Future<void> markCompleted({
    required NeedItem need,
    required String userId,
  }) async {
    final isAllowed = need.createdBy == userId || need.helperId == userId;
    if (!isAllowed) {
      throw Exception('Only the creator or helper can complete this need.');
    }

    if (!need.isHelping) {
      throw Exception('Only needs in progress can be completed.');
    }

    await _needs.doc(need.id).update({
      'status': NeedStatus.completed.value,
    });
  }
}
