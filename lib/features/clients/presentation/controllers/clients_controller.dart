import 'package:flutter/foundation.dart';

import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';

class ClientsController extends ChangeNotifier {
  ClientsController({
    required ClientRepository repository,
    required this.companyId,
  }) : _repository = repository;

  final ClientRepository _repository;
  final String companyId;

  bool _loading = false;
  String _search = '';
  String? _error;

  List<Client> _clients = [];

  bool get loading => _loading;
  String? get error => _error;

  List<Client> get clients {
    if (_search.isEmpty) return _clients;

    final value = _search.toLowerCase();

    return _clients.where((client) {
      return client.name.toLowerCase().contains(value) ||
          client.responsible.toLowerCase().contains(value) ||
          client.city.toLowerCase().contains(value) ||
          client.phone.toLowerCase().contains(value);
    }).toList();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _clients = await _repository.getAll(
        companyId: companyId,
      );
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  void search(String value) {
    _search = value.trim();
    notifyListeners();
  }

  Future<bool> save(Client client) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.save(
        companyId: companyId,
        client: client,
      );

      await load();
      return true;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(Client client) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.delete(
        companyId: companyId,
        clientId: client.id,
      );

      await load();
      return true;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
