import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/workshop_job.dart';
import '../../domain/repositories/workshop_job_repository.dart';
import '../mappers/workshop_job_firestore_mapper.dart';

class FirestoreWorkshopJobRepository implements WorkshopJobRepository {
  FirestoreWorkshopJobRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _workshopJobsCollection(
    String companyId,
  ) {
    return _firestore.collection('empresas').doc(companyId).collection('obras');
  }

  @override
  Stream<List<WorkshopJob>> watchWorkshopJobs({
    required String companyId,
  }) {
    return _workshopJobsCollection(companyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                WorkshopJobFirestoreMapper.fromFirestore,
              )
              .toList(),
        );
  }

  @override
  Future<WorkshopJob?> getWorkshopJob({
    required String companyId,
    required String workshopJobId,
  }) async {
    final document =
        await _workshopJobsCollection(companyId).doc(workshopJobId).get();

    if (!document.exists) {
      return null;
    }

    return WorkshopJobFirestoreMapper.fromFirestore(
      document,
    );
  }

  @override
  Future<String> createWorkshopJob({
    required WorkshopJob workshopJob,
  }) async {
    final collection = _workshopJobsCollection(workshopJob.companyId);

    final document = workshopJob.id.trim().isEmpty
        ? collection.doc()
        : collection.doc(workshopJob.id);

    final jobToSave = workshopJob.copyWith(
      id: document.id,
    );

    await document.set(
      WorkshopJobFirestoreMapper.toFirestore(
        jobToSave,
      ),
    );

    return document.id;
  }

  @override
  Future<void> updateWorkshopJob({
    required WorkshopJob workshopJob,
  }) async {
    if (workshopJob.id.trim().isEmpty) {
      throw ArgumentError(
        'Não é possível atualizar uma obra sem ID.',
      );
    }

    final updatedJob = workshopJob.copyWith(
      updatedAt: DateTime.now(),
    );

    await _workshopJobsCollection(
      workshopJob.companyId,
    ).doc(workshopJob.id).set(
          WorkshopJobFirestoreMapper.toFirestore(
            updatedJob,
          ),
          SetOptions(merge: true),
        );
  }
}
