import 'package:flutter/foundation.dart';

import '../../domain/entities/compressor.dart';
import '../../domain/repositories/compressor_repository.dart';

class CompressorsController extends ChangeNotifier {
  CompressorsController(
    this._repository, {
    required this.companyId,
    this.clientId,
  });

  final CompressorRepository _repository;

  final String companyId;
  final String? clientId;

  bool _loading = false;
  String? _error;

  List<Compressor> _compressors = [];

  bool get loading => _loading;
  String? get error => _error;
  bool get isGlobal => clientId == null || clientId!.trim().isEmpty;

  List<Compressor> get compressors => List.unmodifiable(_compressors);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      if (isGlobal) {
        _compressors = await _repository.getAll(
          companyId: companyId,
        );
      } else {
        _compressors = await _repository.getByClient(
          companyId: companyId,
          clientId: clientId!,
        );
      }
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> save(Compressor compressor) async {
    final resolvedClientId =
        compressor.clientId.trim().isNotEmpty ? compressor.clientId : clientId;

    if (resolvedClientId == null || resolvedClientId.trim().isEmpty) {
      _error = 'O compressor tem de estar associado a um cliente.';
      notifyListeners();
      return false;
    }

    _error = null;

    try {
      await _repository.save(
        companyId: companyId,
        clientId: resolvedClientId,
        compressor: compressor,
      );

      await load();
      return true;
    } catch (error) {
      _error = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> delete(String compressorId) async {
    if (clientId == null || clientId!.trim().isEmpty) {
      throw StateError(
        'É necessário indicar o cliente para eliminar o compressor.',
      );
    }

    await _repository.delete(
      companyId: companyId,
      clientId: clientId!,
      compressorId: compressorId,
    );

    await load();
  }

  Future<bool> deleteCompressor(Compressor compressor) async {
    if (compressor.clientId.trim().isEmpty) {
      _error = 'Não foi possível identificar o cliente deste compressor.';
      notifyListeners();
      return false;
    }

    _error = null;

    try {
      await _repository.delete(
        companyId: companyId,
        clientId: compressor.clientId,
        compressorId: compressor.id,
      );

      await load();
      return true;
    } catch (error) {
      _error = error.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
