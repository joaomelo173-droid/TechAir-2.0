import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/reception.dart';

class FirestoreReceptionMapper {
  static Reception fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return Reception(
      id: doc.id,
      companyId: (data['companyId'] ?? '').toString(),
      clientId: (data['clientId'] ?? '').toString(),
      compressorId: (data['compressorId'] ?? '').toString(),
      clientName: (data['clientName'] ?? '').toString(),
      compressorName:
          (data['compressorName'] ?? '').toString(),

      receivedAt:
          _dateTimeFromFirestore(data['receivedAt']) ??
              DateTime.now(),

      receivedBy: (data['receivedBy'] ?? '').toString(),

      reasons: _reasonsFromFirestore(
        data['reasons'],
      ),

      expectedMaintenance:
          (data['expectedMaintenance'] ?? '').toString(),

      faultTypes: _faultTypesFromFirestore(
        data['faultTypes'],
      ),

      reportedFault:
          (data['reportedFault'] ?? '').toString(),

      expectedRepair:
          (data['expectedRepair'] ?? '').toString(),

      expectedModernization:
          (data['expectedModernization'] ?? '').toString(),

      observations:
          (data['observations'] ?? '').toString(),

      photoUrls:
          _stringListFromFirestore(data['photoUrls']),

      status: _statusFromFirestore(
        data['status'],
      ),

      workshopJobId:
          (data['workshopJobId'] ?? '').toString(),

      createdAt:
          _dateTimeFromFirestore(data['createdAt']) ??
              DateTime.now(),

      updatedAt:
          _dateTimeFromFirestore(data['updatedAt']) ??
              DateTime.now(),
    );
  }

  static Map<String, dynamic> toFirestore(
    Reception reception,
  ) {
    return {
      'companyId': reception.companyId,
      'clientId': reception.clientId,
      'compressorId': reception.compressorId,
      'clientName': reception.clientName,
      'compressorName': reception.compressorName,

      'receivedAt':
          Timestamp.fromDate(reception.receivedAt),

      'receivedBy': reception.receivedBy,

      'reasons': reception.reasons
          .map((reason) => reason.name)
          .toList(),

      'expectedMaintenance':
          reception.expectedMaintenance,

      'faultTypes': reception.faultTypes
          .map((faultType) => faultType.name)
          .toList(),

      'reportedFault': reception.reportedFault,
      'expectedRepair': reception.expectedRepair,
      'expectedModernization':
          reception.expectedModernization,

      'observations': reception.observations,

      'photoUrls': reception.photoUrls,

      'status': reception.status.name,

      'workshopJobId': reception.workshopJobId,

      'createdAt':
          Timestamp.fromDate(reception.createdAt),

      'updatedAt':
          Timestamp.fromDate(reception.updatedAt),
    };
  }

  static DateTime? _dateTimeFromFirestore(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  static List<ReceptionReason> _reasonsFromFirestore(
    dynamic value,
  ) {
    if (value is! Iterable) {
      return const [];
    }

    final reasons = <ReceptionReason>[];

    for (final item in value) {
      final name = item.toString();

      final reason = ReceptionReason.values.cast<
          ReceptionReason?>().firstWhere(
        (value) => value?.name == name,
        orElse: () => null,
      );

      if (reason != null && !reasons.contains(reason)) {
        reasons.add(reason);
      }
    }

    return reasons;
  }

  static List<CompressorFaultType>
      _faultTypesFromFirestore(
    dynamic value,
  ) {
    if (value is! Iterable) {
      return const [];
    }

    final faultTypes = <CompressorFaultType>[];

    for (final item in value) {
      final name = item.toString();

      final faultType = CompressorFaultType.values.cast<
          CompressorFaultType?>().firstWhere(
        (value) => value?.name == name,
        orElse: () => null,
      );

      if (faultType != null &&
          !faultTypes.contains(faultType)) {
        faultTypes.add(faultType);
      }
    }

    return faultTypes;
  }

  static ReceptionStatus _statusFromFirestore(
    dynamic value,
  ) {
    final name = value?.toString();

    return ReceptionStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => ReceptionStatus.received,
    );
  }

  static List<String> _stringListFromFirestore(
    dynamic value,
  ) {
    if (value is! Iterable) {
      return const [];
    }

    return value
        .map((item) => item.toString())
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }
}