import 'package:flutter/material.dart';

import '../../domain/entities/workshop_job.dart';
import '../../domain/entities/workshop_service.dart';
import '../controllers/workshop_service_controller.dart';
import 'dart:ui';

class WorkshopDetailPage extends StatefulWidget {
  const WorkshopDetailPage({
    super.key,
    required this.job,
  });

  final WorkshopJob job;

  @override
  State<WorkshopDetailPage> createState() => _WorkshopDetailPageState();
}

class _WorkshopDetailPageState extends State<WorkshopDetailPage> {
  static const String companyId = 'extincendios';

  final WorkshopServiceController _controller = WorkshopServiceController();

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Scaffold(
      appBar: AppBar(
        title: Text(job.jobNumber),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informação Geral',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  _InfoRow(
                    icon: Icons.business,
                    title: 'Cliente',
                    value: job.clientName,
                  ),
                  const Divider(),
                  _InfoRow(
                    icon: Icons.precision_manufacturing,
                    title: 'Compressor',
                    value: job.compressorName,
                  ),
                  const Divider(),
                  _InfoRow(
                    icon: Icons.badge,
                    title: 'Estado',
                    value: job.statusLabel,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          DefaultTabController(
            length: 5,
            child: Column(
              children: [
                const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.build),
                      text: 'Serviços',
                    ),
                    Tab(
                      icon: Icon(Icons.inventory_2),
                      text: 'Peças',
                    ),
                    Tab(
                      icon: Icon(Icons.photo_camera),
                      text: 'Fotografias',
                    ),
                    Tab(
                      icon: Icon(Icons.history),
                      text: 'Linha Temporal',
                    ),
                    Tab(
                      icon: Icon(Icons.description),
                      text: 'Documentos',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 520,
                  child: TabBarView(
                    children: [
                      _StreamServicesTab(
                        companyId: companyId,
                        workshopJobId: job.id,
                        controller: _controller,
                      ),
                      const _ComingSoon('Peças'),
                      const _ComingSoon('Fotografias'),
                      const _ComingSoon('Linha Temporal'),
                      const _ComingSoon('Documentos'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? 'Não definido' : value,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title disponível num próximo passo.',
        style: const TextStyle(
          fontSize: 18,
        ),
      ),
    );
  }
}

class _StreamServicesTab extends StatelessWidget {
  const _StreamServicesTab({
    required this.companyId,
    required this.workshopJobId,
    required this.controller,
  });

  final String companyId;
  final String workshopJobId;
  final WorkshopServiceController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Serviços da obra',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            FilledButton.icon(
              onPressed: () {
                _showCreateServiceDialog(context);
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Novo serviço'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<List<WorkshopService>>(
            stream: controller.watchServices(
              companyId: companyId,
              workshopJobId: workshopJobId,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Erro ao carregar os serviços:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final services = snapshot.data ?? [];

              if (services.isEmpty) {
                return const _EmptyServicesState();
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                itemCount: services.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 12);
                },
                itemBuilder: (context, index) {
                  final service = services[index];

                  return _WorkshopServiceCard(
                    service: service,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showCreateServiceDialog(
    BuildContext context,
  ) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        var isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> save() async {
              final name = nameController.text.trim();
              final description = descriptionController.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Indica o nome do serviço.',
                    ),
                  ),
                );
                return;
              }

              setDialogState(() {
                isSaving = true;
              });

              final now = DateTime.now();

              try {
                await controller.createService(
                  companyId: companyId,
                  workshopJobId: workshopJobId,
                  service: WorkshopService(
                    id: '',
                    workshopJobId: workshopJobId,
                    name: name,
                    description: description,
                    order: now.millisecondsSinceEpoch,
                    status: WorkshopServiceStatus.waiting,
                    elapsedSeconds: 0,
                    timerRunning: false,
                    startedAt: null,
                    finishedAt: null,
                    technicianId: '',
                    technicianName: '',
                    partsIds: const [],
                    notes: '',
                    createdAt: now,
                    updatedAt: now,
                  ),
                );

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop(true);
                }
              } catch (error) {
                setDialogState(() {
                  isSaving = false;
                });

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Erro ao criar o serviço: $error',
                      ),
                    ),
                  );
                }
              }
            }

            return AlertDialog(
              title: const Text('Novo serviço'),
              content: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nome do serviço',
                        hintText: 'Ex.: Mudança de óleo',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: descriptionController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        hintText: 'Descrição opcional do trabalho',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop(false);
                        },
                  child: const Text('Cancelar'),
                ),
                FilledButton.icon(
                  onPressed: isSaving ? null : save,
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    isSaving ? 'A guardar...' : 'Guardar',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();

    if (created == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Serviço criado com sucesso.',
          ),
        ),
      );
    }
  }
}

class _WorkshopServiceCard extends StatelessWidget {
  const _WorkshopServiceCard({
    required this.service,
  });

  final WorkshopService service;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.build_circle_outlined,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (service.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Chip(
                        avatar: Icon(
                          _statusIcon(service.status),
                          size: 17,
                        ),
                        label: Text(
                          service.status.label,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _formatDuration(service.elapsed),
                        style: const TextStyle(
                          fontFeatures: [
                            FontFeature.tabularFigures(),
                          ],
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  static IconData _statusIcon(
    WorkshopServiceStatus status,
  ) {
    switch (status) {
      case WorkshopServiceStatus.waiting:
        return Icons.schedule_rounded;
      case WorkshopServiceStatus.running:
        return Icons.play_circle_outline_rounded;
      case WorkshopServiceStatus.waitingCustomer:
        return Icons.person_outline_rounded;
      case WorkshopServiceStatus.waitingParts:
        return Icons.inventory_2_outlined;
      case WorkshopServiceStatus.waitingSupplier:
        return Icons.local_shipping_outlined;
      case WorkshopServiceStatus.testing:
        return Icons.science_outlined;
      case WorkshopServiceStatus.completed:
        return Icons.check_circle_outline_rounded;
      case WorkshopServiceStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  static String _formatDuration(
    Duration duration,
  ) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }
}

class _EmptyServicesState extends StatelessWidget {
  const _EmptyServicesState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.build_outlined,
              size: 60,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Ainda não existem serviços',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Cria o primeiro serviço desta obra.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
