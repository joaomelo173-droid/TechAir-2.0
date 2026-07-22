import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/intervention.dart';
import '../../domain/repositories/intervention_repository.dart';
import '../mappers/firestore_intervention_mapper.dart';

class FirestoreInterventionRepository
    implements InterventionRepository {
  FirestoreInterventionRepository(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> _collection({
    required String companyId,
    required String clientId,
    required String compressorId,
  }) {
    return firestore
        .collection('empresas')
        .doc(companyId)
        .collection('clientes')
        .doc(clientId)
        .collection('compressores')
        .doc(compressorId)
        .collection('intervencoes');
  }

  @override
Future<List<Intervention>> getAll({
  required String companyId,
}) async {
  final clientsSnapshot = await firestore
      .collection('empresas')
      .doc(companyId)
      .collection('clientes')
      .get();

  final interventions = <Intervention>[];

  for (final clientDocument in clientsSnapshot.docs) {
    final clientData = clientDocument.data();
    final clientName = (clientData['name'] ?? '').toString().trim();

    final compressorsSnapshot =
        await clientDocument.reference.collection('compressores').get();

    for (final compressorDocument in compressorsSnapshot.docs) {
      final compressorData = compressorDocument.data();

      final compressorName = [
        (compressorData['brand'] ?? '').toString().trim(),
        (compressorData['model'] ?? '').toString().trim(),
      ].where((value) => value.isNotEmpty).join(' ');

      final interventionsSnapshot = await compressorDocument.reference
          .collection('intervencoes')
          .get();

      for (final interventionDocument in interventionsSnapshot.docs) {
        final intervention =
            FirestoreInterventionMapper.fromFirestore(
          interventionDocument,
        );

        interventions.add(
          intervention.copyWith(
            companyId: companyId,
            clientId: clientDocument.id,
            compressorId: compressorDocument.id,
            clientName: intervention.clientName.isNotEmpty
                ? intervention.clientName
                : clientName,
            compressorName: intervention.compressorName.isNotEmpty
                ? intervention.compressorName
                : compressorName,
          ),
        );
      }
    }
  }

  interventions.sort(
    (a, b) => b.startedAt.compareTo(a.startedAt),
  );

  return interventions;
}

  @override
  Future<List<Intervention>> getByCompressor({
    required String companyId,
    required String clientId,
    required String compressorId,
  }) async {
    final snapshot = await _collection(
      companyId: companyId,
      clientId: clientId,
      compressorId: compressorId,
    ).orderBy(
      'startedAt',
      descending: true,
    ).get();

    return snapshot.docs
        .map(FirestoreInterventionMapper.fromFirestore)
        .toList();
  }

  @override
  Future<Intervention> save({
    required String companyId,
    required String clientId,
    required String compressorId,
    required Intervention intervention,
  }) async {
    final collection = _collection(
      companyId: companyId,
      clientId: clientId,
      compressorId: compressorId,
    );

    final document = intervention.id.isEmpty
        ? collection.doc()
        : collection.doc(intervention.id);

    final now = DateTime.now();

    final entity = intervention.copyWith(
      id: document.id,
      companyId: companyId,
      clientId: clientId,
      compressorId: compressorId,
      clientName: intervention.clientName,
compressorName: intervention.compressorName,
      createdAt: intervention.id.isEmpty
          ? now
          : intervention.createdAt,
      updatedAt: now,
    );

    await document.set(
      FirestoreInterventionMapper.toFirestore(entity),
      SetOptions(merge: true),
    );

    return entity;
  }

  @override
  Future<void> delete({
    required String companyId,
    required String clientId,
    required String compressorId,
    required String interventionId,
  }) async {
    await _collection(
      companyId: companyId,
      clientId: clientId,
      compressorId: compressorId,
    ).doc(interventionId).delete();
  }
}