import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/new_compressor_dialog.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../clients/domain/entities/client.dart';
import '../../data/repositories/firestore_compressor_repository.dart';
import '../../domain/entities/compressor.dart';
import '../controllers/compressors_controller.dart';

class CompressorsPage extends StatefulWidget {
  const CompressorsPage({
    super.key,
    required this.client,
  });

  final Client client;

  @override
  State<CompressorsPage> createState() => _CompressorsPageState();
}

class _CompressorsPageState extends State<CompressorsPage> {
  late final CompressorsController _controller;
  final TextEditingController _searchController = TextEditingController();

  String _search = '';

  @override
  void initState() {
    super.initState();

    _controller = CompressorsController(
      FirestoreCompressorRepository(
        FirebaseFirestore.instance,
      ),
      companyId: widget.client.companyId,
      clientId: widget.client.id,
    )..load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  List<Compressor> get _filteredCompressors {
    final query = _search.trim().toLowerCase();

    final compressors = [..._controller.compressors]..sort(
        (a, b) => a.displayName.toLowerCase().compareTo(
              b.displayName.toLowerCase(),
            ),
      );

    if (query.isEmpty) {
      return compressors;
    }

    return compressors.where((compressor) {
      return compressor.displayName.toLowerCase().contains(query) ||
          compressor.model.toLowerCase().contains(query) ||
          compressor.material.toLowerCase().contains(query) ||
          compressor.equipmentDetails.toLowerCase().contains(query) ||
          compressor.responsible.toLowerCase().contains(query) ||
          compressor.district.toLowerCase().contains(query) ||
          compressor.maintenanceStatus.toLowerCase().contains(query) ||
          compressor.modernizationStatus.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _createCompressor() async {
    final compressor = await showDialog<Compressor>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return NewCompressorDialog(
          companyId: widget.client.companyId,
          clientId: widget.client.id,
          clientName: widget.client.name,
        );
      },
    );

    if (compressor == null || !mounted) {
      return;
    }

    final saved = await _controller.save(compressor);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            saved
                ? 'Compressor criado com sucesso.'
                : _controller.error ?? 'Não foi possível criar o compressor.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final compressors = _filteredCompressors;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Compressores',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  widget.client.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              FilledButton.icon(
                onPressed: _controller.loading ? null : _createCompressor,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Novo compressor'),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _controller.loading ? null : _controller.load,
                tooltip: 'Atualizar',
                icon: const Icon(Icons.refresh_rounded),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ClientSummary(
                    client: widget.client,
                    compressorCount: _controller.compressors.length,
                  ),
                  const SizedBox(height: 18),
                  _SearchBar(
                    controller: _searchController,
                    count: compressors.length,
                    onChanged: (value) {
                      setState(() {
                        _search = value;
                      });
                    },
                    onClear: () {
                      _searchController.clear();

                      setState(() {
                        _search = '';
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: _buildBody(compressors),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(List<Compressor> compressors) {
    if (_controller.loading && _controller.compressors.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_controller.compressors.isEmpty) {
      return _EmptyState(
        onRefresh: _controller.load,
        onCreate: _createCompressor,
      );
    }

    if (compressors.isEmpty) {
      return const _NoSearchResults();
    }

    return RefreshIndicator(
      onRefresh: _controller.load,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 1100) {
            return GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 2.45,
              ),
              itemCount: compressors.length,
              itemBuilder: (context, index) {
                final compressor = compressors[index];

                return _CompressorCard(
                  compressor: compressor,
                  onOpen: () => _openDetails(compressor),
                  onDelete: () => _confirmDelete(compressor),
                );
              },
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: compressors.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final compressor = compressors[index];

              return _CompressorCard(
                compressor: compressor,
                onOpen: () => _openDetails(compressor),
                onDelete: () => _confirmDelete(compressor),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openDetails(Compressor compressor) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.88,
          child: _CompressorDetailsSheet(
            compressor: compressor,
            client: widget.client,
            onDelete: () {
              Navigator.of(context).pop();
              _confirmDelete(compressor);
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(Compressor compressor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar compressor?'),
          content: Text(
            'O compressor “${compressor.displayName}” será eliminado permanentemente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _controller.delete(compressor.id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Compressor eliminado.'),
          ),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Não foi possível eliminar o compressor: $error',
            ),
          ),
        );
    }
  }
}

class _ClientSummary extends StatelessWidget {
  const _ClientSummary({
    required this.client,
    required this.compressorCount,
  });

  final Client client;
  final int compressorCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 650;

          final information = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                client.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 18,
                runSpacing: 8,
                children: [
                  if (client.responsible.isNotEmpty)
                    _InlineDetail(
                      icon: Icons.person_outline_rounded,
                      value: client.responsible,
                    ),
                  if (client.phone.isNotEmpty)
                    _InlineDetail(
                      icon: Icons.phone_outlined,
                      value: client.phone,
                    ),
                  if (client.email.isNotEmpty)
                    _InlineDetail(
                      icon: Icons.mail_outline_rounded,
                      value: client.email,
                    ),
                  if (client.locationLabel.isNotEmpty)
                    _InlineDetail(
                      icon: Icons.location_on_outlined,
                      value: client.locationLabel,
                    ),
                ],
              ),
            ],
          );

          final counter = Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.precision_manufacturing_rounded,
                  color: AppColors.orange,
                ),
                const SizedBox(width: 10),
                Text(
                  '$compressorCount',
                  style: const TextStyle(
                    color: AppColors.orange,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  compressorCount == 1 ? 'compressor' : 'compressores',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                information,
                const SizedBox(height: 16),
                counter,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: information),
              const SizedBox(width: 20),
              counter,
            ],
          );
        },
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.count,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final int count;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText:
                    'Pesquisar por modelo, material, série, responsável ou estado…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: onClear,
                        icon: const Icon(Icons.close_rounded),
                      ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompressorCard extends StatelessWidget {
  const _CompressorCard({
    required this.compressor,
    required this.onOpen,
    required this.onDelete,
  });

  final Compressor compressor;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final status = _MaintenanceVisual.from(compressor);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.precision_manufacturing_rounded,
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            compressor.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _StatusBadge(
                          label: status.label,
                          color: status.color,
                          icon: status.icon,
                        ),
                      ],
                    ),
                    if (compressor.material.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        compressor.material,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 13),
                    Wrap(
                      spacing: 18,
                      runSpacing: 8,
                      children: [
                        if (compressor.lastMaintenanceDate != null)
                          _InlineDetail(
                            icon: Icons.build_circle_outlined,
                            value:
                                'Última: ${_formatDate(compressor.lastMaintenanceDate)}',
                          ),
                        if (compressor.nextMaintenanceDate != null)
                          _InlineDetail(
                            icon: Icons.event_outlined,
                            value:
                                'Próxima: ${_formatDate(compressor.nextMaintenanceDate)}',
                          ),
                        if (compressor.district.isNotEmpty)
                          _InlineDetail(
                            icon: Icons.location_on_outlined,
                            value: compressor.district,
                          ),
                        if (compressor.responsible.isNotEmpty)
                          _InlineDetail(
                            icon: Icons.person_outline_rounded,
                            value: compressor.responsible,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                tooltip: 'Opções',
                onSelected: (value) {
                  if (value == 'open') {
                    onOpen();
                  }

                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'open',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_outlined),
                        SizedBox(width: 10),
                        Text('Ver detalhes'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red,
                        ),
                        SizedBox(width: 10),
                        Text('Eliminar'),
                      ],
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompressorDetailsSheet extends StatelessWidget {
  const _CompressorDetailsSheet({
    required this.compressor,
    required this.client,
    required this.onDelete,
  });

  final Compressor compressor;
  final Client client;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final status = _MaintenanceVisual.from(compressor);

    return Column(
      children: [
        Container(
          height: 5,
          width: 48,
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.precision_manufacturing_rounded,
                        size: 30,
                        color: AppColors.orange,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            compressor.displayName,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            client.name,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(
                      label: status.label,
                      color: status.color,
                      icon: status.icon,
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                _DetailsSection(
                  title: 'Identificação',
                  icon: Icons.badge_outlined,
                  children: [
                    _DetailRow(
                      label: 'Marca',
                      value: compressor.brand,
                    ),
                    _DetailRow(
                      label: 'Modelo',
                      value: compressor.model,
                    ),
                    _DetailRow(
                      label: 'Número de série',
                      value: compressor.serialNumber,
                    ),
                    _DetailRow(
                      label: 'Ano de fabrico',
                      value: compressor.manufactureYear?.toString() ?? '',
                    ),
                    _DetailRow(
                      label: 'Tipo',
                      value: compressor.compressorType,
                    ),
                    _DetailRow(
                      label: 'Material',
                      value: compressor.material,
                    ),
                    _DetailRow(
                      label: 'Localização',
                      value: compressor.location,
                    ),
                    _DetailRow(
                      label: 'Distrito',
                      value: compressor.district,
                    ),
                    _DetailRow(
                      label: 'Detalhes do equipamento',
                      value: compressor.equipmentDetails,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _DetailsSection(
                  title: 'Dados técnicos',
                  icon: Icons.settings_outlined,
                  children: [
                    _DetailRow(
                      label: 'Pressão de trabalho',
                      value: _formatTechnicalValue(
                        compressor.workingPressureBar,
                        'bar',
                      ),
                    ),
                    _DetailRow(
                      label: 'Pressão final',
                      value: _formatTechnicalValue(
                        compressor.finalPressureBar,
                        'bar',
                      ),
                    ),
                    _DetailRow(
                      label: 'Pressão de teste',
                      value: _formatTechnicalValue(
                        compressor.testPressureBar,
                        'bar',
                      ),
                    ),
                    _DetailRow(
                      label: 'Caudal',
                      value: _formatTechnicalValue(
                        compressor.chargingRateLitersMinute,
                        'l/min',
                      ),
                    ),
                    _DetailRow(
                      label: 'Potência do motor',
                      value: _formatTechnicalValue(
                        compressor.motorPowerKw,
                        'kW',
                      ),
                    ),
                    _DetailRow(
                      label: 'Tensão',
                      value: compressor.voltage == null
                          ? ''
                          : '${compressor.voltage} V',
                    ),
                    _DetailRow(
                      label: 'Fases',
                      value: compressor.phases?.toString() ?? '',
                    ),
                    _DetailRow(
                      label: 'Horas de funcionamento',
                      value: compressor.operatingHours == null
                          ? ''
                          : '${compressor.operatingHours} h',
                    ),
                    _DetailRow(
                      label: 'Número de estágios',
                      value: compressor.stageCount?.toString() ?? '',
                    ),
                    _DetailRow(
                      label: 'Tipo de óleo',
                      value: compressor.oilType,
                    ),
                    _DetailRow(
                      label: 'Tipo de filtro',
                      value: compressor.filterType,
                    ),
                    _DetailRow(
                      label: 'Estado do equipamento',
                      value: _equipmentStatusLabel(compressor.status),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _DetailsSection(
                  title: 'Manutenção',
                  icon: Icons.handyman_outlined,
                  children: [
                    _DetailRow(
                      label: 'Última manutenção',
                      value: _formatDate(compressor.lastMaintenanceDate),
                    ),
                    _DetailRow(
                      label: 'Próxima manutenção',
                      value: _formatDate(compressor.nextMaintenanceDate),
                    ),
                    _DetailRow(
                      label: 'Estado',
                      value: compressor.maintenanceStatus,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _DetailsSection(
                  title: 'Modernização',
                  icon: Icons.settings_suggest_outlined,
                  children: [
                    _DetailRow(
                      label: 'Última modernização',
                      value: _formatDate(
                        compressor.lastModernizationDate,
                      ),
                    ),
                    _DetailRow(
                      label: 'Próxima modernização',
                      value: _formatDate(
                        compressor.nextModernizationDate,
                      ),
                    ),
                    _DetailRow(
                      label: 'Estado',
                      value: compressor.modernizationStatus,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _DetailsSection(
                  title: 'Contacto',
                  icon: Icons.person_outline_rounded,
                  children: [
                    _DetailRow(
                      label: 'Responsável',
                      value: compressor.responsible,
                    ),
                    _DetailRow(
                      label: 'Email',
                      value: compressor.responsibleEmail,
                    ),
                  ],
                ),
                if (compressor.notes.isNotEmpty ||
                    compressor.alert.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _DetailsSection(
                    title: 'Observações',
                    icon: Icons.notes_rounded,
                    children: [
                      _DetailRow(
                        label: 'Notas',
                        value: compressor.notes,
                      ),
                      _DetailRow(
                        label: 'Alerta',
                        value: compressor.alert,
                      ),
                      _DetailRow(
                        label: 'Último alerta',
                        value: _formatDate(
                          compressor.lastAlertDate,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red,
                    ),
                    label: const Text('Eliminar compressor'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
    final visibleChildren = children.where((child) {
      if (child is _DetailRow) {
        return child.value.trim().isNotEmpty;
      }

      return true;
    }).toList();

    if (visibleChildren.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
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
                color: AppColors.orange,
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...visibleChildren,
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
            width: 170,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
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

class _InlineDetail extends StatelessWidget {
  const _InlineDetail({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: .28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MaintenanceVisual {
  const _MaintenanceVisual({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  factory _MaintenanceVisual.from(Compressor compressor) {
    final rawStatus = compressor.maintenanceStatus.trim();
    final normalized = rawStatus.toLowerCase();
    final nextDate = compressor.nextMaintenanceDate;
    final now = DateTime.now();

    if (compressor.hasMaintenanceAlert ||
        normalized.contains('atras') ||
        normalized.contains('venc') ||
        (nextDate != null && nextDate.isBefore(now))) {
      return _MaintenanceVisual(
        label: rawStatus.isEmpty ? 'Vencida' : rawStatus,
        color: Colors.red.shade400,
        icon: Icons.error_outline_rounded,
      );
    }

    if (nextDate != null) {
      final difference = nextDate.difference(now).inDays;

      if (difference <= 30) {
        return _MaintenanceVisual(
          label: rawStatus.isEmpty ? 'A vencer' : rawStatus,
          color: Colors.orange.shade400,
          icon: Icons.schedule_rounded,
        );
      }
    }

    if (normalized.contains('dia') ||
        normalized.contains('ok') ||
        normalized.contains('válid') ||
        normalized.contains('valid')) {
      return _MaintenanceVisual(
        label: rawStatus.isEmpty ? 'Em dia' : rawStatus,
        color: Colors.green.shade400,
        icon: Icons.check_circle_outline_rounded,
      );
    }

    return _MaintenanceVisual(
      label: rawStatus.isEmpty ? 'Sem estado' : rawStatus,
      color: AppColors.textSecondary,
      icon: Icons.info_outline_rounded,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onRefresh,
    required this.onCreate,
  });

  final VoidCallback onRefresh;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.precision_manufacturing_outlined,
              size: 58,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 14),
            Text(
              'Nenhum compressor associado',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Este cliente ainda não tem compressores registados.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Novo compressor'),
                ),
                OutlinedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Atualizar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 54,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 14),
          Text(
            'Nenhum compressor encontrado',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Altera a pesquisa para ver outros resultados.',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTechnicalValue(double? value, String unit) {
  if (value == null) {
    return '';
  }

  final formatted = value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1).replaceAll('.', ',');

  return '$formatted $unit';
}

String _equipmentStatusLabel(String status) {
  switch (status.trim().toLowerCase()) {
    case 'active':
    case 'ativo':
      return 'Ativo';

    case 'inactive':
    case 'inativo':
      return 'Inativo';

    case 'maintenance':
      return 'Em manutenção';

    default:
      return status.trim();
  }
}

String _formatDate(DateTime? date) {
  if (date == null) {
    return '';
  }

  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day/$month/${date.year}';
}
