import 'package:flutter/foundation.dart';

import '../../domain/entities/intervention.dart';
import '../../domain/repositories/intervention_repository.dart';

class InterventionsController extends ChangeNotifier {
  InterventionsController(
    this._repository, {
    required this.companyId,
    this.clientId,
    this.compressorId,
  });

  final InterventionRepository _repository;

  final String companyId;
  final String? clientId;
  final String? compressorId;

  bool _loading = false;
  bool _saving = false;
  String? _error;
  List<Intervention> _interventions = [];

  bool get loading => _loading;
  bool get saving => _saving;
  String? get error => _error;

  List<Intervention> get interventions =>
      List.unmodifiable(_interventions);

  bool get isGlobal {
    return clientId == null ||
        clientId!.trim().isEmpty ||
        compressorId == null ||
        compressorId!.trim().isEmpty;
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      if (isGlobal) {
        _interventions = await _repository.getAll(
          companyId: companyId,
        );
      } else {
        _interventions = await _repository.getByCompressor(
          companyId: companyId,
          clientId: clientId!,
          compressorId: compressorId!,
        );
      }
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> save(Intervention intervention) async {
    return _saveIntervention(intervention);
  }

  Future<bool> startIntervention(
    Intervention intervention,
  ) async {
    if (intervention.status ==
        InterventionStatus.completed) {
      _error = 'Esta intervenção já está concluída.';
      notifyListeners();
      return false;
    }

    if (intervention.status ==
        InterventionStatus.cancelled) {
      _error = 'Uma intervenção cancelada não pode ser iniciada.';
      notifyListeners();
      return false;
    }

    final updatedIntervention = intervention.copyWith(
      status: InterventionStatus.inProgress,
      updatedAt: DateTime.now(),
    );

    return _saveIntervention(updatedIntervention);
  }

  Future<bool> saveExecution({
    required Intervention intervention,
    required String description,
    required List<String> partsUsed,
    required int durationMinutes,
    required int? operatingHours,
    required DateTime? nextInterventionDate,
  }) async {
    if (intervention.status ==
        InterventionStatus.completed) {
      _error =
          'A intervenção já está concluída e não pode ser alterada.';
      notifyListeners();
      return false;
    }

    final cleanParts = partsUsed
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    final updatedIntervention = intervention.copyWith(
      status: InterventionStatus.inProgress,
      description: description.trim(),
      partsUsed: cleanParts,
      durationMinutes: durationMinutes,
      operatingHours: operatingHours,
      nextInterventionDate: nextInterventionDate,
      updatedAt: DateTime.now(),
    );

    return _saveIntervention(updatedIntervention);
  }

  Future<bool> completeIntervention({
    required Intervention intervention,
    required String description,
    required List<String> partsUsed,
    required int durationMinutes,
    required int? operatingHours,
    required DateTime? nextInterventionDate,
  }) async {
    if (description.trim().isEmpty) {
      _error = _descriptionRequiredMessage(intervention.type);
      notifyListeners();
      return false;
    }

    if (intervention.status ==
        InterventionStatus.completed) {
      _error = 'Esta intervenção já está concluída.';
      notifyListeners();
      return false;
    }

    if (intervention.status ==
        InterventionStatus.cancelled) {
      _error =
          'Uma intervenção cancelada não pode ser finalizada.';
      notifyListeners();
      return false;
    }

    final cleanParts = partsUsed
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    final now = DateTime.now();

    final completedIntervention = intervention.copyWith(
      status: InterventionStatus.completed,
      description: description.trim(),
      partsUsed: cleanParts,
      durationMinutes: durationMinutes,
      operatingHours: operatingHours,
      nextInterventionDate: nextInterventionDate,
      completedAt: now,
      updatedAt: now,
    );

    return _saveIntervention(completedIntervention);
  }

  Future<bool> cancelIntervention(
    Intervention intervention,
  ) async {
    if (intervention.status ==
        InterventionStatus.completed) {
      _error =
          'Uma intervenção concluída não pode ser cancelada.';
      notifyListeners();
      return false;
    }

    final cancelledIntervention = intervention.copyWith(
      status: InterventionStatus.cancelled,
      updatedAt: DateTime.now(),
    );

    return _saveIntervention(cancelledIntervention);
  }

  Future<bool> deleteIntervention(
    Intervention intervention,
  ) async {
    _error = null;

    final targetClientId = _targetClientId(intervention);
    final targetCompressorId =
        _targetCompressorId(intervention);

    if (targetClientId.isEmpty ||
        targetCompressorId.isEmpty) {
      _error = 'Cliente ou compressor não definido.';
      notifyListeners();
      return false;
    }

    _saving = true;
    notifyListeners();

    try {
      await _repository.delete(
        companyId: companyId,
        clientId: targetClientId,
        compressorId: targetCompressorId,
        interventionId: intervention.id,
      );

      await load();
      return true;
    } catch (error) {
      _error = error.toString();
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<bool> _saveIntervention(
    Intervention intervention,
  ) async {
    _error = null;

    final targetClientId = _targetClientId(intervention);
    final targetCompressorId =
        _targetCompressorId(intervention);

    if (targetClientId.isEmpty ||
        targetCompressorId.isEmpty) {
      _error = 'Cliente ou compressor não definido.';
      notifyListeners();
      return false;
    }

    _saving = true;
    notifyListeners();

    try {
      await _repository.save(
        companyId: companyId,
        clientId: targetClientId,
        compressorId: targetCompressorId,
        intervention: intervention,
      );

      await load();
      return true;
    } catch (error) {
      _error = error.toString();
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  String _targetClientId(Intervention intervention) {
    if (intervention.clientId.trim().isNotEmpty) {
      return intervention.clientId.trim();
    }

    return clientId?.trim() ?? '';
  }

  String _targetCompressorId(
    Intervention intervention,
  ) {
    if (intervention.compressorId.trim().isNotEmpty) {
      return intervention.compressorId.trim();
    }

    return compressorId?.trim() ?? '';
  }

  String _descriptionRequiredMessage(
    InterventionType type,
  ) {
    return switch (type) {
      InterventionType.maintenance =>
        'Indique os trabalhos de manutenção realizados.',
      InterventionType.modernization =>
        'Indique os trabalhos de modernização realizados.',
      InterventionType.breakdown =>
        'Indique a avaria e os trabalhos realizados.',
      InterventionType.inspection =>
        'Indique o resultado da inspeção.',
      InterventionType.other =>
        'Indique os trabalhos realizados.',
    };
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}