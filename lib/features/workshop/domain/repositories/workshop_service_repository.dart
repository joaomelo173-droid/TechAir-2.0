import '../entities/workshop_service.dart';

abstract class WorkshopServiceRepository {
  Stream<List<WorkshopService>> watchServices({
    required String companyId,
    required String workshopJobId,
  });

  Future<void> createService({
    required String companyId,
    required String workshopJobId,
    required WorkshopService service,
  });

  Future<void> updateService({
    required String companyId,
    required String workshopJobId,
    required WorkshopService service,
  });

  Future<void> deleteService({
    required String companyId,
    required String workshopJobId,
    required String serviceId,
  });
}
