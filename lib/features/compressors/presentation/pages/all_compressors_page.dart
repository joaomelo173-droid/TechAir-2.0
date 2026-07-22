import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/repositories/firestore_compressor_repository.dart';
import '../../domain/entities/compressor.dart';
import '../controllers/compressors_controller.dart';

class AllCompressorsPage extends StatefulWidget {
  const AllCompressorsPage({super.key});

  @override
  State<AllCompressorsPage> createState() => _AllCompressorsPageState();
}

class _AllCompressorsPageState extends State<AllCompressorsPage> {
  late final CompressorsController _controller;
  final TextEditingController _searchController = TextEditingController();

  String _search = '';

  @override
  void initState() {
    super.initState();

    _controller = CompressorsController(
      FirestoreCompressorRepository(FirebaseFirestore.instance),
      companyId: 'extincendios',
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

    final compressors = [..._controller.compressors]
      ..sort(
        (a, b) => a.displayName.toLowerCase().compareTo(
              b.displayName.toLowerCase(),
            ),
      );

    if (query.isEmpty) {
      return compressors;
    }

    return compressors.where((compressor) {
      return compressor.displayName.toLowerCase().contains(query) ||
          compressor.brand.toLowerCase().contains(query) ||
          compressor.model.toLowerCase().contains(query) ||
          compressor.serialNumber.toLowerCase().contains(query) ||
          compressor.material.toLowerCase().contains(query) ||
          compressor.responsible.toLowerCase().contains(query) ||
          compressor.district.toLowerCase().contains(query) ||
          compressor.equipmentDetails.toLowerCase().contains(query) ||
          compressor.maintenanceStatus.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final compressors = _filteredCompressors;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                count: _controller.compressors.length,
                loading: _controller.loading,
                onRefresh: _controller.load,
              ),
              const SizedBox(height: 22),
              _SearchToolbar(
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

    if (_controller.error case final error?) {
      return _ErrorState(
        message: error,
        onRetry: _controller.load,
      );
    }

    if (_controller.compressors.isEmpty) {
      return _EmptyState(
        onRefresh: _controller.load,
      );
    }

    if (compressors.isEmpty) {
      return const _NoResultsState();
    }

    return RefreshIndicator(
      onRefresh: _controller.load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: compressors.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final compressor = compressors[index];

          return _CompressorCard(
            compressor: compressor,
            onOpen: () => _openDetails(compressor),
          );
        },
      ),
    );
  }

  Future<void> _openDetails(Compressor compressor) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 760,
              maxHeight: 760,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.orange.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.air_rounded,
                          color: AppColors.orange,
                        ),
                      ),
                      const SizedBox(width: 14),
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
                            if (compressor.serialNumber.isNotEmpty)
                              Text(
                                'S/N ${compressor.serialNumber}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _DetailsSection(
                    title: 'Dados técnicos',
                    children: [
                      _DetailRow(label: 'Marca', value: compressor.brand),
                      _DetailRow(label: 'Modelo', value: compressor.model),
                      _DetailRow(
                        label: 'Número de série',
                        value: compressor.serialNumber,
                      ),
                      _DetailRow(
                        label: 'Ano',
                        value: compressor.manufactureYear?.toString() ?? '',
                      ),
                      _DetailRow(
                        label: 'Tipo',
                        value: compressor.compressorType,
                      ),
                      _DetailRow(
                        label: 'Pressão de trabalho',
                        value: _numberWithUnit(
                          compressor.workingPressureBar,
                          'bar',
                        ),
                      ),
                      _DetailRow(
                        label: 'Pressão de teste',
                        value: _numberWithUnit(
                          compressor.testPressureBar,
                          'bar',
                        ),
                      ),
                      _DetailRow(
                        label: 'Pressão final',
                        value: _numberWithUnit(
                          compressor.finalPressureBar,
                          'bar',
                        ),
                      ),
                      _DetailRow(
                        label: 'Caudal',
                        value: _numberWithUnit(
                          compressor.chargingRateLitersMinute,
                          'l/min',
                        ),
                      ),
                      _DetailRow(
                        label: 'Potência',
                        value: _numberWithUnit(
                          compressor.motorPowerKw,
                          'kW',
                        ),
                      ),
                      _DetailRow(
                        label: 'Horas',
                        value: compressor.operatingHours?.toString() ?? '',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DetailsSection(
                    title: 'Manutenção',
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

                const SizedBox(height: 16),

_DetailsSection(
  title: 'Modernização',
  children: [
    _DetailRow(
      label: 'Última modernização',
      value: _formatDate(compressor.lastModernizationDate),
    ),
    _DetailRow(
      label: 'Próxima modernização',
      value: _formatDate(compressor.nextModernizationDate),
    ),
    _DetailRow(
      label: 'Estado',
      value: compressor.modernizationStatus,
    ),
    _DetailRow(
      label: 'Orçamento enviado',
      value: compressor.quoteSent ? 'Sim' : 'Não',
    ),
  ],
),
                  const SizedBox(height: 16),
                  _DetailsSection(
  title: 'Localização e contacto',
  children: [
    _DetailRow(
      label: 'Cliente / Corporação',
      value: compressor.clientName,
    ),
    _DetailRow(
      label: 'Distrito',
      value: compressor.district,
    ),
    _DetailRow(
      label: 'Localização',
      value: compressor.location,
    ),
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
                      compressor.equipmentDetails.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _DetailsSection(
                      title: 'Observações',
                      children: [
                        _DetailRow(
                          label: 'Equipamento',
                          value: compressor.equipmentDetails,
                        ),
                        _DetailRow(
                          label: 'Notas',
                          value: compressor.notes,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.count,
    required this.loading,
    required this.onRefresh,
  });

  final int count;
  final bool loading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Compressores',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Todos os equipamentos registados na empresa.',
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: AppColors.orange.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            '$count compressores',
            style: const TextStyle(
              color: AppColors.orange,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: loading ? null : onRefresh,
          tooltip: 'Atualizar',
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }
}

class _SearchToolbar extends StatelessWidget {
  const _SearchToolbar({
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
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText:
                    'Pesquisar por marca, modelo, série, responsável ou distrito…',
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
              '$count resultados',
              style: const TextStyle(fontWeight: FontWeight.w700),
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
  });

  final Compressor compressor;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
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
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.air_rounded,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 18,
                      runSpacing: 7,
                      children: [
                        if (compressor.serialNumber.isNotEmpty)
                          _InlineDetail(
                            icon: Icons.numbers_rounded,
                            value: 'S/N ${compressor.serialNumber}',
                          ),
                        if (compressor.district.isNotEmpty)
                          _InlineDetail(
                            icon: Icons.location_on_outlined,
                            value: compressor.district,
                          ),
                        if (compressor.nextMaintenanceDate != null)
                          _InlineDetail(
                            icon: Icons.event_outlined,
                            value:
                                'Próxima: ${_formatDate(compressor.nextMaintenanceDate)}',
                          ),
                        if (compressor.responsible.isNotEmpty)
                          _InlineDetail(
                            icon: Icons.person_outline_rounded,
                            value: compressor.responsible,
                          ),
                          if (compressor.clientName.isNotEmpty)
  _InlineDetail(
    icon: Icons.business_rounded,
    value: compressor.clientName,
  ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
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
          size: 15,
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

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<_DetailRow> children;

  @override
  Widget build(BuildContext context) {
    final visibleChildren = children
        .where((child) => child.value.trim().isNotEmpty)
        .toList();

    if (visibleChildren.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onRefresh,
  });

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.air_rounded,
            size: 56,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 14),
          Text(
            'Nenhum compressor encontrado',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  const _NoResultsState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Nenhum resultado para esta pesquisa.'),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 54,
            color: Colors.red,
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return '';

  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day/$month/${date.year}';
}

String _numberWithUnit(num? value, String unit) {
  if (value == null) return '';

  final formatted = value % 1 == 0
      ? value.toInt().toString()
      : value.toStringAsFixed(1).replaceAll('.', ',');

  return '$formatted $unit';
}