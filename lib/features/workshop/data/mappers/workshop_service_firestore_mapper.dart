import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/workshop_service.dart';

class WorkshopServiceFirestoreMapper {
  const WorkshopServiceFirestoreMapper._();

  static WorkshopService fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};

    return WorkshopService(
      id: document.id,
      workshopJobId: _string(data['workshopJobId']),
      name: _string(data['name']),
      description: _string(data['description']),
      order: _int(data['order']),
      status: _status(data['status']),
      elapsedSeconds: _int(data['elapsedSeconds']),
      timerRunning: data['timerRunning'] == true,
      startedAt: _nullableDateTime(data['startedAt']),
      finishedAt: _nullableDateTime(data['finishedAt']),
      technicianId: _string(data['technicianId']),
      technicianName: _string(data['technicianName']),
      partsIds: _stringList(data['partsIds']),
      notes: _string(data['notes']),
      createdAt: _dateTime(data['createdAt']),
      updatedAt: _dateTime(data['updatedAt']),
    );
  }

  static Map<String, dynamic> toFirestore(
    WorkshopService service,
  ) {
    return {
      'workshopJobId': service.workshopJobId,
      'name': service.name,
      'description': service.description,
      'order': service.order,
      'status': service.status.name,
      'elapsedSeconds': service.elapsedSeconds,
      'timerRunning': service.timerRunning,
      'startedAt': service.startedAt == null
          ? null
          : Timestamp.fromDate(service.startedAt!),
      'finishedAt': service.finishedAt == null
          ? null
          : Timestamp.fromDate(service.finishedAt!),
      'technicianId': service.technicianId,
      'technicianName': service.technicianName,
      'partsIds': service.partsIds,
      'notes': service.notes,
      'createdAt': Timestamp.fromDate(service.createdAt),
      'updatedAt': Timestamp.fromDate(service.updatedAt),
    };
  }

  static String _string(Object? value) => value?.toString().trim() ?? '';

  static int _int(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  static List<String> _stringList(Object? value) {
    if (value is! Iterable) {
      return const [];
    }

    return value
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static DateTime _dateTime(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static DateTime? _nullableDateTime(Object? value) {
    if (value == null) {
      return null;
    }

    return _dateTime(value);
  }

  static WorkshopServiceStatus _status(Object? value) {
    final name = value?.toString() ?? '';

    for (final status in WorkshopServiceStatus.values) {
      if (status.name == name) {
        return status;
      }
    }

    return WorkshopServiceStatus.waiting;
  }
}
