import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/workshop_job.dart';

class WorkshopJobFirestoreMapper {
  const WorkshopJobFirestoreMapper._();

  static WorkshopJob fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};

    return WorkshopJob(
      id: document.id,
      jobNumber: _string(data['jobNumber']),
      companyId: _string(data['companyId']),
      receptionId: _string(data['receptionId']),
      clientId: _string(data['clientId']),
      compressorId: _string(data['compressorId']),
      clientName: _string(data['clientName']),
      compressorName: _string(data['compressorName']),
      status: _status(data['status']),
      reasons: _stringList(data['reasons']),
      description: _string(data['description']),
      observations: _string(data['observations']),
      createdAt: _dateTime(data['createdAt']),
      updatedAt: _dateTime(data['updatedAt']),
    );
  }

  static Map<String, dynamic> toFirestore(
    WorkshopJob workshopJob,
  ) {
    return <String, dynamic>{
      'companyId': workshopJob.companyId,
      'jobNumber': workshopJob.jobNumber,
      'receptionId': workshopJob.receptionId,
      'clientId': workshopJob.clientId,
      'compressorId': workshopJob.compressorId,
      'clientName': workshopJob.clientName,
      'compressorName': workshopJob.compressorName,
      'status': workshopJob.status.name,
      'reasons': workshopJob.reasons,
      'description': workshopJob.description,
      'observations': workshopJob.observations,
      'createdAt': Timestamp.fromDate(
        workshopJob.createdAt,
      ),
      'updatedAt': Timestamp.fromDate(
        workshopJob.updatedAt,
      ),
    };
  }

  static String _string(Object? value) {
    return value?.toString().trim() ?? '';
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

  static WorkshopJobStatus _status(Object? value) {
    final name = value?.toString() ?? '';

    for (final status in WorkshopJobStatus.values) {
      if (status.name == name) {
        return status;
      }
    }

    return WorkshopJobStatus.waiting;
  }
}
