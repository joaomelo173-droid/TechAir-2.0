import '../../data/repositories/firestore_workshop_service_repository.dart';
import '../../domain/entities/workshop_service.dart';
import '../../domain/repositories/workshop_service_repository.dart';

class WorkshopServiceController {
  WorkshopServiceController({
    WorkshopServiceRepository? repository,
  }) : _repository = repository ?? FirestoreWorkshopServiceRepository();

  final WorkshopServiceRepository _repository;

  Stream<List<WorkshopService>> watchServices({
    required String companyId,
    required String workshopJobId,
  }) {
    return _repository.watchServices(
      companyId: companyId,
      workshopJobId: workshopJobId,
    );
  }

  Future<void> createService({
    required String companyId,
    required String workshopJobId,
    required WorkshopService service,
  }) {
    return _repository.createService(
      companyId: companyId,
      workshopJobId: workshopJobId,
      service: service,
    );
  }

  Future<void> updateService({
    required String companyId,
    required String workshopJobId,
    required WorkshopService service,
  }) {
    return _repository.updateService(
      companyId: companyId,
      workshopJobId: workshopJobId,
      service: service,
    );
  }

  Future<void> deleteService({
    required String companyId,
    required String workshopJobId,
    required String serviceId,
  }) {
    return _repository.deleteService(
      companyId: companyId,
      workshopJobId: workshopJobId,
      serviceId: serviceId,
    );
  }
}
