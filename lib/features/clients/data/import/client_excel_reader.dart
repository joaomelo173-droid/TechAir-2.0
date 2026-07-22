import 'dart:typed_data';

import 'package:excel/excel.dart';

class ClientExcelImportRow {
  const ClientExcelImportRow({
    required this.sourceRow,
    required this.clientName,
    required this.material,
    required this.model,
    required this.notes,
    required this.responsible,
    required this.responsibleEmail,
    required this.equipmentDetails,
    required this.district,
    required this.lastMaintenanceDate,
    required this.nextMaintenanceDate,
    required this.maintenanceStatus,
    required this.lastModernizationDate,
    required this.nextModernizationDate,
    required this.modernizationStatus,
    required this.quoteSent,
    required this.alert,
    required this.lastAlertDate,
  });

  final int sourceRow;
  final String clientName;
  final String material;
  final String model;
  final String notes;
  final String responsible;
  final String responsibleEmail;
  final String equipmentDetails;
  final String district;
  final DateTime? lastMaintenanceDate;
  final DateTime? nextMaintenanceDate;
  final String maintenanceStatus;
  final DateTime? lastModernizationDate;
  final DateTime? nextModernizationDate;
  final String modernizationStatus;
  final bool quoteSent;
  final String alert;
  final DateTime? lastAlertDate;

  String get normalizedClientName {
    return clientName
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase();
  }
}

class ClientExcelImportResult {
  const ClientExcelImportResult({
    required this.fileName,
    required this.rows,
    required this.skippedRows,
  });

  final String fileName;
  final List<ClientExcelImportRow> rows;
  final int skippedRows;

  int get compressorCount => rows.length;

  int get clientCount {
    return rows.map((row) => row.normalizedClientName).toSet().length;
  }
}

class ClientExcelReader {
  const ClientExcelReader();

  ClientExcelImportResult read({
    required String fileName,
    required Uint8List bytes,
  }) {
    final workbook = Excel.decodeBytes(bytes);

    final sheet = workbook.tables['Compressores'];

    if (sheet == null) {
      throw const FormatException(
        'A folha "Compressores" não foi encontrada no ficheiro.',
      );
    }

    final rows = <ClientExcelImportRow>[];
    var skippedRows = 0;

    for (var index = 9; index < sheet.rows.length; index++) {
      final source = sheet.rows[index];

      final clientName = _textAt(source, 0);

      if (clientName.isEmpty) {
        skippedRows++;
        continue;
      }

      final responsibleData = _splitResponsible(
        _textAt(source, 4),
      );

      rows.add(
        ClientExcelImportRow(
          sourceRow: index + 1,
          clientName: clientName,
          material: _textAt(source, 1),
          model: _textAt(source, 2),
          notes: _textAt(source, 3),
          responsible: responsibleData.name,
          responsibleEmail: responsibleData.email,
          equipmentDetails: _textAt(source, 5),
          district: _textAt(source, 6),
          lastMaintenanceDate: _dateAt(source, 7),
          nextMaintenanceDate: _dateAt(source, 8),
          maintenanceStatus: _textAt(source, 9),
          lastModernizationDate: _dateAt(source, 10),
          nextModernizationDate: _dateAt(source, 11),
          modernizationStatus: _textAt(source, 12),
          quoteSent: _booleanAt(source, 13),
          alert: _textAt(source, 14),
          lastAlertDate: _dateAt(source, 15),
        ),
      );
    }

    if (rows.isEmpty) {
      throw const FormatException(
        'O ficheiro não contém linhas válidas para importar.',
      );
    }

    return ClientExcelImportResult(
      fileName: fileName,
      rows: rows,
      skippedRows: skippedRows,
    );
  }

  String _textAt(List<Data?> row, int index) {
    if (index >= row.length) return '';

    final value = row[index]?.value;

    if (value == null) return '';

    return value
        .toString()
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .trim();
  }

  DateTime? _dateAt(List<Data?> row, int index) {
    if (index >= row.length) return null;

    final value = row[index]?.value;

    if (value == null) return null;

    final raw = value.toString().trim();

    if (raw.isEmpty) return null;

    final directDate = DateTime.tryParse(raw);

    if (directDate != null) {
      return DateTime(
        directDate.year,
        directDate.month,
        directDate.day,
        directDate.hour,
        directDate.minute,
        directDate.second,
      );
    }

    final serial = double.tryParse(
      raw.replaceAll(',', '.'),
    );

    if (serial == null || serial <= 0) {
      return null;
    }

    final days = serial.floor();
    final fraction = serial - days;

    final date = DateTime(1899, 12, 30).add(
      Duration(
        days: days,
        milliseconds: (fraction * Duration.millisecondsPerDay).round(),
      ),
    );

    return date;
  }

  bool _booleanAt(List<Data?> row, int index) {
    final value = _textAt(row, index).toLowerCase();

    return value == 'sim' ||
        value == 's' ||
        value == 'yes' ||
        value == 'true' ||
        value == '1' ||
        value == 'x';
  }

  _ResponsibleData _splitResponsible(String value) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      return const _ResponsibleData(
        name: '',
        email: '',
      );
    }

    final emailMatch = RegExp(
      r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}',
      caseSensitive: false,
    ).firstMatch(normalized);

    if (emailMatch == null) {
      return _ResponsibleData(
        name: normalized,
        email: '',
      );
    }

    final email = emailMatch.group(0) ?? '';

    final name = normalized
        .replaceFirst(email, '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return _ResponsibleData(
      name: name,
      email: email,
    );
  }
}

class _ResponsibleData {
  const _ResponsibleData({
    required this.name,
    required this.email,
  });

  final String name;
  final String email;
}