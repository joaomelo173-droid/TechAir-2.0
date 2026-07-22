enum ReceptionReason {
  maintenance,
  breakdown,
  modernization,
}

enum CompressorFaultType {
  doesNotStart,
  electricalFault,
  protectionTrips,
  lowPressure,
  noAirProduction,
  airLeak,
  oilLeak,
  excessiveOilConsumption,
  overheating,
  abnormalNoise,
  excessiveVibration,
  safetyValveActivation,
  doesNotLoad,
  doesNotUnload,
  cloggedFilter,
  cloggedOilSeparator,
  dryerFault,
  excessiveCondensate,
  other,
}

enum ReceptionStatus {
  received,
  workCreated,
  cancelled,
}

class Reception {
  const Reception({
    required this.id,
    required this.companyId,
    required this.clientId,
    required this.compressorId,
    this.clientName = '',
    this.compressorName = '',
    required this.receivedAt,
    required this.receivedBy,
    required this.reasons,
    required this.expectedMaintenance,
    required this.faultTypes,
    required this.reportedFault,
    required this.expectedRepair,
    required this.expectedModernization,
    required this.observations,
    required this.photoUrls,
    required this.status,
    required this.workshopJobId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String companyId;
  final String clientId;
  final String compressorId;

  final String clientName;
  final String compressorName;

  final DateTime receivedAt;
  final String receivedBy;

  /// Pode conter manutenção, avaria e modernização ao mesmo tempo.
  final List<ReceptionReason> reasons;

  /// Preenchido quando maintenance está selecionado.
  final String expectedMaintenance;

  /// Preenchido quando breakdown está selecionado.
  final List<CompressorFaultType> faultTypes;

  /// Descrição da avaria indicada pelo cliente.
  final String reportedFault;

  /// Trabalho inicialmente previsto para reparar a avaria.
  final String expectedRepair;

  /// Preenchido quando modernization está selecionado.
  final String expectedModernization;

  final String observations;

  /// URLs das fotografias guardadas no Firebase Storage.
  final List<String> photoUrls;

  final ReceptionStatus status;

  /// Referência da obra criada automaticamente.
  final String workshopJobId;

  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasMaintenance => reasons.contains(ReceptionReason.maintenance);

  bool get hasBreakdown => reasons.contains(ReceptionReason.breakdown);

  bool get hasModernization => reasons.contains(ReceptionReason.modernization);

  bool get hasPhotos => photoUrls.isNotEmpty;

  bool get hasWorkshopJob => workshopJobId.trim().isNotEmpty;

  bool get isCancelled => status == ReceptionStatus.cancelled;

  String get reasonsLabel {
    if (reasons.isEmpty) {
      return 'Sem motivo definido';
    }

    return reasons.map(_reasonLabel).join(', ');
  }

  String get statusLabel {
    return switch (status) {
      ReceptionStatus.received => 'Recebido',
      ReceptionStatus.workCreated => 'Obra criada',
      ReceptionStatus.cancelled => 'Cancelada',
    };
  }

  static String _reasonLabel(ReceptionReason reason) {
    return switch (reason) {
      ReceptionReason.maintenance => 'Manutenção',
      ReceptionReason.breakdown => 'Avaria',
      ReceptionReason.modernization => 'Modernização',
    };
  }

  static String faultTypeLabel(
    CompressorFaultType faultType,
  ) {
    return switch (faultType) {
      CompressorFaultType.doesNotStart => 'Não liga',
      CompressorFaultType.electricalFault => 'Falha elétrica',
      CompressorFaultType.protectionTrips => 'Disjuntor ou proteção dispara',
      CompressorFaultType.lowPressure => 'Pressão insuficiente',
      CompressorFaultType.noAirProduction => 'Não produz ar',
      CompressorFaultType.airLeak => 'Fuga de ar',
      CompressorFaultType.oilLeak => 'Fuga de óleo',
      CompressorFaultType.excessiveOilConsumption =>
        'Consumo excessivo de óleo',
      CompressorFaultType.overheating => 'Sobreaquecimento',
      CompressorFaultType.abnormalNoise => 'Ruído anormal',
      CompressorFaultType.excessiveVibration => 'Vibração excessiva',
      CompressorFaultType.safetyValveActivation =>
        'Válvula de segurança dispara',
      CompressorFaultType.doesNotLoad => 'Não entra em carga',
      CompressorFaultType.doesNotUnload => 'Não descarrega',
      CompressorFaultType.cloggedFilter => 'Filtro obstruído',
      CompressorFaultType.cloggedOilSeparator => 'Separador de óleo obstruído',
      CompressorFaultType.dryerFault => 'Problema no secador',
      CompressorFaultType.excessiveCondensate =>
        'Excesso de água ou condensados',
      CompressorFaultType.other => 'Outro',
    };
  }

  Reception copyWith({
    String? id,
    String? companyId,
    String? clientId,
    String? compressorId,
    String? clientName,
    String? compressorName,
    DateTime? receivedAt,
    String? receivedBy,
    List<ReceptionReason>? reasons,
    String? expectedMaintenance,
    List<CompressorFaultType>? faultTypes,
    String? reportedFault,
    String? expectedRepair,
    String? expectedModernization,
    String? observations,
    List<String>? photoUrls,
    ReceptionStatus? status,
    String? workshopJobId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reception(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      clientId: clientId ?? this.clientId,
      compressorId: compressorId ?? this.compressorId,
      clientName: clientName ?? this.clientName,
      compressorName: compressorName ?? this.compressorName,
      receivedAt: receivedAt ?? this.receivedAt,
      receivedBy: receivedBy ?? this.receivedBy,
      reasons: reasons ?? this.reasons,
      expectedMaintenance: expectedMaintenance ?? this.expectedMaintenance,
      faultTypes: faultTypes ?? this.faultTypes,
      reportedFault: reportedFault ?? this.reportedFault,
      expectedRepair: expectedRepair ?? this.expectedRepair,
      expectedModernization:
          expectedModernization ?? this.expectedModernization,
      observations: observations ?? this.observations,
      photoUrls: photoUrls ?? this.photoUrls,
      status: status ?? this.status,
      workshopJobId: workshopJobId ?? this.workshopJobId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
