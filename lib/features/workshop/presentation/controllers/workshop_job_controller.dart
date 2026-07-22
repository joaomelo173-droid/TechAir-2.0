import '../../data/repositories/firestore_workshop_job_repository.dart';
import '../../domain/entities/workshop_job.dart';
import '../../domain/repositories/workshop_job_repository.dart';

class WorkshopJobController {
  WorkshopJobController({
    WorkshopJobRepository? repository,
  }) : _repository = repository ?? FirestoreWorkshopJobRepository();

  final WorkshopJobRepository _repository;

  Stream<List<WorkshopJob>> watchWorkshopJobs({
    required String companyId,
  }) {
    return _repository.watchWorkshopJobs(
      companyId: companyId,
    );
  }

  Future<WorkshopJob?> getWorkshopJob({
    required String companyId,
    required String workshopJobId,
  }) {
    return _repository.getWorkshopJob(
      companyId: companyId,
      workshopJobId: workshopJobId,
    );
  }

  Future<String> createWorkshopJob({
    required WorkshopJob workshopJob,
  }) {
    return _repository.createWorkshopJob(
      workshopJob: workshopJob,
    );
  }

  Future<void> updateWorkshopJob({
    required WorkshopJob workshopJob,
  }) {
    return _repository.updateWorkshopJob(
      workshopJob: workshopJob,
    );
  }
}
