class Compressor {
  const Compressor({
    required this.id,
    required this.companyId,
    required this.clientId,
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
    required this.sourceRow,
    required this.createdAt,
    required this.updatedAt,
    this.brand = '',
    this.serialNumber = '',
    this.manufactureYear,
    this.compressorType = '',
    this.workingPressureBar,
    this.testPressureBar,
    this.finalPressureBar,
    this.chargingRateLitersMinute,
    this.motorPowerKw,
    this.voltage,
    this.phases,
    this.operatingHours,
    this.stageCount,
    this.oilType = '',
    this.filterType = '',
    this.location = '',
    this.status = 'active',
    this.clientName = '',
  });

  final String id;
  final String companyId;
  final String clientId;

  final String brand;
  final String model;
  final String serialNumber;
  final int? manufactureYear;
  final String compressorType;

  final double? workingPressureBar;
  final double? testPressureBar;
  final double? finalPressureBar;
  final double? chargingRateLitersMinute;

  final double? motorPowerKw;
  final int? voltage;
  final int? phases;
  final int? operatingHours;
  final int? stageCount;

  final String oilType;
  final String filterType;
  final String location;
  final String status;

  final String material;
  final String notes;

  final String responsible;
  final String responsibleEmail;

  final String equipmentDetails;
  final String district;
  final String clientName;

  final DateTime? lastMaintenanceDate;
  final DateTime? nextMaintenanceDate;
  final String maintenanceStatus;

  final DateTime? lastModernizationDate;
  final DateTime? nextModernizationDate;
  final String modernizationStatus;

  final bool quoteSent;
  final String alert;
  final DateTime? lastAlertDate;

  final int sourceRow;

  final DateTime createdAt;
  final DateTime updatedAt;

  String get displayName {
    final brandValue = brand.trim();
    final modelValue = model.trim();

    if (brandValue.isNotEmpty && modelValue.isNotEmpty) {
      return '$brandValue $modelValue';
    }

    if (modelValue.isNotEmpty) {
      return modelValue;
    }

    if (brandValue.isNotEmpty) {
      return brandValue;
    }

    if (material.trim().isNotEmpty) {
      return material.trim();
    }

    return 'Compressor';
  }

  String get pressureLabel {
    final values = <String>[];

    if (workingPressureBar != null) {
      values.add('${_formatNumber(workingPressureBar!)} bar trabalho');
    }

    if (finalPressureBar != null) {
      values.add('${_formatNumber(finalPressureBar!)} bar final');
    }

    if (testPressureBar != null) {
      values.add('${_formatNumber(testPressureBar!)} bar teste');
    }

    return values.join(' • ');
  }

  String get technicalSummary {
    final values = <String>[];

    if (serialNumber.trim().isNotEmpty) {
      values.add('S/N $serialNumber');
    }

    if (manufactureYear != null) {
      values.add('Ano $manufactureYear');
    }

    if (chargingRateLitersMinute != null) {
      values.add(
        '${_formatNumber(chargingRateLitersMinute!)} l/min',
      );
    }

    if (motorPowerKw != null) {
      values.add('${_formatNumber(motorPowerKw!)} kW');
    }

    return values.join(' • ');
  }

  bool get isActive {
    final value = status.trim().toLowerCase();

    return value.isEmpty ||
        value == 'active' ||
        value == 'ativo' ||
        value == 'em serviço';
  }

  bool get hasMaintenanceAlert {
    final normalized = maintenanceStatus.toLowerCase();

    return normalized.contains('atras') ||
        normalized.contains('venc') ||
        normalized.contains('urgente');
  }

  bool get hasModernizationAlert {
    final normalized = modernizationStatus.toLowerCase();

    return normalized.contains('atras') ||
        normalized.contains('venc') ||
        normalized.contains('urgente');
  }

  Compressor copyWith({
    String? id,
    String? companyId,
    String? clientId,
    String? brand,
    String? model,
    String? serialNumber,
    int? manufactureYear,
    String? compressorType,
    double? workingPressureBar,
    double? testPressureBar,
    double? finalPressureBar,
    double? chargingRateLitersMinute,
    double? motorPowerKw,
    int? voltage,
    int? phases,
    int? operatingHours,
    int? stageCount,
    String? oilType,
    String? filterType,
    String? location,
    String? status,
    String? material,
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
    int? sourceRow,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? clientName,
  }) {
    return Compressor(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      clientId: clientId ?? this.clientId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      manufactureYear: manufactureYear ?? this.manufactureYear,
      compressorType: compressorType ?? this.compressorType,
      workingPressureBar: workingPressureBar ?? this.workingPressureBar,
      testPressureBar: testPressureBar ?? this.testPressureBar,
      finalPressureBar: finalPressureBar ?? this.finalPressureBar,
      chargingRateLitersMinute:
          chargingRateLitersMinute ?? this.chargingRateLitersMinute,
      motorPowerKw: motorPowerKw ?? this.motorPowerKw,
      voltage: voltage ?? this.voltage,
      phases: phases ?? this.phases,
      operatingHours: operatingHours ?? this.operatingHours,
      stageCount: stageCount ?? this.stageCount,
      oilType: oilType ?? this.oilType,
      filterType: filterType ?? this.filterType,
      location: location ?? this.location,
      status: status ?? this.status,
      material: material ?? this.material,
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
      sourceRow: sourceRow ?? this.sourceRow,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      clientName: clientName ?? this.clientName,
    );
  }

  static String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1).replaceAll('.', ',');
  }
}
