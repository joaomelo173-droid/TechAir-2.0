import 'package:flutter/material.dart';

import '../../domain/entities/intervention.dart';

class NewInterventionDialog extends StatefulWidget {
  const NewInterventionDialog({
    required this.companyId,
    required this.clientId,
    required this.clientName,
    required this.compressorId,
    required this.compressorName,
    super.key,
  });

  final String companyId;
  final String clientId;
  final String clientName;
  final String compressorId;
  final String compressorName;

  @override
  State<NewInterventionDialog> createState() =>
      _NewInterventionDialogState();
}

class _NewInterventionDialogState
    extends State<NewInterventionDialog> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _technicianController = TextEditingController();

  InterventionType _type = InterventionType.maintenance;
  InterventionStatus _status = InterventionStatus.completed;

  DateTime _startedAt = DateTime.now();
  DateTime? _nextInterventionDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _technicianController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova intervenção'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ReadOnlyField(
                  label: 'Cliente',
                  value: widget.clientName,
                ),
                const SizedBox(height: 12),
                _ReadOnlyField(
                  label: 'Compressor',
                  value: widget.compressorName,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<InterventionType>(
                  initialValue: _type,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de intervenção',
                    border: OutlineInputBorder(),
                  ),
                  items: InterventionType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_typeLabel(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _type = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<InterventionStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                  ),
                  items: InterventionStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_statusLabel(status)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Indica um título.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _technicianController,
                  decoration: const InputDecoration(
                    labelText: 'Técnico',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Descrição / observações',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                _DateField(
                  label: 'Data da intervenção',
                  value: _startedAt,
                  onPressed: _selectStartedDate,
                ),
                const SizedBox(height: 12),
                _DateField(
                  label: 'Próxima intervenção',
                  value: _nextInterventionDate,
                  allowClear: true,
                  onPressed: _selectNextDate,
                  onClear: () {
                    setState(() {
                      _nextInterventionDate = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Future<void> _selectStartedDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _startedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() {
        _startedAt = selected;
      });
    }
  }

  Future<void> _selectNextDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _nextInterventionDate ?? _startedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() {
        _nextInterventionDate = selected;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();

    final intervention = Intervention(
      id: '',
      companyId: widget.companyId,
      clientId: widget.clientId,
      compressorId: widget.compressorId,
      clientName: widget.clientName,
      compressorName: widget.compressorName,
      type: _type,
      status: _status,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      technicianName: _technicianController.text.trim(),
      startedAt: _startedAt,
      completedAt: _status == InterventionStatus.completed
          ? _startedAt
          : null,
      nextInterventionDate: _nextInterventionDate,
      durationMinutes: 0,
      operatingHours: null,
      partsUsed: const [],
      checklist: const {},
      photoUrls: const [],
      documentUrls: const [],
      pdfUrl: '',
      createdAt: now,
      updatedAt: now,
    );

    Navigator.of(context).pop(intervention);
  }

  static String _typeLabel(InterventionType type) {
    return switch (type) {
      InterventionType.maintenance => 'Manutenção',
      InterventionType.modernization => 'Modernização',
      InterventionType.breakdown => 'Avaria',
      InterventionType.inspection => 'Inspeção',
      InterventionType.other => 'Outra',
    };
  }

  static String _statusLabel(
  InterventionStatus status,
) {
  return switch (status) {
    InterventionStatus.planned => 'Planeada',
    InterventionStatus.inProgress => 'Em curso',
    InterventionStatus.completed => 'Concluída',
    InterventionStatus.cancelled => 'Cancelada',
  };
}
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: Text(
        value.trim().isEmpty ? 'Não definido' : value,
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onPressed,
    this.allowClear = false,
    this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPressed;
  final bool allowClear;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (allowClear && value != null)
              IconButton(
                tooltip: 'Limpar',
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
            IconButton(
              tooltip: 'Selecionar data',
              onPressed: onPressed,
              icon: const Icon(Icons.calendar_month_rounded),
            ),
          ],
        ),
      ),
      child: Text(
        value == null ? 'Não definida' : _formatDate(value!),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}