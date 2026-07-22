import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/intervention.dart';

class FirestoreInterventionMapper {
  static Intervention fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return Intervention(
      id: doc.id,
      companyId: (data['companyId'] ?? '').toString(),
      clientId: (data['clientId'] ?? '').toString(),
      compressorId: (data['compressorId'] ?? '').toString(),
      clientName: (data['clientName'] ?? '').toString(),
      compressorName: (data['compressorName'] ?? '').toString(),
      type: InterventionType.values.firstWhere(
        (value) => value.name == data['type'],
        orElse: () => InterventionType.maintenance,
      ),
      status: _statusFromFirestore(data['status']),
      title: (data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      technicianName: (data['technicianName'] ?? '').toString(),
      startedAt: _dateTimeFromFirestore(data['startedAt']) ?? DateTime.now(),
      completedAt: _dateTimeFromFirestore(data['completedAt']),
      nextInterventionDate: _dateTimeFromFirestore(
        data['nextInterventionDate'],
      ),
      durationMinutes: _intFromFirestore(data['durationMinutes']) ?? 0,
      operatingHours: _intFromFirestore(data['operatingHours']),
      partsUsed: _stringListFromFirestore(data['partsUsed']),
      checklist: _boolMapFromFirestore(data['checklist']),
      photoUrls: _stringListFromFirestore(data['photoUrls']),
      documentUrls: _stringListFromFirestore(data['documentUrls']),
      pdfUrl: (data['pdfUrl'] ?? '').toString(),
      createdAt: _dateTimeFromFirestore(data['createdAt']) ?? DateTime.now(),
      updatedAt: _dateTimeFromFirestore(data['updatedAt']) ?? DateTime.now(),
    );
  }

  static Map<String, dynamic> toFirestore(
    Intervention intervention,
  ) {
    return {
      'companyId': intervention.companyId,
      'clientId': intervention.clientId,
      'compressorId': intervention.compressorId,
      'clientName': intervention.clientName,
      'compressorName': intervention.compressorName,
      'type': intervention.type.name,
      'status': intervention.status.name,
      'title': intervention.title,
      'description': intervention.description,
      'technicianName': intervention.technicianName,
      'startedAt': Timestamp.fromDate(intervention.startedAt),
      'completedAt': intervention.completedAt == null
          ? null
          : Timestamp.fromDate(
              intervention.completedAt!,
            ),
      'nextInterventionDate': intervention.nextInterventionDate == null
          ? null
          : Timestamp.fromDate(
              intervention.nextInterventionDate!,
            ),
      'durationMinutes': intervention.durationMinutes,
      'operatingHours': intervention.operatingHours,
      'partsUsed': intervention.partsUsed,
      'checklist': intervention.checklist,
      'photoUrls': intervention.photoUrls,
      'documentUrls': intervention.documentUrls,
      'pdfUrl': intervention.pdfUrl,
      'createdAt': Timestamp.fromDate(intervention.createdAt),
      'updatedAt': Timestamp.fromDate(intervention.updatedAt),
    };
  }

  static InterventionStatus _statusFromFirestore(
    dynamic value,
  ) {
    final statusName = value?.toString();

    return switch (statusName) {
      'planned' => InterventionStatus.planned,
      'inProgress' => InterventionStatus.inProgress,
      'completed' => InterventionStatus.completed,
      'cancelled' => InterventionStatus.cancelled,

      // Compatibilidade temporária com documentos criados
      // enquanto os estados de oficina estavam em Intervention.
      'waitingToStart' => InterventionStatus.planned,
      'waitingBudgetApproval' => InterventionStatus.inProgress,
      'waitingParts' => InterventionStatus.inProgress,
      'waitingCollection' => InterventionStatus.completed,
      'delivered' => InterventionStatus.completed,
      _ => InterventionStatus.planned,
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

  static int? _intFromFirestore(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
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

  static Map<String, bool> _boolMapFromFirestore(
    dynamic value,
  ) {
    if (value is! Map) {
      return const {};
    }

    return value.map(
      (key, mapValue) => MapEntry(
        key.toString(),
        mapValue == true,
      ),
    );
  }
}
