import 'package:flutter/material.dart';

import '../../domain/entities/reception.dart';

class ReceptionReasonsSection extends StatelessWidget {
  const ReceptionReasonsSection({
    super.key,
    required this.selectedReasons,
    required this.onReasonChanged,
    required this.expectedMaintenanceController,
    required this.reportedFaultController,
    required this.expectedRepairController,
    required this.expectedModernizationController,
    required this.selectedFaultTypes,
    required this.onFaultTypeChanged,
    this.enabled = true,
  });

  final Set<ReceptionReason> selectedReasons;

  final void Function(
    ReceptionReason reason,
    bool selected,
  ) onReasonChanged;

  final TextEditingController
      expectedMaintenanceController;

  final TextEditingController reportedFaultController;
  final TextEditingController expectedRepairController;

  final TextEditingController
      expectedModernizationController;

  final Set<CompressorFaultType> selectedFaultTypes;

  final void Function(
    CompressorFaultType faultType,
    bool selected,
  ) onFaultTypeChanged;

  final bool enabled;

  bool get _hasMaintenance =>
      selectedReasons.contains(
        ReceptionReason.maintenance,
      );

  bool get _hasBreakdown =>
      selectedReasons.contains(
        ReceptionReason.breakdown,
      );

  bool get _hasModernization =>
      selectedReasons.contains(
        ReceptionReason.modernization,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Motivo da Entrada',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pode selecionar um, dois ou os três motivos.',
                  style:
                      Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: _hasMaintenance,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity:
                      ListTileControlAffinity.leading,
                  title: const Text('Manutenção'),
                  subtitle: const Text(
                    'Revisão ou manutenção preventiva.',
                  ),
                  secondary: const Icon(
                    Icons.build_outlined,
                  ),
                  onChanged: enabled
                      ? (value) {
                          onReasonChanged(
                            ReceptionReason.maintenance,
                            value ?? false,
                          );
                        }
                      : null,
                ),
                const Divider(),
                CheckboxListTile(
                  value: _hasBreakdown,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity:
                      ListTileControlAffinity.leading,
                  title: const Text('Avaria'),
                  subtitle: const Text(
                    'Falha ou problema indicado pelo cliente.',
                  ),
                  secondary: const Icon(
                    Icons.warning_amber_outlined,
                  ),
                  onChanged: enabled
                      ? (value) {
                          onReasonChanged(
                            ReceptionReason.breakdown,
                            value ?? false,
                          );
                        }
                      : null,
                ),
                const Divider(),
                CheckboxListTile(
                  value: _hasModernization,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity:
                      ListTileControlAffinity.leading,
                  title: const Text('Modernização'),
                  subtitle: const Text(
                    'Alteração ou melhoria do equipamento.',
                  ),
                  secondary: const Icon(
                    Icons.upgrade_outlined,
                  ),
                  onChanged: enabled
                      ? (value) {
                          onReasonChanged(
                            ReceptionReason.modernization,
                            value ?? false,
                          );
                        }
                      : null,
                ),
                if (selectedReasons.isEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Selecione pelo menos um motivo.',
                    style: TextStyle(
                      color:
                          Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_hasMaintenance) ...[
          const SizedBox(height: 16),
          _MaintenanceSection(
            controller:
                expectedMaintenanceController,
            enabled: enabled,
          ),
        ],
        if (_hasBreakdown) ...[
          const SizedBox(height: 16),
          _BreakdownSection(
            reportedFaultController:
                reportedFaultController,
            expectedRepairController:
                expectedRepairController,
            selectedFaultTypes: selectedFaultTypes,
            onFaultTypeChanged:
                onFaultTypeChanged,
            enabled: enabled,
          ),
        ],
        if (_hasModernization) ...[
          const SizedBox(height: 16),
          _ModernizationSection(
            controller:
                expectedModernizationController,
            enabled: enabled,
          ),
        ],
      ],
    );
  }
}

class _MaintenanceSection extends StatelessWidget {
  const _MaintenanceSection({
    required this.controller,
    required this.enabled,
  });

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const _SectionTitle(
              icon: Icons.build_outlined,
              title: 'Manutenção',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              enabled: enabled,
              minLines: 3,
              maxLines: 6,
              textCapitalization:
                  TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Trabalho previsto',
                hintText:
                    'Ex.: revisão das 4000 horas, mudança de óleo e filtros...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Indique o trabalho de manutenção previsto.';
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownSection extends StatelessWidget {
  const _BreakdownSection({
    required this.reportedFaultController,
    required this.expectedRepairController,
    required this.selectedFaultTypes,
    required this.onFaultTypeChanged,
    required this.enabled,
  });

  final TextEditingController reportedFaultController;
  final TextEditingController expectedRepairController;

  final Set<CompressorFaultType> selectedFaultTypes;

  final void Function(
    CompressorFaultType faultType,
    bool selected,
  ) onFaultTypeChanged;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const _SectionTitle(
              icon: Icons.warning_amber_outlined,
              title: 'Avaria',
            ),
            const SizedBox(height: 6),
            Text(
              'Selecione todos os sintomas indicados.',
              style:
                  Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            ...CompressorFaultType.values.map(
              (faultType) {
                return CheckboxListTile(
                  value:
                      selectedFaultTypes.contains(faultType),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity:
                      ListTileControlAffinity.leading,
                  title: Text(
                    Reception.faultTypeLabel(
                      faultType,
                    ),
                  ),
                  onChanged: enabled
                      ? (value) {
                          onFaultTypeChanged(
                            faultType,
                            value ?? false,
                          );
                        }
                      : null,
                );
              },
            ),
            if (selectedFaultTypes.isEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Selecione pelo menos um tipo de avaria.',
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: reportedFaultController,
              enabled: enabled,
              minLines: 3,
              maxLines: 6,
              textCapitalization:
                  TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText:
                    'Avaria indicada pelo cliente',
                hintText:
                    'Descreva o problema ou os sintomas comunicados.',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Descreva a avaria indicada.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: expectedRepairController,
              enabled: enabled,
              minLines: 3,
              maxLines: 6,
              textCapitalization:
                  TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Trabalho previsto',
                hintText:
                    'Indique o trabalho inicialmente previsto.',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernizationSection extends StatelessWidget {
  const _ModernizationSection({
    required this.controller,
    required this.enabled,
  });

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const _SectionTitle(
              icon: Icons.upgrade_outlined,
              title: 'Modernização',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              enabled: enabled,
              minLines: 3,
              maxLines: 6,
              textCapitalization:
                  TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Modernização prevista',
                hintText:
                    'Ex.: instalar controlador, substituir quadro elétrico...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Indique a modernização prevista.';
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}