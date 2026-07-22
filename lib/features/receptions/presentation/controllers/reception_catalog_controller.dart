import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ReceptionClientItem {
  const ReceptionClientItem({
    required this.id,
    required this.name,
    required this.subtitle,
  });

  final String id;
  final String name;
  final String subtitle;
}

class ReceptionCompressorItem {
  const ReceptionCompressorItem({
    required this.id,
    required this.clientId,
    required this.name,
    required this.subtitle,
  });

  final String id;
  final String clientId;
  final String name;
  final String subtitle;
}

class ReceptionCatalogController extends ChangeNotifier {
  ReceptionCatalogController(
    this._firestore, {
    required this.companyId,
  });

  final FirebaseFirestore _firestore;
  final String companyId;

  final List<ReceptionClientItem> _clients = [];
  final List<ReceptionCompressorItem> _compressors = [];

  List<ReceptionClientItem> get clients =>
      List.unmodifiable(_clients);

  List<ReceptionCompressorItem> get compressors =>
      List.unmodifiable(_compressors);

  bool loadingClients = false;
  bool loadingCompressors = false;

  String? error;

  Future<void> loadClients() async {
    if (loadingClients) {
      return;
    }

    loadingClients = true;
    error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('empresas')
          .doc(companyId)
          .collection('clientes')
          .get();

      final loadedClients = snapshot.docs.map((document) {
        final data = document.data();

        final name = _firstNonEmpty([
          data['name'],
          data['nome'],
          data['clientName'],
          data['cliente'],
        ]);

        final district = _firstNonEmpty([
          data['district'],
          data['distrito'],
          data['location'],
          data['localizacao'],
          data['morada'],
          data['address'],
        ]);

        final responsible = _firstNonEmpty([
          data['responsible'],
          data['responsavel'],
          data['contactPerson'],
          data['contacto'],
        ]);

        final subtitleParts = <String>[
          if (district.isNotEmpty) district,
          if (responsible.isNotEmpty) responsible,
        ];

        return ReceptionClientItem(
          id: document.id,
          name: name.isEmpty
              ? 'Cliente sem nome'
              : name,
          subtitle: subtitleParts.join(' • '),
        );
      }).toList();

      loadedClients.sort(
        (a, b) => a.name.toLowerCase().compareTo(
              b.name.toLowerCase(),
            ),
      );

      _clients
        ..clear()
        ..addAll(loadedClients);
    } on FirebaseException catch (exception) {
      error = exception.message ??
          'Não foi possível carregar os clientes.';
    } catch (exception) {
      error =
          'Não foi possível carregar os clientes: $exception';
    } finally {
      loadingClients = false;
      notifyListeners();
    }
  }

  Future<void> loadCompressors(
    String clientId,
  ) async {
    if (clientId.trim().isEmpty) {
      clearCompressors();
      return;
    }

    loadingCompressors = true;
    error = null;

    _compressors.clear();
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('empresas')
          .doc(companyId)
          .collection('clientes')
          .doc(clientId)
          .collection('compressores')
          .get();

      final loadedCompressors =
          snapshot.docs.map((document) {
        final data = document.data();

        final brand = _firstNonEmpty([
          data['brand'],
          data['marca'],
        ]);

        final model = _firstNonEmpty([
          data['model'],
          data['modelo'],
        ]);

        final serialNumber = _firstNonEmpty([
          data['serialNumber'],
          data['numeroSerie'],
          data['numero_serie'],
          data['serial'],
        ]);

        final material = _firstNonEmpty([
          data['material'],
          data['equipmentNumber'],
          data['numeroEquipamento'],
        ]);

        final storedDisplayName = _firstNonEmpty([
          data['displayName'],
          data['name'],
          data['nome'],
        ]);

        final generatedName = [
          brand,
          model,
        ].where((value) => value.isNotEmpty).join(' ');

        final name = storedDisplayName.isNotEmpty
            ? storedDisplayName
            : generatedName.isNotEmpty
                ? generatedName
                : 'Compressor sem identificação';

        final subtitleParts = <String>[
          if (serialNumber.isNotEmpty)
            'N.º série: $serialNumber',
          if (material.isNotEmpty)
            'Material: $material',
        ];

        return ReceptionCompressorItem(
          id: document.id,
          clientId: clientId,
          name: name,
          subtitle: subtitleParts.join(' • '),
        );
      }).toList();

      loadedCompressors.sort(
        (a, b) => a.name.toLowerCase().compareTo(
              b.name.toLowerCase(),
            ),
      );

      _compressors
        ..clear()
        ..addAll(loadedCompressors);
    } on FirebaseException catch (exception) {
      error = exception.message ??
          'Não foi possível carregar os compressores.';
    } catch (exception) {
      error =
          'Não foi possível carregar os compressores: $exception';
    } finally {
      loadingCompressors = false;
      notifyListeners();
    }
  }

  void clearCompressors() {
    if (_compressors.isEmpty &&
        !loadingCompressors) {
      return;
    }

    _compressors.clear();
    loadingCompressors = false;
    notifyListeners();
  }

  void clearError() {
    if (error == null) {
      return;
    }

    error = null;
    notifyListeners();
  }

  String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      if (value == null) {
        continue;
      }

      final text = value.toString().trim();

      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }
}