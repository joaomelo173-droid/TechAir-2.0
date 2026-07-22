import 'package:flutter/material.dart';

import '../../domain/entities/compressor.dart';

class NewCompressorDialog extends StatefulWidget {
  const NewCompressorDialog({
    super.key,
    required this.companyId,
    required this.clientId,
    required this.clientName,
  });

  final String companyId;
  final String clientId;
  final String clientName;

  @override
  State<NewCompressorDialog> createState() => _NewCompressorDialogState();
}

class _NewCompressorDialogState extends State<NewCompressorDialog> {
  final _formKey = GlobalKey<FormState>();

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _yearController = TextEditingController();
  final _typeController = TextEditingController();

  final _materialController = TextEditingController();
  final _districtController = TextEditingController();
  final _locationController = TextEditingController();

  final _responsibleController = TextEditingController();
  final _responsibleEmailController = TextEditingController();

  final _workingPressureController = TextEditingController();
  final _finalPressureController = TextEditingController();
  final _chargingRateController = TextEditingController();
  final _motorPowerController = TextEditingController();

  final _equipmentDetailsController = TextEditingController();
  final _notesController = TextEditingController();

  String _status = 'active';

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _serialNumberController.dispose();
    _yearController.dispose();
    _typeController.dispose();
    _materialController.dispose();
    _districtController.dispose();
    _locationController.dispose();
    _responsibleController.dispose();
    _responsibleEmailController.dispose();
    _workingPressureController.dispose();
    _finalPressureController.dispose();
    _chargingRateController.dispose();
    _motorPowerController.dispose();
    _equipmentDetailsController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  double? _parseDouble(String value) {
    final normalized = value.trim().replaceAll(',', '.');

    if (normalized.isEmpty) {
      return null;
    }

    return double.tryParse(normalized);
  }

  int? _parseInt(String value) {
    if (value.trim().isEmpty) {
      return null;
    }

    return int.tryParse(value.trim());
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();

    final compressor = Compressor(
      id: '',
      companyId: widget.companyId,
      clientId: widget.clientId,
      clientName: widget.clientName,
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      serialNumber: _serialNumberController.text.trim(),
      manufactureYear: _parseInt(_yearController.text),
      compressorType: _typeController.text.trim(),
      workingPressureBar: _parseDouble(_workingPressureController.text),
      testPressureBar: null,
      finalPressureBar: _parseDouble(_finalPressureController.text),
      chargingRateLitersMinute: _parseDouble(_chargingRateController.text),
      motorPowerKw: _parseDouble(_motorPowerController.text),
      voltage: null,
      phases: null,
      operatingHours: null,
      stageCount: null,
      oilType: '',
      filterType: '',
      location: _locationController.text.trim(),
      status: _status,
      material: _materialController.text.trim(),
      notes: _notesController.text.trim(),
      responsible: _responsibleController.text.trim(),
      responsibleEmail: _responsibleEmailController.text.trim(),
      equipmentDetails: _equipmentDetailsController.text.trim(),
      district: _districtController.text.trim(),
      lastMaintenanceDate: null,
      nextMaintenanceDate: null,
      maintenanceStatus: '',
      lastModernizationDate: null,
      nextModernizationDate: null,
      modernizationStatus: '',
      quoteSent: false,
      alert: '',
      lastAlertDate: null,
      sourceRow: 0,
      createdAt: now,
      updatedAt: now,
    );

    Navigator.of(context).pop(compressor);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo compressor'),
      content: SizedBox(
        width: 760,
        height: 620,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.clientName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _field(
                      controller: _brandController,
                      label: 'Marca',
                      width: 220,
                    ),
                    _field(
                      controller: _modelController,
                      label: 'Modelo',
                      width: 220,
                      required: true,
                    ),
                    _field(
                      controller: _serialNumberController,
                      label: 'Número de série',
                      width: 220,
                    ),
                    _field(
                      controller: _yearController,
                      label: 'Ano',
                      width: 140,
                      keyboardType: TextInputType.number,
                    ),
                    _field(
                      controller: _typeController,
                      label: 'Tipo de compressor',
                      width: 250,
                    ),
                    _field(
                      controller: _materialController,
                      label: 'Material / referência',
                      width: 250,
                    ),
                    _field(
                      controller: _districtController,
                      label: 'Distrito',
                      width: 220,
                    ),
                    _field(
                      controller: _locationController,
                      label: 'Localização',
                      width: 250,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Contacto',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _field(
                      controller: _responsibleController,
                      label: 'Responsável',
                      width: 300,
                    ),
                    _field(
                      controller: _responsibleEmailController,
                      label: 'Email',
                      width: 350,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Dados técnicos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _field(
                      controller: _workingPressureController,
                      label: 'Pressão de trabalho (bar)',
                      width: 220,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    _field(
                      controller: _finalPressureController,
                      label: 'Pressão final (bar)',
                      width: 220,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    _field(
                      controller: _chargingRateController,
                      label: 'Caudal (l/min)',
                      width: 220,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    _field(
                      controller: _motorPowerController,
                      label: 'Potência (kW)',
                      width: 220,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'active',
                      child: Text('Ativo'),
                    ),
                    DropdownMenuItem(
                      value: 'inactive',
                      child: Text('Inativo'),
                    ),
                    DropdownMenuItem(
                      value: 'maintenance',
                      child: Text('Em manutenção'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _equipmentDetailsController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Detalhes do equipamento',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_rounded),
          label: const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required double width,
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Campo obrigatório';
                }

                return null;
              }
            : null,
      ),
    );
  }
}
