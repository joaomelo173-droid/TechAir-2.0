import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/compressor.dart';

class CompressorFirestoreMapper {
  static Compressor fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return Compressor(
      id: doc.id,
      companyId: _string(
        data['companyId'],
        fallback: doc.reference.parent.parent?.parent.parent?.id ?? '',
      ),
      clientId: _string(
        data['clientId'],
        fallback: doc.reference.parent.parent?.id ?? '',
      ),
      brand: _string(data['brand']),
      model: _string(data['model']),
      serialNumber: _string(data['serialNumber']),
      manufactureYear: _integer(data['manufactureYear']),
      compressorType: _string(data['compressorType']),
      workingPressureBar: _decimal(data['workingPressureBar']),
      testPressureBar: _decimal(data['testPressureBar']),
      finalPressureBar: _decimal(data['finalPressureBar']),
      chargingRateLitersMinute:
          _decimal(data['chargingRateLitersMinute']),
      motorPowerKw: _decimal(data['motorPowerKw']),
      voltage: _integer(data['voltage']),
      phases: _integer(data['phases']),
      operatingHours: _integer(data['operatingHours']),
      stageCount: _integer(data['stageCount']),
      oilType: _string(data['oilType']),
      filterType: _string(data['filterType']),
      location: _string(data['location']),
      status: _string(
        data['status'],
        fallback: 'active',
      ),
      material: _string(data['material']),
      notes: _string(data['notes']),
      responsible: _string(data['responsible']),
      responsibleEmail: _string(data['responsibleEmail']),
      equipmentDetails: _string(data['equipmentDetails']),
      district: _string(data['district']),
      lastMaintenanceDate: _date(data['lastMaintenanceDate']),
      nextMaintenanceDate: _date(data['nextMaintenanceDate']),
      maintenanceStatus: _string(data['maintenanceStatus']),
      lastModernizationDate: _date(data['lastModernizationDate']),
      nextModernizationDate: _date(data['nextModernizationDate']),
      modernizationStatus: _string(data['modernizationStatus']),
      quoteSent: _boolean(data['quoteSent']),
      alert: _string(data['alert']),
      lastAlertDate: _date(data['lastAlertDate']),
      sourceRow: _integer(data['sourceRow']) ?? 0,
      createdAt: _date(data['createdAt']) ?? DateTime.now(),
      updatedAt: _date(data['updatedAt']) ?? DateTime.now(),
    );
  }

  static Map<String, dynamic> toFirestore(
    Compressor compressor,
  ) {
    return {
      'companyId': compressor.companyId,
      'clientId': compressor.clientId,
      'brand': compressor.brand,
      'model': compressor.model,
      'serialNumber': compressor.serialNumber,
      'manufactureYear': compressor.manufactureYear,
      'compressorType': compressor.compressorType,
      'workingPressureBar': compressor.workingPressureBar,
      'testPressureBar': compressor.testPressureBar,
      'finalPressureBar': compressor.finalPressureBar,
      'chargingRateLitersMinute':
          compressor.chargingRateLitersMinute,
      'motorPowerKw': compressor.motorPowerKw,
      'voltage': compressor.voltage,
      'phases': compressor.phases,
      'operatingHours': compressor.operatingHours,
      'stageCount': compressor.stageCount,
      'oilType': compressor.oilType,
      'filterType': compressor.filterType,
      'location': compressor.location,
      'status': compressor.status,
      'material': compressor.material,
      'notes': compressor.notes,
      'responsible': compressor.responsible,
      'responsibleEmail': compressor.responsibleEmail,
      'equipmentDetails': compressor.equipmentDetails,
      'district': compressor.district,
      'lastMaintenanceDate':
          _timestamp(compressor.lastMaintenanceDate),
      'nextMaintenanceDate':
          _timestamp(compressor.nextMaintenanceDate),
      'maintenanceStatus': compressor.maintenanceStatus,
      'lastModernizationDate':
          _timestamp(compressor.lastModernizationDate),
      'nextModernizationDate':
          _timestamp(compressor.nextModernizationDate),
      'modernizationStatus': compressor.modernizationStatus,
      'quoteSent': compressor.quoteSent,
      'alert': compressor.alert,
      'lastAlertDate': _timestamp(compressor.lastAlertDate),
      'sourceRow': compressor.sourceRow,
      'createdAt': Timestamp.fromDate(compressor.createdAt),
      'updatedAt': Timestamp.fromDate(compressor.updatedAt),
    };
  }

  static String _string(
    Object? value, {
    String fallback = '',
  }) {
    if (value == null) return fallback;

    final result = value.toString().trim();

    return result.isEmpty ? fallback : result;
  }

  static int? _integer(Object? value) {
    if (value == null) return null;

    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(
      value.toString().trim(),
    );
  }

  static double? _decimal(Object? value) {
    if (value == null) return null;

    if (value is num) return value.toDouble();

    return double.tryParse(
      value.toString().trim().replaceAll(',', '.'),
    );
  }

  static bool _boolean(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final normalized = value?.toString().trim().toLowerCase();

    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'sim' ||
        normalized == 'yes' ||
        normalized == 's';
  }

  static DateTime? _date(Object? value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(
      value.toString().trim(),
    );
  }

  static Timestamp? _timestamp(DateTime? value) {
    if (value == null) return null;

    return Timestamp.fromDate(value);
  }
}