import '../entities/intervention.dart';

abstract interface class InterventionRepository {
  Future<List<Intervention>> getAll({
    required String companyId,
  });

  Future<List<Intervention>> getByCompressor({
    required String companyId,
    required String clientId,
    required String compressorId,
  });

  Future<Intervention> save({
    required String companyId,
    required String clientId,
    required String compressorId,
    required Intervention intervention,
  });

  Future<void> delete({
    required String companyId,
    required String clientId,
    required String compressorId,
    required String interventionId,
  });
}