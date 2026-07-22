enum WorkshopServiceStatus {
  waiting,
  running,
  waitingCustomer,
  waitingParts,
  waitingSupplier,
  testing,
  completed,
  cancelled,
}

extension WorkshopServiceStatusExtension on WorkshopServiceStatus {
  String get label {
    switch (this) {
      case WorkshopServiceStatus.waiting:
        return 'Em espera';

      case WorkshopServiceStatus.running:
        return 'Em reparação';

      case WorkshopServiceStatus.waitingCustomer:
        return 'Aguarda cliente';

      case WorkshopServiceStatus.waitingParts:
        return 'Aguarda peças';

      case WorkshopServiceStatus.waitingSupplier:
        return 'Aguarda fornecedor';

      case WorkshopServiceStatus.testing:
        return 'Em testes';

      case WorkshopServiceStatus.completed:
        return 'Concluído';

      case WorkshopServiceStatus.cancelled:
        return 'Cancelado';
    }
  }
}

class WorkshopService {
  const WorkshopService({
    required this.id,
    required this.workshopJobId,
    required this.name,
    required this.description,
    required this.order,
    required this.status,
    required this.elapsedSeconds,
    required this.timerRunning,
    required this.startedAt,
    required this.finishedAt,
    required this.technicianId,
    required this.technicianName,
    required this.partsIds,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;

  final String workshopJobId;

  final String name;

  final String description;

  /// Ordem em que aparece na ficha da obra.
  final int order;

  final WorkshopServiceStatus status;

  /// Tempo total acumulado.
  final int elapsedSeconds;

  /// Existe apenas UM serviço com true em toda a aplicação.
  final bool timerRunning;

  final DateTime? startedAt;

  final DateTime? finishedAt;

  final String technicianId;

  final String technicianName;

  final List<String> partsIds;

  final String notes;

  final DateTime createdAt;

  final DateTime updatedAt;

  bool get isRunning => status == WorkshopServiceStatus.running;

  bool get isCompleted => status == WorkshopServiceStatus.completed;

  Duration get elapsed => Duration(seconds: elapsedSeconds);

  WorkshopService copyWith({
    String? id,
    String? workshopJobId,
    String? name,
    String? description,
    int? order,
    WorkshopServiceStatus? status,
    int? elapsedSeconds,
    bool? timerRunning,
    DateTime? startedAt,
    DateTime? finishedAt,
    String? technicianId,
    String? technicianName,
    List<String>? partsIds,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkshopService(
      id: id ?? this.id,
      workshopJobId: workshopJobId ?? this.workshopJobId,
      name: name ?? this.name,
      description: description ?? this.description,
      order: order ?? this.order,
      status: status ?? this.status,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      timerRunning: timerRunning ?? this.timerRunning,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
      partsIds: partsIds ?? this.partsIds,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
