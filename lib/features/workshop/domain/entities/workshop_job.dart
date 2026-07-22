enum WorkshopJobStatus {
  waiting,
  diagnosis,
  waitingParts,
  repair,
  testing,
  completed,
  delivered,
  cancelled,
}

class WorkshopJob {
  const WorkshopJob({
    required this.id,
    required this.jobNumber,
    required this.companyId,
    required this.receptionId,
    required this.clientId,
    required this.compressorId,
    required this.clientName,
    required this.compressorName,
    required this.status,
    required this.reasons,
    required this.description,
    required this.observations,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String jobNumber;
  final String companyId;

  /// Receção que originou automaticamente a obra.
  final String receptionId;

  final String clientId;
  final String compressorId;
  final String clientName;
  final String compressorName;

  final WorkshopJobStatus status;

  /// Motivos copiados da receção.
  final List<String> reasons;

  /// Trabalho inicialmente previsto.
  final String description;

  final String observations;

  final DateTime createdAt;
  final DateTime updatedAt;

  String get statusLabel {
    return switch (status) {
      WorkshopJobStatus.waiting => 'Em espera',
      WorkshopJobStatus.diagnosis => 'Em diagnóstico',
      WorkshopJobStatus.waitingParts => 'A aguardar peças',
      WorkshopJobStatus.repair => 'Em reparação',
      WorkshopJobStatus.testing => 'Em teste',
      WorkshopJobStatus.completed => 'Concluída',
      WorkshopJobStatus.delivered => 'Entregue',
      WorkshopJobStatus.cancelled => 'Cancelada',
    };
  }

  bool get isFinished {
    return status == WorkshopJobStatus.completed ||
        status == WorkshopJobStatus.delivered ||
        status == WorkshopJobStatus.cancelled;
  }

  WorkshopJob copyWith({
    String? id,
    String? jobNumber,
    String? companyId,
    String? receptionId,
    String? clientId,
    String? compressorId,
    String? clientName,
    String? compressorName,
    WorkshopJobStatus? status,
    List<String>? reasons,
    String? description,
    String? observations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkshopJob(
      id: id ?? this.id,
      jobNumber: jobNumber ?? this.jobNumber,
      companyId: companyId ?? this.companyId,
      receptionId: receptionId ?? this.receptionId,
      clientId: clientId ?? this.clientId,
      compressorId: compressorId ?? this.compressorId,
      clientName: clientName ?? this.clientName,
      compressorName: compressorName ?? this.compressorName,
      status: status ?? this.status,
      reasons: reasons ?? this.reasons,
      description: description ?? this.description,
      observations: observations ?? this.observations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
