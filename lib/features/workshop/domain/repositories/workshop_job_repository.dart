import '../entities/workshop_job.dart';

abstract interface class WorkshopJobRepository {
  Stream<List<WorkshopJob>> watchWorkshopJobs({
    required String companyId,
  });

  Future<WorkshopJob?> getWorkshopJob({
    required String companyId,
    required String workshopJobId,
  });

  Future<String> createWorkshopJob({
    required WorkshopJob workshopJob,
  });

  Future<void> updateWorkshopJob({
    required WorkshopJob workshopJob,
  });
}
