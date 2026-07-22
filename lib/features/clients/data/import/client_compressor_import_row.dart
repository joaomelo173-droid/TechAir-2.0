class ClientCompressorImportRow {
  const ClientCompressorImportRow({
    required this.sourceRow,
    required this.clientName,
    required this.material,
    required this.model,
    required this.notes,
    required this.responsible,
    required this.responsibleEmail,
    required this.equipmentDetails,
    required this.district,
    required this.lastMaintenanceDate,
    required this.nextMaintenanceDate,
    required this.maintenanceStatus,
    required this.lastModernizationDate,
    required this.nextModernizationDate,
    required this.modernizationStatus,
    required this.quoteSent,
    required this.alert,
    required this.lastAlertDate,
  });

  final int sourceRow;

  final String clientName;
  final String material;
  final String model;
  final String notes;

  final String responsible;
  final String responsibleEmail;

  final String equipmentDetails;
  final String district;

  final DateTime? lastMaintenanceDate;
  final DateTime? nextMaintenanceDate;
  final String maintenanceStatus;

  final DateTime? lastModernizationDate;
  final DateTime? nextModernizationDate;
  final String modernizationStatus;

  final bool quoteSent;
  final String alert;
  final DateTime? lastAlertDate;

  bool get isValid => clientName.trim().isNotEmpty;

  String get normalizedClientName {
    return clientName.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }

  ClientCompressorImportRow copyWith({
    int? sourceRow,
    String? clientName,
    String? material,
    String? model,
    String? notes,
    String? responsible,
    String? responsibleEmail,
    String? equipmentDetails,
    String? district,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDate,
    String? maintenanceStatus,
    DateTime? lastModernizationDate,
    DateTime? nextModernizationDate,
    String? modernizationStatus,
    bool? quoteSent,
    String? alert,
    DateTime? lastAlertDate,
  }) {
    return ClientCompressorImportRow(
      sourceRow: sourceRow ?? this.sourceRow,
      clientName: clientName ?? this.clientName,
      material: material ?? this.material,
      model: model ?? this.model,
      notes: notes ?? this.notes,
      responsible: responsible ?? this.responsible,
      responsibleEmail: responsibleEmail ?? this.responsibleEmail,
      equipmentDetails: equipmentDetails ?? this.equipmentDetails,
      district: district ?? this.district,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
      nextMaintenanceDate: nextMaintenanceDate ?? this.nextMaintenanceDate,
      maintenanceStatus: maintenanceStatus ?? this.maintenanceStatus,
      lastModernizationDate:
          lastModernizationDate ?? this.lastModernizationDate,
      nextModernizationDate:
          nextModernizationDate ?? this.nextModernizationDate,
      modernizationStatus: modernizationStatus ?? this.modernizationStatus,
      quoteSent: quoteSent ?? this.quoteSent,
      alert: alert ?? this.alert,
      lastAlertDate: lastAlertDate ?? this.lastAlertDate,
    );
  }
}
