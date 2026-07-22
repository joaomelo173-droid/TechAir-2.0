import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/services/workshop_job_number_generator.dart';

class FirestoreWorkshopJobNumberGenerator
    implements WorkshopJobNumberGenerator {
  FirestoreWorkshopJobNumberGenerator({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<String> generate({
    required String companyId,
  }) async {
    final year = DateTime.now().year;

    final counterRef = _firestore
        .collection('empresas')
        .doc(companyId)
        .collection('counters')
        .doc('workshop_$year');

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);

      int next = 1;

      if (snapshot.exists) {
        final data = snapshot.data()!;
        next = (data['lastNumber'] as int? ?? 0) + 1;
      }

      transaction.set(counterRef, {
        'year': year,
        'lastNumber': next,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return 'OB-$year-${next.toString().padLeft(6, '0')}';
    });
  }
}
