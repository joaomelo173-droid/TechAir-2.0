import '../entities/compressor.dart';

abstract interface class CompressorRepository {
  Future<List<Compressor>> getAll({
    required String companyId,
  });

  Future<List<Compressor>> getByClient({
    required String companyId,
    required String clientId,
  });

  Future<Compressor> save({
    required String companyId,
    required String clientId,
    required Compressor compressor,
  });

  Future<void> delete({
    required String companyId,
    required String clientId,
    required String compressorId,
  });
}