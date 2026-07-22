import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';

class InMemoryClientRepository implements ClientRepository {
  InMemoryClientRepository() : _clients = _seedClients();

  final List<Client> _clients;

  @override
  Future<List<Client>> getAll({
    required String companyId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));

    final list = _clients
        .where((client) => client.companyId == companyId)
        .toList();

    list.sort(
      (a, b) => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
    );

    return list;
  }

  @override
  Future<Client> save({
    required String companyId,
    required Client client,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 140));

    final entity = client.copyWith(companyId: companyId);

    final index = _clients.indexWhere((item) => item.id == entity.id);

    if (index == -1) {
      _clients.add(entity);
    } else {
      _clients[index] = entity;
    }

    return entity;
  }

  @override
  Future<void> delete({
    required String companyId,
    required String clientId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));

    _clients.removeWhere(
      (client) =>
          client.companyId == companyId &&
          client.id == clientId,
    );
  }

  static List<Client> _seedClients() {
    final now = DateTime.now();

    return [
      Client(
        id: 'cli-001',
        companyId: 'extincendios',
        name: 'Extincêndios — Equipamentos de Proteção',
        responsible: '',
        taxNumber: '500000001',
        phone: '261 325 968',
        email: 'geral@extincendios.pt',
        address: 'Estrada Nacional 8, Nº54',
        postalCode: '2565-646',
        city: 'Ramalhal',
        notes: '',
        compressorCount: 0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Client(
        id: 'cli-002',
        companyId: 'extincendios',
        name: 'Bombeiros Voluntários do Oeste',
        responsible: '',
        taxNumber: '500000002',
        phone: '261 000 221',
        email: 'comando@bvoeste.pt',
        address: 'Rua do Quartel, 18',
        postalCode: '2560-000',
        city: 'Torres Vedras',
        notes: '',
        compressorCount: 0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Client(
        id: 'cli-003',
        companyId: 'extincendios',
        name: 'Proteção Civil Municipal',
        responsible: '',
        taxNumber: '500000003',
        phone: '262 100 100',
        email: 'operacoes@pcm.pt',
        address: 'Avenida Central, 40',
        postalCode: '2500-100',
        city: 'Caldas da Rainha',
        notes: '',
        compressorCount: 0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}