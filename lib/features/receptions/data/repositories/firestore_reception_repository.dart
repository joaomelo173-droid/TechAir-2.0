import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/reception.dart';
import '../../domain/repositories/reception_repository.dart';
import '../mappers/firestore_reception_mapper.dart';

class FirestoreReceptionRepository
    implements ReceptionRepository {
  FirestoreReceptionRepository({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
      _receptionsCollection(String companyId) {
    return _firestore
        .collection('empresas')
        .doc(companyId)
        .collection('rececoes');
  }

  @override
  Stream<List<Reception>> watchReceptions({
    required String companyId,
  }) {
    return _receptionsCollection(companyId)
        .orderBy('receivedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(FirestoreReceptionMapper.fromFirestore)
              .toList(),
        );
  }

  @override
  Stream<List<Reception>> watchClientReceptions({
    required String companyId,
    required String clientId,
  }) {
    return _receptionsCollection(companyId)
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) {
      final receptions = snapshot.docs
          .map(FirestoreReceptionMapper.fromFirestore)
          .toList();

      receptions.sort(
        (a, b) => b.receivedAt.compareTo(a.receivedAt),
      );

      return receptions;
    });
  }

  @override
  Stream<List<Reception>> watchCompressorReceptions({
    required String companyId,
    required String compressorId,
  }) {
    return _receptionsCollection(companyId)
        .where('compressorId', isEqualTo: compressorId)
        .snapshots()
        .map((snapshot) {
      final receptions = snapshot.docs
          .map(FirestoreReceptionMapper.fromFirestore)
          .toList();

      receptions.sort(
        (a, b) => b.receivedAt.compareTo(a.receivedAt),
      );

      return receptions;
    });
  }

  @override
  Future<Reception?> getReception({
    required String companyId,
    required String receptionId,
  }) async {
    final document = await _receptionsCollection(companyId)
        .doc(receptionId)
        .get();

    if (!document.exists) {
      return null;
    }

    return FirestoreReceptionMapper.fromFirestore(
      document,
    );
  }

  @override
  Future<String> createReception({
    required Reception reception,
  }) async {
    final collection =
        _receptionsCollection(reception.companyId);

    final document = reception.id.trim().isEmpty
        ? collection.doc()
        : collection.doc(reception.id);

    final receptionToSave = reception.copyWith(
      id: document.id,
    );

    await document.set(
      FirestoreReceptionMapper.toFirestore(
        receptionToSave,
      ),
    );

    return document.id;
  }

  @override
  Future<void> updateReception({
    required Reception reception,
  }) async {
    if (reception.id.trim().isEmpty) {
      throw ArgumentError(
        'Não é possível atualizar uma receção sem ID.',
      );
    }

    final updatedReception = reception.copyWith(
      updatedAt: DateTime.now(),
    );

    await _receptionsCollection(reception.companyId)
        .doc(reception.id)
        .set(
          FirestoreReceptionMapper.toFirestore(
            updatedReception,
          ),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> cancelReception({
    required String companyId,
    required String receptionId,
  }) async {
    if (receptionId.trim().isEmpty) {
      throw ArgumentError(
        'O ID da receção é obrigatório.',
      );
    }

    await _receptionsCollection(companyId)
        .doc(receptionId)
        .update({
      'status': ReceptionStatus.cancelled.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  @override
  Future<void> deleteReception({
    required String companyId,
    required String receptionId,
  }) async {
    if (receptionId.trim().isEmpty) {
      throw ArgumentError(
        'O ID da receção é obrigatório.',
      );
    }

    await _receptionsCollection(companyId)
        .doc(receptionId)
        .delete();
  }
}