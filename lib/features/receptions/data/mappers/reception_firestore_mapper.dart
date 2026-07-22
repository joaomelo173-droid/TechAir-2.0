import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/reception.dart';

class ReceptionFirestoreMapper {
  const ReceptionFirestoreMapper._();

  static Reception fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};

    return Reception(
      id: document.id,
      companyId: _string(data['companyId']),
      clientId: _string(data['clientId']),
      compressorId: _string(data['compressorId']),
      clientName: _string(data['clientName']),
      compressorName: _string(data['compressorName']),
      receivedAt: _dateTime(data['receivedAt']),
      receivedBy: _string(data['receivedBy']),
      reasons: _reasons(data['reasons']),
      expectedMaintenance: _string(data['expectedMaintenance']),
      faultTypes: _faultTypes(data['faultTypes']),
      reportedFault: _string(data['reportedFault']),
      expectedRepair: _string(data['expectedRepair']),
      expectedModernization: _string(data['expectedModernization']),
      observations: _string(data['observations']),
      photoUrls: _stringList(data['photoUrls']),
      status: _status(data['status']),
      workshopJobId: _string(data['workshopJobId']),
      createdAt: _dateTime(data['createdAt']),
      updatedAt: _dateTime(data['updatedAt']),
    );
  }

  static Map<String, dynamic> toFirestore(
    Reception reception,
  ) {
    return <String, dynamic>{
      'companyId': reception.companyId,
      'clientId': reception.clientId,
      'compressorId': reception.compressorId,
      'clientName': reception.clientName,
      'compressorName': reception.compressorName,
      'receivedAt': Timestamp.fromDate(reception.receivedAt),
      'receivedBy': reception.receivedBy,
      'reasons': reception.reasons.map((reason) => reason.name).toList(),
      'expectedMaintenance': reception.expectedMaintenance,
      'faultTypes':
          reception.faultTypes.map((faultType) => faultType.name).toList(),
      'reportedFault': reception.reportedFault,
      'expectedRepair': reception.expectedRepair,
      'expectedModernization': reception.expectedModernization,
      'observations': reception.observations,
      'photoUrls': reception.photoUrls,
      'status': reception.status.name,
      'workshopJobId': reception.workshopJobId,
      'createdAt': Timestamp.fromDate(reception.createdAt),
      'updatedAt': Timestamp.fromDate(reception.updatedAt),
    };
  }

  static String _string(Object? value) {
    return value?.toString().trim() ?? '';
  }

  static DateTime _dateTime(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static List<String> _stringList(Object? value) {
    if (value is! Iterable) {
      return const [];
    }

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static List<ReceptionReason> _reasons(Object? value) {
    if (value is! Iterable) {
      return const [];
    }

    return value
        .map((item) => item.toString())
        .map(_reasonFromName)
        .whereType<ReceptionReason>()
        .toList();
  }

  static ReceptionReason? _reasonFromName(String name) {
    for (final reason in ReceptionReason.values) {
      if (reason.name == name) {
        return reason;
      }
    }

    return null;
  }

  static List<CompressorFaultType> _faultTypes(
    Object? value,
  ) {
    if (value is! Iterable) {
      return const [];
    }

    return value
        .map((item) => item.toString())
        .map(_faultTypeFromName)
        .whereType<CompressorFaultType>()
        .toList();
  }

  static CompressorFaultType? _faultTypeFromName(
    String name,
  ) {
    for (final faultType in CompressorFaultType.values) {
      if (faultType.name == name) {
        return faultType;
      }
    }

    return null;
  }

  static ReceptionStatus _status(Object? value) {
    final name = value?.toString() ?? '';

    for (final status in ReceptionStatus.values) {
      if (status.name == name) {
        return status;
      }
    }

    return ReceptionStatus.received;
  }
}
