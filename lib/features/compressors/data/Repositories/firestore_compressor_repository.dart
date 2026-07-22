import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/compressor.dart';
import '../../domain/repositories/compressor_repository.dart';
import '../mappers/firestore_compressor_mapper.dart';

class FirestoreCompressorRepository implements CompressorRepository {
  FirestoreCompressorRepository(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> _collection({
    required String companyId,
    required String clientId,
  }) {
    return firestore
        .collection('empresas')
        .doc(companyId)
        .collection('clientes')
        .doc(clientId)
        .collection('compressores');
  }

  @override
  Future<List<Compressor>> getAll({
    required String companyId,
  }) async {
    final clientsSnapshot = await firestore
        .collection('empresas')
        .doc(companyId)
        .collection('clientes')
        .get();

    final compressors = <Compressor>[];

    for (final clientDocument in clientsSnapshot.docs) {
      final clientData = clientDocument.data();
      final clientName = (clientData['name'] ?? '').toString().trim();

      final snapshot =
          await clientDocument.reference.collection('compressores').get();

      for (final document in snapshot.docs) {
        final compressor = CompressorFirestoreMapper.fromFirestore(document);

        compressors.add(
          compressor.copyWith(
            clientId: clientDocument.id,
            clientName: clientName,
          ),
        );
      }
    }

    compressors.sort(
      (a, b) => a.displayName.toLowerCase().compareTo(
            b.displayName.toLowerCase(),
          ),
    );

    return compressors;
  }

  @override
  Future<List<Compressor>> getByClient({
    required String companyId,
    required String clientId,
  }) async {
    final snapshot = await _collection(
      companyId: companyId,
      clientId: clientId,
    ).get();

    final compressors =
        snapshot.docs.map(CompressorFirestoreMapper.fromFirestore).toList();

    compressors.sort(
      (a, b) => a.displayName.toLowerCase().compareTo(
            b.displayName.toLowerCase(),
          ),
    );

    return compressors;
  }

  @override
  Future<Compressor> save({
    required String companyId,
    required String clientId,
    required Compressor compressor,
  }) async {
    final collection = _collection(
      companyId: companyId,
      clientId: clientId,
    );

    final document = compressor.id.isEmpty
        ? collection.doc()
        : collection.doc(compressor.id);

    final entity = compressor.copyWith(
      id: document.id,
      companyId: companyId,
      clientId: clientId,
      updatedAt: DateTime.now(),
    );

    await document.set(
      CompressorFirestoreMapper.toFirestore(entity),
      SetOptions(merge: true),
    );

    return entity;
  }

  @override
  Future<void> delete({
    required String companyId,
    required String clientId,
    required String compressorId,
  }) async {
    await _collection(
      companyId: companyId,
      clientId: clientId,
    ).doc(compressorId).delete();
  }
}
