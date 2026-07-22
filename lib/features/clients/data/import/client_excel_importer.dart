import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/client.dart';
import '../repositories/firestore_client_repository.dart';
import 'client_excel_reader.dart';

class ClientExcelImportSummary {
  const ClientExcelImportSummary({
    required this.createdClients,
    required this.updatedClients,
    required this.processedRows,
  });

  final int createdClients;
  final int updatedClients;
  final int processedRows;
}

class ClientExcelImporter {
  ClientExcelImporter({
    required FirebaseFirestore firestore,
    required String companyId,
  })  : _firestore = firestore,
        _companyId = companyId,
        _repository = FirestoreClientRepository(firestore);

  final FirebaseFirestore _firestore;
  final FirestoreClientRepository _repository;
  final String _companyId;

  Future<ClientExcelImportSummary> import(
    ClientExcelImportResult result,
  ) async {
    final existingClients = await _repository.getAll(
      companyId: _companyId,
    );

    final existingByName = <String, Client>{
      for (final client in existingClients)
        _normalize(client.name): client,
    };

    final rowsByClient = <String, List<ClientExcelImportRow>>{};

    for (final row in result.rows) {
      rowsByClient
          .putIfAbsent(row.normalizedClientName, () => [])
          .add(row);
    }

    var createdClients = 0;
    var updatedClients = 0;

    for (final entry in rowsByClient.entries) {
      final rows = entry.value;
      final firstRow = rows.first;
      final existing = existingByName[entry.key];
      final now = DateTime.now();

      final client = Client(
        id: existing?.id ?? '',
        companyId: _companyId,
        name: firstRow.clientName.trim(),
        responsible: _firstNotEmpty(
          rows.map((row) => row.responsible),
        ),
        taxNumber: existing?.taxNumber ?? '',
        phone: existing?.phone ?? '',
        email: _firstNotEmpty(
          rows.map((row) => row.responsibleEmail),
          fallback: existing?.email ?? '',
        ),
        address: existing?.address ?? '',
        postalCode: existing?.postalCode ?? '',
        city: existing?.city ?? '',
        notes: _firstNotEmpty(
          rows.map((row) => row.notes),
          fallback: existing?.notes ?? '',
        ),
        compressorCount: rows.length,
        isActive: existing?.isActive ?? true,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      final saved = await _repository.save(
        companyId: _companyId,
        client: client,
      );

      existingByName[entry.key] = saved;

      if (existing == null) {
        createdClients++;
      } else {
        updatedClients++;
      }

      await _saveCompressors(
        clientId: saved.id,
        rows: rows,
      );
    }

    return ClientExcelImportSummary(
      createdClients: createdClients,
      updatedClients: updatedClients,
      processedRows: result.rows.length,
    );
  }

  Future<void> _saveCompressors({
    required String clientId,
    required List<ClientExcelImportRow> rows,
  }) async {
    final compressors = _firestore
        .collection('empresas')
        .doc(_companyId)
        .collection('clientes')
        .doc(clientId)
        .collection('compressores');

    final existing = await compressors.get();

    final batch = _firestore.batch();

    for (final document in existing.docs) {
      batch.delete(document.reference);
    }

    for (final row in rows) {
      final document = compressors.doc();

      batch.set(document, {
        'clientId': clientId,
        'material': row.material,
        'model': row.model,
        'notes': row.notes,
        'responsible': row.responsible,
        'responsibleEmail': row.responsibleEmail,
        'equipmentDetails': row.equipmentDetails,
        'district': row.district,
        'lastMaintenanceDate': _timestamp(row.lastMaintenanceDate),
        'nextMaintenanceDate': _timestamp(row.nextMaintenanceDate),
        'maintenanceStatus': row.maintenanceStatus,
        'lastModernizationDate':
            _timestamp(row.lastModernizationDate),
        'nextModernizationDate':
            _timestamp(row.nextModernizationDate),
        'modernizationStatus': row.modernizationStatus,
        'quoteSent': row.quoteSent,
        'alert': row.alert,
        'lastAlertDate': _timestamp(row.lastAlertDate),
        'sourceRow': row.sourceRow,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Timestamp? _timestamp(DateTime? value) {
    if (value == null) return null;
    return Timestamp.fromDate(value);
  }

  String _firstNotEmpty(
    Iterable<String> values, {
    String fallback = '',
  }) {
    for (final value in values) {
      final trimmed = value.trim();

      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    return fallback;
  }

  String _normalize(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase();
  }
}