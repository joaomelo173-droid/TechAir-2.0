import 'package:flutter/material.dart';

import '../../domain/entities/workshop_job.dart';
import '../controllers/workshop_job_controller.dart';
import 'workshop_detail_page.dart';

class WorkshopPage extends StatefulWidget {
  const WorkshopPage({super.key});

  @override
  State<WorkshopPage> createState() => _WorkshopPageState();
}

class _WorkshopPageState extends State<WorkshopPage> {
  static const String companyId = 'extincendios';
  static const String allStatuses = 'Todos';

  final WorkshopJobController _controller = WorkshopJobController();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedStatus = allStatuses;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<WorkshopJob>>(
        stream: _controller.watchWorkshopJobs(
          companyId: companyId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _ErrorState(
              error: snapshot.error,
            );
          }

          final jobs = snapshot.data ?? [];

          final statuses = jobs
              .map((job) => job.statusLabel.trim())
              .where((status) => status.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

          final filteredJobs = jobs.where((job) {
            final query = _searchQuery.trim().toLowerCase();

            final matchesSearch = query.isEmpty ||
                job.jobNumber.toLowerCase().contains(query) ||
                job.clientName.toLowerCase().contains(query) ||
                job.compressorName.toLowerCase().contains(query);

            final matchesStatus = _selectedStatus == allStatuses ||
                job.statusLabel == _selectedStatus;

            return matchesSearch && matchesStatus;
          }).toList();

          return SafeArea(
            child: Column(
              children: [
                _WorkshopHeader(
                  totalJobs: jobs.length,
                  visibleJobs: filteredJobs.length,
                  onCreateJob: _showCreateJobMessage,
                ),
                _FiltersBar(
                  searchController: _searchController,
                  searchQuery: _searchQuery,
                  selectedStatus: _selectedStatus,
                  statuses: statuses,
                  onSearchChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onClearSearch: () {
                    _searchController.clear();

                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  onStatusChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
                Expanded(
                  child: _buildContent(
                    jobs: jobs,
                    filteredJobs: filteredJobs,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent({
    required List<WorkshopJob> jobs,
    required List<WorkshopJob> filteredJobs,
  }) {
    if (jobs.isEmpty) {
      return const _EmptyState(
        icon: Icons.engineering_outlined,
        title: 'Ainda não existem obras',
        message:
            'As obras criadas através da receção irão aparecer nesta página.',
      );
    }

    if (filteredJobs.isEmpty) {
      return const _EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Nenhuma obra encontrada',
        message: 'Altera a pesquisa ou seleciona outro estado.',
      );
    }

    return Scrollbar(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        itemCount: filteredJobs.length,
        separatorBuilder: (context, index) {
          return const SizedBox(height: 12);
        },
        itemBuilder: (context, index) {
          final job = filteredJobs[index];

          return _WorkshopJobCard(
            job: job,
            onTap: () {
              _openWorkshopJob(job);
            },
          );
        },
      ),
    );
  }

  void _showCreateJobMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'As novas obras são criadas automaticamente através da receção.',
        ),
      ),
    );
  }

  void _openWorkshopJob(WorkshopJob job) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkshopDetailPage(
          job: job,
        ),
      ),
    );
  }
}

class _WorkshopHeader extends StatelessWidget {
  const _WorkshopHeader({
    required this.totalJobs,
    required this.visibleJobs,
    required this.onCreateJob,
  });

  final int totalJobs;
  final int visibleJobs;
  final VoidCallback onCreateJob;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.engineering_rounded,
              color: theme.colorScheme.onPrimaryContainer,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Obras',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _buildCounterText(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: onCreateJob,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nova obra'),
          ),
        ],
      ),
    );
  }

  String _buildCounterText() {
    if (totalJobs == 0) {
      return 'Nenhuma obra registada';
    }

    if (visibleJobs == totalJobs) {
      return totalJobs == 1
          ? '1 obra registada'
          : '$totalJobs obras registadas';
    }

    return '$visibleJobs de $totalJobs obras visíveis';
  }
}

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({
    required this.searchController,
    required this.searchQuery,
    required this.selectedStatus,
    required this.statuses,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onStatusChanged,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final String selectedStatus;
  final List<String> statuses;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 760;

          final searchField = TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Pesquisar por obra, cliente ou compressor...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpar pesquisa',
                      onPressed: onClearSearch,
                      icon: const Icon(Icons.close_rounded),
                    ),
              border: const OutlineInputBorder(),
            ),
          );

          final statusFilter = DropdownButtonFormField<String>(
            initialValue: selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Estado',
              prefixIcon: Icon(Icons.filter_alt_outlined),
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: _WorkshopPageState.allStatuses,
                child: Text('Todos os estados'),
              ),
              ...statuses.map(
                (status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                },
              ),
            ],
            onChanged: onStatusChanged,
          );

          if (isCompact) {
            return Column(
              children: [
                searchField,
                const SizedBox(height: 12),
                statusFilter,
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: searchField,
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 260,
                child: statusFilter,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WorkshopJobCard extends StatelessWidget {
  const _WorkshopJobCard({
    required this.job,
    required this.onTap,
  });

  final WorkshopJob job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusStyle = _WorkshopStatusStyle.fromLabel(
      context,
      job.statusLabel,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.precision_manufacturing_rounded,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            job.jobNumber,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _StatusBadge(
                          label: job.statusLabel,
                          style: statusStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _InformationLine(
                      icon: Icons.business_outlined,
                      text: job.clientName,
                    ),
                    const SizedBox(height: 6),
                    _InformationLine(
                      icon: Icons.settings_outlined,
                      text: job.compressorName,
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
      ),
    );
  }
}

class _InformationLine extends StatelessWidget {
  const _InformationLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text.isEmpty ? 'Não definido' : text,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.style,
  });

  final String label;
  final _WorkshopStatusStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: style.foregroundColor.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            style.icon,
            size: 14,
            color: style.foregroundColor,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: style.foregroundColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkshopStatusStyle {
  const _WorkshopStatusStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;

  factory _WorkshopStatusStyle.fromLabel(
    BuildContext context,
    String label,
  ) {
    final normalizedLabel = label.toLowerCase();
    final colorScheme = Theme.of(context).colorScheme;

    if (normalizedLabel.contains('conclu') ||
        normalizedLabel.contains('entreg')) {
      return const _WorkshopStatusStyle(
        backgroundColor: Color(0xFFE8F5E9),
        foregroundColor: Color(0xFF1B5E20),
        icon: Icons.check_circle_outline_rounded,
      );
    }

    if (normalizedLabel.contains('repara') ||
        normalizedLabel.contains('execu') ||
        normalizedLabel.contains('curso')) {
      return const _WorkshopStatusStyle(
        backgroundColor: Color(0xFFE3F2FD),
        foregroundColor: Color(0xFF0D47A1),
        icon: Icons.build_circle_outlined,
      );
    }

    if (normalizedLabel.contains('peça') ||
        normalizedLabel.contains('peca') ||
        normalizedLabel.contains('cliente') ||
        normalizedLabel.contains('fornecedor') ||
        normalizedLabel.contains('aguarda')) {
      return const _WorkshopStatusStyle(
        backgroundColor: Color(0xFFFFF3E0),
        foregroundColor: Color(0xFFE65100),
        icon: Icons.schedule_rounded,
      );
    }

    if (normalizedLabel.contains('teste')) {
      return const _WorkshopStatusStyle(
        backgroundColor: Color(0xFFF3E5F5),
        foregroundColor: Color(0xFF6A1B9A),
        icon: Icons.science_outlined,
      );
    }

    if (normalizedLabel.contains('cancel')) {
      return const _WorkshopStatusStyle(
        backgroundColor: Color(0xFFFFEBEE),
        foregroundColor: Color(0xFFB71C1C),
        icon: Icons.cancel_outlined,
      );
    }

    return _WorkshopStatusStyle(
      backgroundColor: colorScheme.surfaceContainerHighest,
      foregroundColor: colorScheme.onSurfaceVariant,
      icon: Icons.info_outline_rounded,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

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
              icon,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.error,
  });

  final Object? error;

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
              Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 18),
            Text(
              'Erro ao carregar as obras',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
