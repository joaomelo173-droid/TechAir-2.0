import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../compressors/data/repositories/firestore_compressor_repository.dart';
import '../../../compressors/domain/entities/compressor.dart';
import '../widgets/new_intervention_dialog.dart';
import '../../data/repositories/firestore_intervention_repository.dart';
import '../../domain/entities/intervention.dart';
import '../controllers/interventions_controller.dart';

class InterventionsPage extends StatefulWidget {
  const InterventionsPage({super.key});

  @override
  State<InterventionsPage> createState() => _InterventionsPageState();
}

class _InterventionsPageState extends State<InterventionsPage> {
  late final InterventionsController _controller;
  final TextEditingController _searchController = TextEditingController();

  InterventionType? _selectedType;

  @override
  void initState() {
    super.initState();

    _controller = InterventionsController(
      FirestoreInterventionRepository(
        FirebaseFirestore.instance,
      ),
      companyId: 'extincendios',
    )..load();

    _controller.addListener(_refresh);
    _searchController.addListener(_refresh);
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    _searchController
      ..removeListener(_refresh)
      ..dispose();

    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  List<Intervention> get _filteredInterventions {
    final query = _searchController.text.trim().toLowerCase();

    return _controller.interventions.where((intervention) {
      if (_selectedType != null && intervention.type != _selectedType) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final searchableText = [
        intervention.title,
        intervention.description,
        intervention.technicianName,
        intervention.clientName,
        intervention.compressorName,
        intervention.typeLabel,
        intervention.statusLabel,
      ].join(' ').toLowerCase();

      return searchableText.contains(query);
    }).toList();
  }

  Future<void> _openInterventionDetails(
    Intervention intervention,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: _InterventionDetailsSheet(
            intervention: intervention,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final interventions = _filteredInterventions;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSearchField(),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 24),
            Expanded(
              child: _buildContent(interventions),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Intervenções',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        FilledButton.icon(
          onPressed: _showNewInterventionMessage,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Nova intervenção'),
        ),
      ],
    );
  }

  Future<void> _showNewInterventionMessage() async {
    try {
      final compressorRepository = FirestoreCompressorRepository(
        FirebaseFirestore.instance,
      );

      final compressors = await compressorRepository.getAll(
        companyId: 'extincendios',
      );

      if (!mounted) {
        return;
      }

      if (compressors.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não existem compressores registados.'),
          ),
        );
        return;
      }

      final compressor = await showDialog<Compressor>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Selecionar compressor'),
            content: SizedBox(
              width: 600,
              height: 460,
              child: ListView.separated(
                itemCount: compressors.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = compressors[index];

                  return ListTile(
                    leading: const Icon(Icons.air_rounded),
                    title: Text(item.displayName),
                    subtitle: Text(
                      item.clientName.trim().isEmpty
                          ? 'Cliente não identificado'
                          : item.clientName,
                    ),
                    onTap: () {
                      Navigator.of(dialogContext).pop(item);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Cancelar'),
              ),
            ],
          );
        },
      );

      if (compressor == null || !mounted) {
        return;
      }

      final intervention = await showDialog<Intervention>(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return NewInterventionDialog(
            companyId: 'extincendios',
            clientId: compressor.clientId,
            clientName: compressor.clientName,
            compressorId: compressor.id,
            compressorName: compressor.displayName,
          );
        },
      );

      if (intervention == null || !mounted) {
        return;
      }

      final saved = await _controller.save(intervention);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saved
                ? 'Intervenção guardada com sucesso.'
                : _controller.error ??
                    'Não foi possível guardar a intervenção.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível carregar os compressores: $error',
          ),
        ),
      );
    }
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText:
            'Pesquisar por cliente, compressor, técnico ou intervenção...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpar pesquisa',
                onPressed: _searchController.clear,
                icon: const Icon(Icons.close_rounded),
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('Todas'),
          selected: _selectedType == null,
          onSelected: (_) {
            setState(() {
              _selectedType = null;
            });
          },
        ),
        _typeFilter(
          label: 'Manutenções',
          type: InterventionType.maintenance,
        ),
        _typeFilter(
          label: 'Modernizações',
          type: InterventionType.modernization,
        ),
        _typeFilter(
          label: 'Avarias',
          type: InterventionType.breakdown,
        ),
        _typeFilter(
          label: 'Inspeções',
          type: InterventionType.inspection,
        ),
      ],
    );
  }

  Widget _typeFilter({
    required String label,
    required InterventionType type,
  }) {
    return FilterChip(
      label: Text(label),
      selected: _selectedType == type,
      onSelected: (_) {
        setState(() {
          _selectedType = type;
        });
      },
    );
  }

  Widget _buildContent(List<Intervention> interventions) {
    if (_controller.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_controller.error != null) {
      return _ErrorState(
        message: _controller.error!,
        onRetry: _controller.load,
      );
    }

    if (_controller.interventions.isEmpty) {
      return _EmptyState(
        title: 'Ainda não existem intervenções.',
        description:
            'As manutenções, modernizações, avarias e inspeções aparecerão aqui.',
        onCreate: _showNewInterventionMessage,
      );
    }

    if (interventions.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma intervenção corresponde à pesquisa ou filtro.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _controller.load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: interventions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final intervention = interventions[index];

          return _InterventionCard(
            intervention: intervention,
            onOpen: () => _openInterventionDetails(intervention),
          );
        },
      ),
    );
  }
}

class _InterventionCard extends StatelessWidget {
  const _InterventionCard({
    required this.intervention,
    required this.onOpen,
  });

  final Intervention intervention;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onOpen,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: CircleAvatar(
          child: Icon(_iconForType(intervention.type)),
        ),
        title: Text(
          intervention.title.trim().isEmpty
              ? intervention.typeLabel
              : intervention.title,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (intervention.clientName.trim().isNotEmpty)
                Text(intervention.clientName),
              if (intervention.compressorName.trim().isNotEmpty)
                Text(intervention.compressorName),
              const SizedBox(height: 4),
              Text(
                [
                  _formatDate(intervention.startedAt),
                  intervention.statusLabel,
                  if (intervention.technicianName.trim().isNotEmpty)
                    intervention.technicianName,
                ].join(' • '),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }

  static IconData _iconForType(InterventionType type) {
    return switch (type) {
      InterventionType.maintenance => Icons.handyman_rounded,
      InterventionType.modernization => Icons.upgrade_rounded,
      InterventionType.breakdown => Icons.warning_amber_rounded,
      InterventionType.inspection => Icons.fact_check_rounded,
      InterventionType.other => Icons.home_repair_service_rounded,
    };
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class _InterventionDetailsSheet extends StatelessWidget {
  const _InterventionDetailsSheet({
    required this.intervention,
  });

  final Intervention intervention;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 5,
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _DetailsSection(
                  title: 'Identificação',
                  icon: Icons.badge_outlined,
                  children: [
                    _DetailRow(
                      label: 'Cliente',
                      value: intervention.clientName,
                    ),
                    _DetailRow(
                      label: 'Compressor',
                      value: intervention.compressorName,
                    ),
                    _DetailRow(
                      label: 'Tipo',
                      value: intervention.typeLabel,
                    ),
                    _DetailRow(
                      label: 'Estado',
                      value: intervention.statusLabel,
                    ),
                    _DetailRow(
                      label: 'Técnico',
                      value: intervention.technicianName,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _DetailsSection(
                  title: 'Datas e duração',
                  icon: Icons.calendar_month_outlined,
                  children: [
                    _DetailRow(
                      label: 'Data de início',
                      value: _formatDateTime(
                        intervention.startedAt,
                      ),
                    ),
                    _DetailRow(
                      label: 'Data de conclusão',
                      value: _formatOptionalDateTime(
                        intervention.completedAt,
                      ),
                    ),
                    _DetailRow(
                      label: 'Próxima intervenção',
                      value: _formatOptionalDate(
                        intervention.nextInterventionDate,
                      ),
                    ),
                    _DetailRow(
                      label: 'Duração',
                      value: _formatDuration(
                        intervention.durationMinutes,
                      ),
                    ),
                    _DetailRow(
                      label: 'Horas do compressor',
                      value: intervention.operatingHours == null
                          ? ''
                          : '${intervention.operatingHours} h',
                    ),
                  ],
                ),
                if (intervention.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _DetailsSection(
                    title: 'Descrição dos trabalhos',
                    icon: Icons.description_outlined,
                    children: [
                      _DetailText(
                        value: intervention.description,
                      ),
                    ],
                  ),
                ],
                if (intervention.partsUsed.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _DetailsSection(
                    title: 'Materiais utilizados',
                    icon: Icons.inventory_2_outlined,
                    children: intervention.partsUsed
                        .where((part) => part.trim().isNotEmpty)
                        .map(
                          (part) => _BulletRow(
                            value: part,
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (intervention.checklist.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _DetailsSection(
                    title: 'Checklist',
                    icon: Icons.fact_check_outlined,
                    children: intervention.checklist.entries
                        .map(
                          (entry) => _ChecklistRow(
                            label: entry.key,
                            completed: entry.value,
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (intervention.photoUrls.isNotEmpty ||
                    intervention.documentUrls.isNotEmpty ||
                    intervention.pdfUrl.trim().isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _DetailsSection(
                    title: 'Anexos',
                    icon: Icons.attach_file_rounded,
                    children: [
                      if (intervention.photoUrls.isNotEmpty)
                        _DetailRow(
                          label: 'Fotografias',
                          value: '${intervention.photoUrls.length}',
                        ),
                      if (intervention.documentUrls.isNotEmpty)
                        _DetailRow(
                          label: 'Documentos',
                          value: '${intervention.documentUrls.length}',
                        ),
                      if (intervention.pdfUrl.trim().isNotEmpty)
                        const _DetailRow(
                          label: 'Relatório PDF',
                          value: 'Disponível',
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                _buildActions(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final title = intervention.title.trim().isEmpty
        ? intervention.typeLabel
        : intervention.title.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 27,
          child: Icon(
            _iconForType(intervention.type),
            size: 27,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusBadge(
                    label: intervention.typeLabel,
                    icon: _iconForType(intervention.type),
                  ),
                  _StatusBadge(
                    label: intervention.statusLabel,
                    icon: _iconForStatus(intervention.status),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Fechar',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'A edição será ligada na próxima etapa.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar'),
          ),
          OutlinedButton.icon(
            onPressed: intervention.pdfUrl.trim().isEmpty
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'A abertura do PDF será ligada na próxima etapa.',
                        ),
                      ),
                    );
                  },
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: Text(
              intervention.pdfUrl.trim().isEmpty
                  ? 'PDF indisponível'
                  : 'Abrir PDF',
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'A eliminação será ligada na próxima etapa.',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
            ),
            label: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  static IconData _iconForType(InterventionType type) {
    return switch (type) {
      InterventionType.maintenance => Icons.handyman_rounded,
      InterventionType.modernization => Icons.upgrade_rounded,
      InterventionType.breakdown => Icons.warning_amber_rounded,
      InterventionType.inspection => Icons.fact_check_rounded,
      InterventionType.other => Icons.home_repair_service_rounded,
    };
  }

  static IconData _iconForStatus(
    InterventionStatus status,
  ) {
    return switch (status) {
      InterventionStatus.planned => Icons.schedule_rounded,
      InterventionStatus.inProgress => Icons.build_circle_rounded,
      InterventionStatus.completed => Icons.check_circle_rounded,
      InterventionStatus.cancelled => Icons.cancel_rounded,
    };
  }
}

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailText extends StatelessWidget {
  const _DetailText({
    required this.value,
  });

  final String value;

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      value,
      style: const TextStyle(
        height: 1.5,
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({
    required this.value,
  });

  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Icon(
              Icons.circle,
              size: 6,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.label,
    required this.completed,
  });

  final String label;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(
            completed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: completed ? Colors.green : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return '$day/$month/${date.year} às $hour:$minute';
}

String _formatOptionalDateTime(DateTime? date) {
  if (date == null) {
    return '';
  }

  return _formatDateTime(date);
}

String _formatOptionalDate(DateTime? date) {
  if (date == null) {
    return '';
  }

  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day/$month/${date.year}';
}

String _formatDuration(int minutes) {
  if (minutes <= 0) {
    return '';
  }

  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;

  if (hours == 0) {
    return '$remainingMinutes min';
  }

  if (remainingMinutes == 0) {
    return '${hours}h';
  }

  return '${hours}h ${remainingMinutes}min';
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.description,
    required this.onCreate,
  });

  final String title;
  final String description;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.home_repair_service_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nova intervenção'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Não foi possível carregar as intervenções.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
