import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../mappers/client_firestore_mapper.dart';

class FirestoreClientRepository implements ClientRepository {
  FirestoreClientRepository(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> _clients(String companyId) {
    return firestore
        .collection('empresas')
        .doc(companyId)
        .collection('clientes');
  }

  @override
  Future<List<Client>> getAll({
    required String companyId,
  }) async {
    final snapshot = await _clients(companyId).orderBy('name').get();

    return snapshot.docs
        .map(ClientFirestoreMapper.fromFirestore)
        .toList();
  }

  @override
  Future<Client> save({
    required String companyId,
    required Client client,
  }) async {
    final collection = _clients(companyId);

    final doc = client.id.isEmpty
        ? collection.doc()
        : collection.doc(client.id);

    final entity = client.copyWith(
      id: doc.id,
      updatedAt: DateTime.now(),
    );

    await doc.set(
      ClientFirestoreMapper.toFirestore(entity),
      SetOptions(merge: true),
    );

    return entity;
  }

  @override
  Future<void> delete({
    required String companyId,
    required String clientId,
  }) async {
    await _clients(companyId).doc(clientId).delete();
  }
}