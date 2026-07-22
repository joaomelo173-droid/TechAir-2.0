import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/repositories/firestore_reception_repository.dart';
import '../../data/services/firebase_reception_photo_storage.dart';
import '../../domain/entities/reception.dart';
import '../controllers/reception_controller.dart';
import 'new_reception_page.dart';

class ReceptionsPage extends StatefulWidget {
  const ReceptionsPage({super.key});

  @override
  State<ReceptionsPage> createState() => _ReceptionsPageState();
}

class _ReceptionsPageState extends State<ReceptionsPage> {
  static const String _companyId = 'extincendios';

  final TextEditingController _searchController = TextEditingController();

  late final ReceptionController _receptionController;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _receptionController = ReceptionController(
      repository: FirestoreReceptionRepository(),
      photoStorage: FirebaseReceptionPhotoStorage(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Reception>>(
      stream: _receptionController.watchReceptions(
        companyId: _companyId,
      ),
      builder: (context, snapshot) {
        final receptions = snapshot.data ?? const <Reception>[];

        final filteredReceptions =
            receptions.where(_matchesSearch).toList(growable: false);

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                onCreate: _openNewReception,
              ),
              const SizedBox(height: 22),
              _Toolbar(
                controller: _searchController,
                count: filteredReceptions.length,
                onSearch: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
                onRefresh: _refresh,
              ),
              const SizedBox(height: 18),
              Expanded(
                child: _buildContent(
                  snapshot: snapshot,
                  receptions: filteredReceptions,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent({
    required AsyncSnapshot<List<Reception>> snapshot,
    required List<Reception> receptions,
  }) {
    if (snapshot.connectionState == ConnectionState.waiting &&
        !snapshot.hasData) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (snapshot.hasError) {
      return _ErrorState(
        message: 'Não foi possível carregar as receções.\n${snapshot.error}',
        onRetry: _refresh,
      );
    }

    if (receptions.isEmpty) {
      return _EmptyState(
        hasSearch: _searchQuery.isNotEmpty,
        onCreate: _openNewReception,
      );
    }

    return ListView.separated(
      itemCount: receptions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _ReceptionCard(
          reception: receptions[index],
        );
      },
    );
  }

  bool _matchesSearch(Reception reception) {
    if (_searchQuery.isEmpty) {
      return true;
    }

    final searchableText = [
      reception.id,
      reception.clientName,
      reception.compressorName,
      reception.receivedBy,
      reception.statusLabel,
      reception.reasonsLabel,
      reception.observations,
    ].join(' ').toLowerCase();

    return searchableText.contains(_searchQuery);
  }

  Future<void> _openNewReception() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const NewReceptionPage(),
      ),
    );

    if (!mounted) {
      return;
    }

    _refresh();
  }

  void _refresh() {
    setState(() {});
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onCreate,
  });

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Receções',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Entrada de equipamentos e criação do processo de oficina.',
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: onCreate,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Nova receção'),
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.controller,
    required this.count,
    required this.onSearch,
    required this.onRefresh,
  });

  final TextEditingController controller;
  final int count;
  final ValueChanged<String> onSearch;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.border,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onSearch,
              decoration: const InputDecoration(
                hintText: 'Pesquisar por cliente, compressor ou estado…',
                prefixIcon: Icon(
                  Icons.search_rounded,
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 14),
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
              '$count receções',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onRefresh,
            tooltip: 'Atualizar',
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceptionCard extends StatelessWidget {
  const _ReceptionCard({
    required this.reception,
  });

  final Reception reception;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.move_to_inbox_rounded,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reception.clientName.isEmpty
                              ? 'Cliente sem nome'
                              : reception.clientName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                      _StatusBadge(
                        label: reception.statusLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    reception.compressorName.isEmpty
                        ? 'Compressor sem identificação'
                        : reception.compressorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _InfoItem(
                        icon: Icons.build_outlined,
                        text: reception.reasonsLabel,
                      ),
                      _InfoItem(
                        icon: Icons.calendar_today_outlined,
                        text: _formatDate(
                          reception.receivedAt,
                        ),
                      ),
                      if (reception.receivedBy.trim().isNotEmpty)
                        _InfoItem(
                          icon: Icons.person_outline_rounded,
                          text: reception.receivedBy,
                        ),
                      if (reception.hasPhotos)
                        _InfoItem(
                          icon: Icons.photo_outlined,
                          text: '${reception.photoUrls.length} fotografia(s)',
                        ),
                    ],
                  ),
                  if (reception.observations.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      reception.observations,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} às $hour:$minute';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.onSecondaryContainer,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 17,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
      ],
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
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 14),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasSearch,
    required this.onCreate,
  });

  final bool hasSearch;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 440,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.move_to_inbox_rounded,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 14),
            Text(
              hasSearch
                  ? 'Nenhuma receção encontrada'
                  : 'Ainda não existem receções',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              hasSearch
                  ? 'Altera os termos da pesquisa.'
                  : 'Cria a primeira receção para iniciar um processo de oficina.',
              textAlign: TextAlign.center,
            ),
            if (!hasSearch) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(
                  Icons.add_rounded,
                ),
                label: const Text(
                  'Nova receção',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
