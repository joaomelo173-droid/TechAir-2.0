import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/workshop_service.dart';
import '../../domain/repositories/workshop_service_repository.dart';
import '../mappers/workshop_service_firestore_mapper.dart';

class FirestoreWorkshopServiceRepository implements WorkshopServiceRepository {
  FirestoreWorkshopServiceRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _servicesCollection({
    required String companyId,
    required String workshopJobId,
  }) {
    return _firestore
        .collection('empresas')
        .doc(companyId)
        .collection('obras')
        .doc(workshopJobId)
        .collection('servicos');
  }

  @override
  Stream<List<WorkshopService>> watchServices({
    required String companyId,
    required String workshopJobId,
  }) {
    return _servicesCollection(
      companyId: companyId,
      workshopJobId: workshopJobId,
    ).orderBy('order').snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                WorkshopServiceFirestoreMapper.fromFirestore,
              )
              .toList(),
        );
  }

  @override
  Future<void> createService({
    required String companyId,
    required String workshopJobId,
    required WorkshopService service,
  }) async {
    final collection = _servicesCollection(
      companyId: companyId,
      workshopJobId: workshopJobId,
    );

    final document = service.id.trim().isEmpty
        ? collection.doc()
        : collection.doc(service.id);

    final serviceToSave = service.copyWith(
      id: document.id,
      workshopJobId: workshopJobId,
    );

    await document.set(
      WorkshopServiceFirestoreMapper.toFirestore(
        serviceToSave,
      ),
    );
  }

  @override
  Future<void> updateService({
    required String companyId,
    required String workshopJobId,
    required WorkshopService service,
  }) async {
    if (service.id.trim().isEmpty) {
      throw ArgumentError(
        'Não é possível atualizar um serviço sem ID.',
      );
    }

    final updatedService = service.copyWith(
      workshopJobId: workshopJobId,
      updatedAt: DateTime.now(),
    );

    await _servicesCollection(
      companyId: companyId,
      workshopJobId: workshopJobId,
    ).doc(service.id).set(
          WorkshopServiceFirestoreMapper.toFirestore(
            updatedService,
          ),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> deleteService({
    required String companyId,
    required String workshopJobId,
    required String serviceId,
  }) async {
    if (serviceId.trim().isEmpty) {
      throw ArgumentError(
        'Não é possível eliminar um serviço sem ID.',
      );
    }

    await _servicesCollection(
      companyId: companyId,
      workshopJobId: workshopJobId,
    ).doc(serviceId).delete();
  }
}
