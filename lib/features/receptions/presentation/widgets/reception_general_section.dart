import 'package:flutter/material.dart';

class ReceptionSelectOption {
  const ReceptionSelectOption({
    required this.id,
    required this.label,
    this.subtitle = '',
  });

  final String id;
  final String label;
  final String subtitle;
}

class ReceptionGeneralSection extends StatelessWidget {
  const ReceptionGeneralSection({
    super.key,
    required this.clients,
    required this.compressors,
    required this.selectedClientId,
    required this.selectedCompressorId,
    required this.receivedAt,
    required this.receivedByController,
    required this.onClientChanged,
    required this.onCompressorChanged,
    this.enabled = true,
  });

  final List<ReceptionSelectOption> clients;
  final List<ReceptionSelectOption> compressors;

  final String? selectedClientId;
  final String? selectedCompressorId;

  final DateTime receivedAt;
  final TextEditingController receivedByController;

  final ValueChanged<String?> onClientChanged;
  final ValueChanged<String?> onCompressorChanged;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dados Gerais',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _existingValue(
                selectedClientId,
                clients,
              ),
              decoration: const InputDecoration(
                labelText: 'Cliente',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.business_outlined,
                ),
              ),
              isExpanded: true,
              selectedItemBuilder: (context) {
                return clients
                    .map(
                      (client) => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          client.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList();
              },
              items: clients
                  .map(
                    (client) =>
                        DropdownMenuItem<String>(
                      value: client.id,
                      child: _OptionLabel(
                        label: client.label,
                        subtitle: client.subtitle,
                      ),
                    ),
                  )
                  .toList(),
              onChanged:
                  enabled ? onClientChanged : null,
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Selecione o cliente.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _existingValue(
                selectedCompressorId,
                compressors,
              ),
              decoration: InputDecoration(
                labelText: 'Compressor',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(
                  Icons.precision_manufacturing_outlined,
                ),
                helperText: selectedClientId == null
                    ? 'Selecione primeiro o cliente.'
                    : compressors.isEmpty
                        ? 'Este cliente não tem compressores.'
                        : null,
              ),
              isExpanded: true,
              selectedItemBuilder: (context) {
                return compressors
                    .map(
                      (compressor) => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          compressor.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList();
              },
              items: compressors
                  .map(
                    (compressor) =>
                        DropdownMenuItem<String>(
                      value: compressor.id,
                      child: _OptionLabel(
                        label: compressor.label,
                        subtitle: compressor.subtitle,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: enabled &&
                      selectedClientId != null &&
                      compressors.isNotEmpty
                  ? onCompressorChanged
                  : null,
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Selecione o compressor.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: receivedByController,
              enabled: enabled,
              textCapitalization:
                  TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Recebido por',
                hintText: 'Nome do colaborador',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.person_outline,
                ),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Indique quem recebeu o compressor.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),

            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Data e hora da receção',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.schedule_outlined,
                ),
              ),
              child: Text(
                _formatDateTime(receivedAt),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _existingValue(
    String? selectedId,
    List<ReceptionSelectOption> options,
  ) {
    if (selectedId == null ||
        selectedId.trim().isEmpty) {
      return null;
    }

    final exists = options.any(
      (option) => option.id == selectedId,
    );

    return exists ? selectedId : null;
  }

  String _formatDateTime(DateTime dateTime) {
    final day =
        dateTime.day.toString().padLeft(2, '0');
    final month =
        dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    final hour =
        dateTime.hour.toString().padLeft(2, '0');
    final minute =
        dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year às $hour:$minute';
  }
}

class _OptionLabel extends StatelessWidget {
  const _OptionLabel({
    required this.label,
    required this.subtitle,
  });

  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    if (subtitle.trim().isEmpty) {
      return Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodySmall,
          ),
        ],
      ),
    );
  }
}