import '../../../workshop/data/repositories/firestore_workshop_job_repository.dart';
import '../../../workshop/domain/entities/workshop_job.dart';
import '../../../workshop/domain/repositories/workshop_job_repository.dart';
import '../../domain/entities/reception.dart';
import '../../domain/repositories/reception_repository.dart';
import '../../domain/services/reception_photo_storage.dart';
import '../../../workshop/data/services/firestore_workshop_job_number_generator.dart';
import '../../../workshop/domain/services/workshop_job_number_generator.dart';

class ReceptionController {
  ReceptionController({
    required ReceptionRepository repository,
    required ReceptionPhotoStorage photoStorage,
    WorkshopJobRepository? workshopJobRepository,
    WorkshopJobNumberGenerator? workshopJobNumberGenerator,
  })  : _repository = repository,
        _photoStorage = photoStorage,
        _workshopJobRepository =
            workshopJobRepository ?? FirestoreWorkshopJobRepository(),
        _workshopJobNumberGenerator =
            workshopJobNumberGenerator ?? FirestoreWorkshopJobNumberGenerator();

  final ReceptionRepository _repository;
  final ReceptionPhotoStorage _photoStorage;
  final WorkshopJobRepository _workshopJobRepository;
  final WorkshopJobNumberGenerator _workshopJobNumberGenerator;

  Stream<List<Reception>> watchReceptions({
    required String companyId,
  }) {
    return _repository.watchReceptions(
      companyId: companyId,
    );
  }

  Future<Reception?> getReception({
    required String companyId,
    required String receptionId,
  }) {
    return _repository.getReception(
      companyId: companyId,
      receptionId: receptionId,
    );
  }

  Future<String> createReception({
    required Reception reception,
    required List<String> localPhotoPaths,
  }) async {
    final now = DateTime.now();

    final receptionToCreate = reception.copyWith(
      photoUrls: const [],
      status: ReceptionStatus.received,
      workshopJobId: '',
      createdAt: now,
      updatedAt: now,
    );

    final receptionId = await _repository.createReception(
      reception: receptionToCreate,
    );

    final uploadedPhotoUrls = <String>[];

    try {
      for (final localPhotoPath in localPhotoPaths) {
        final photoUrl = await _photoStorage.uploadPhoto(
          companyId: reception.companyId,
          receptionId: receptionId,
          localFilePath: localPhotoPath,
        );

        uploadedPhotoUrls.add(photoUrl);
      }

      final jobNumber = await _workshopJobNumberGenerator.generate(
        companyId: reception.companyId,
      );

      final workshopJob = WorkshopJob(
        id: '',
        jobNumber: jobNumber,
        companyId: reception.companyId,
        receptionId: receptionId,
        clientId: reception.clientId,
        compressorId: reception.compressorId,
        clientName: reception.clientName,
        compressorName: reception.compressorName,
        status: WorkshopJobStatus.waiting,
        reasons: reception.reasons.map(_receptionReasonLabel).toList(),
        description: _buildWorkshopDescription(
          reception,
        ),
        observations: reception.observations,
        createdAt: now,
        updatedAt: now,
      );

      final workshopJobId = await _workshopJobRepository.createWorkshopJob(
        workshopJob: workshopJob,
      );

      final savedReception = receptionToCreate.copyWith(
        id: receptionId,
        photoUrls: uploadedPhotoUrls,
        status: ReceptionStatus.workCreated,
        workshopJobId: workshopJobId,
        updatedAt: DateTime.now(),
      );

      await _repository.updateReception(
        reception: savedReception,
      );

      return receptionId;
    } catch (error) {
      for (final photoUrl in uploadedPhotoUrls) {
        try {
          await _photoStorage.deletePhoto(
            photoUrl: photoUrl,
          );
        } catch (_) {
          // Evita esconder o erro original.
        }
      }

      rethrow;
    }
  }

  Future<void> updateReception({
    required Reception reception,
  }) {
    return _repository.updateReception(
      reception: reception,
    );
  }

  Future<void> cancelReception({
    required String companyId,
    required String receptionId,
  }) {
    return _repository.cancelReception(
      companyId: companyId,
      receptionId: receptionId,
    );
  }

  Future<void> deleteReception({
    required Reception reception,
  }) async {
    for (final photoUrl in reception.photoUrls) {
      await _photoStorage.deletePhoto(
        photoUrl: photoUrl,
      );
    }

    await _repository.deleteReception(
      companyId: reception.companyId,
      receptionId: reception.id,
    );
  }

  static String _receptionReasonLabel(
    ReceptionReason reason,
  ) {
    return switch (reason) {
      ReceptionReason.maintenance => 'Manutenção',
      ReceptionReason.breakdown => 'Avaria',
      ReceptionReason.modernization => 'Modernização',
    };
  }

  static String _buildWorkshopDescription(
    Reception reception,
  ) {
    final sections = <String>[];

    if (reception.hasMaintenance &&
        reception.expectedMaintenance.trim().isNotEmpty) {
      sections.add(
        'Manutenção prevista:\n'
        '${reception.expectedMaintenance.trim()}',
      );
    }

    if (reception.hasBreakdown) {
      if (reception.faultTypes.isNotEmpty) {
        final faultLabels =
            reception.faultTypes.map(Reception.faultTypeLabel).join(', ');

        sections.add(
          'Tipos de avaria:\n$faultLabels',
        );
      }

      if (reception.reportedFault.trim().isNotEmpty) {
        sections.add(
          'Avaria comunicada:\n'
          '${reception.reportedFault.trim()}',
        );
      }

      if (reception.expectedRepair.trim().isNotEmpty) {
        sections.add(
          'Reparação prevista:\n'
          '${reception.expectedRepair.trim()}',
        );
      }
    }

    if (reception.hasModernization &&
        reception.expectedModernization.trim().isNotEmpty) {
      sections.add(
        'Modernização prevista:\n'
        '${reception.expectedModernization.trim()}',
      );
    }

    if (sections.isEmpty) {
      return 'Obra criada automaticamente através da receção.';
    }

    return sections.join('\n\n');
  }
}
