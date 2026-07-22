import '../entities/client.dart';

abstract interface class ClientRepository {
  Future<List<Client>> getAll({
    required String companyId,
  });

  Future<Client> save({
    required String companyId,
    required Client client,
  });

  Future<void> delete({
    required String companyId,
    required String clientId,
  });
}
