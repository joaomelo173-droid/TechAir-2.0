enum InterventionType {
  maintenance,
  modernization,
  breakdown,
  inspection,
  other,
}

enum InterventionStatus {
  planned,
  inProgress,
  completed,
  cancelled,
}

class Intervention {
  const Intervention({
    required this.id,
    required this.companyId,
    required this.clientId,
    required this.compressorId,
    this.clientName = '',
    this.compressorName = '',
    required this.type,
    required this.status,
    required this.title,
    required this.description,
    required this.technicianName,
    required this.startedAt,
    required this.completedAt,
    required this.nextInterventionDate,
    required this.durationMinutes,
    required this.operatingHours,
    required this.partsUsed,
    required this.checklist,
    required this.photoUrls,
    required this.documentUrls,
    required this.pdfUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  static const Object _unset = Object();

  final String id;
  final String companyId;
  final String clientId;
  final String compressorId;

  final String clientName;
  final String compressorName;

  final InterventionType type;
  final InterventionStatus status;

  final String title;
  final String description;
  final String technicianName;

  /// Data prevista ou data de início da intervenção.
  final DateTime startedAt;

  /// Data em que a intervenção foi concluída.
  final DateTime? completedAt;

  final DateTime? nextInterventionDate;

  final int durationMinutes;
  final int? operatingHours;

  final List<String> partsUsed;
  final Map<String, bool> checklist;

  final List<String> photoUrls;
  final List<String> documentUrls;

  final String pdfUrl;

  final DateTime createdAt;
  final DateTime updatedAt;

  String get typeLabel {
    return switch (type) {
      InterventionType.maintenance => 'Manutenção',
      InterventionType.modernization => 'Modernização',
      InterventionType.breakdown => 'Avaria',
      InterventionType.inspection => 'Inspeção',
      InterventionType.other => 'Outra',
    };
  }

  String get statusLabel {
    return switch (status) {
      InterventionStatus.planned => 'Planeada',
      InterventionStatus.inProgress => 'Em curso',
      InterventionStatus.completed => 'Concluída',
      InterventionStatus.cancelled => 'Cancelada',
    };
  }

  bool get isPlanned =>
      status == InterventionStatus.planned;

  bool get isInProgress =>
      status == InterventionStatus.inProgress;

  bool get isCompleted =>
      status == InterventionStatus.completed;

  bool get isCancelled =>
      status == InterventionStatus.cancelled;

  bool get isClosed =>
      isCompleted || isCancelled;

  bool get needsCustomerSignature =>
      status == InterventionStatus.inProgress;

  Intervention copyWith({
    String? id,
    String? companyId,
    String? clientId,
    String? compressorId,
    String? clientName,
    String? compressorName,
    InterventionType? type,
    InterventionStatus? status,
    String? title,
    String? description,
    String? technicianName,
    DateTime? startedAt,
    Object? completedAt = _unset,
    Object? nextInterventionDate = _unset,
    int? durationMinutes,
    Object? operatingHours = _unset,
    List<String>? partsUsed,
    Map<String, bool>? checklist,
    List<String>? photoUrls,
    List<String>? documentUrls,
    String? pdfUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Intervention(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      clientId: clientId ?? this.clientId,
      compressorId: compressorId ?? this.compressorId,
      clientName: clientName ?? this.clientName,
      compressorName:
          compressorName ?? this.compressorName,
      type: type ?? this.type,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      technicianName:
          technicianName ?? this.technicianName,
      startedAt: startedAt ?? this.startedAt,
      completedAt: identical(completedAt, _unset)
          ? this.completedAt
          : completedAt as DateTime?,
      nextInterventionDate:
          identical(nextInterventionDate, _unset)
              ? this.nextInterventionDate
              : nextInterventionDate as DateTime?,
      durationMinutes:
          durationMinutes ?? this.durationMinutes,
      operatingHours: identical(operatingHours, _unset)
          ? this.operatingHours
          : operatingHours as int?,
      partsUsed: partsUsed ?? this.partsUsed,
      checklist: checklist ?? this.checklist,
      photoUrls: photoUrls ?? this.photoUrls,
      documentUrls:
          documentUrls ?? this.documentUrls,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}