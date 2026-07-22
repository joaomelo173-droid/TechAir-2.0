import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/client.dart';

class ClientCard extends StatelessWidget {
  const ClientCard({
    super.key,
    required this.client,
    required this.onOpenDetails,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenCompressors,
  });

  final Client client;
  final VoidCallback onOpenDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onOpenCompressors;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpenDetails,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 700;

              if (compact) {
                return _CompactContent(
                  client: client,
                  initials: _initials(client.name),
                  onEdit: onEdit,
                  onDelete: onDelete,
                  onOpenCompressors: onOpenCompressors,
                );
              }

              return _DesktopContent(
                client: client,
                initials: _initials(client.name),
                onEdit: onEdit,
                onDelete: onDelete,
                onOpenCompressors: onOpenCompressors,
              );
            },
          ),
        ),
      ),
    );
  }

  String _initials(String value) {
    final words = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) return '?';

    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }

    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }
}

class _DesktopContent extends StatelessWidget {
  const _DesktopContent({
    required this.client,
    required this.initials,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenCompressors,
  });

  final Client client;
  final String initials;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onOpenCompressors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ClientAvatar(initials: initials),
        const SizedBox(width: 16),
        Expanded(
          child: _ClientInformation(client: client),
        ),
        const SizedBox(width: 14),
        _CompressorButton(
          count: client.compressorCount,
          onPressed: onOpenCompressors,
        ),
        const SizedBox(width: 4),
        _ClientMenu(
          onEdit: onEdit,
          onDelete: onDelete,
        ),
        const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
}

class _CompactContent extends StatelessWidget {
  const _CompactContent({
    required this.client,
    required this.initials,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenCompressors,
  });

  final Client client;
  final String initials;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onOpenCompressors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _ClientAvatar(initials: initials),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                client.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            _ClientMenu(
              onEdit: onEdit,
              onDelete: onDelete,
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ClientInformation(
          client: client,
          showName: false,
        ),
        const SizedBox(height: 14),
        _CompressorButton(
          count: client.compressorCount,
          onPressed: onOpenCompressors,
          expanded: true,
        ),
      ],
    );
  }
}

class _ClientAvatar extends StatelessWidget {
  const _ClientAvatar({
    required this.initials,
  });

  final String initials;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 25,
      backgroundColor: AppColors.orange.withValues(alpha: .12),
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.orange,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ClientInformation extends StatelessWidget {
  const _ClientInformation({
    required this.client,
    this.showName = true,
  });

  final Client client;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showName) ...[
          Text(
            client.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 7),
        ],
        Wrap(
          spacing: 16,
          runSpacing: 7,
          children: [
            _Detail(
              icon: Icons.person_outline_rounded,
              value: client.responsible,
            ),
            _Detail(
              icon: Icons.phone_outlined,
              value: client.phone,
            ),
            _Detail(
              icon: Icons.mail_outline_rounded,
              value: client.email,
            ),
            _Detail(
              icon: Icons.location_on_outlined,
              value: client.locationLabel,
            ),
          ].where((item) => item.value.isNotEmpty).toList(),
        ),
      ],
    );
  }
}

class _CompressorButton extends StatelessWidget {
  const _CompressorButton({
    required this.count,
    required this.onPressed,
    this.expanded = false,
  });

  final int count;
  final VoidCallback onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final content = InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: expanded ? double.infinity : null,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment:
              expanded ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            const Icon(
              Icons.precision_manufacturing_rounded,
              size: 18,
              color: AppColors.orange,
            ),
            const SizedBox(width: 8),
            Text(
              '$count',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              count == 1 ? 'compressor' : 'compressores',
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );

    return Tooltip(
      message: 'Abrir compressores deste cliente',
      child: content,
    );
  }
}

class _ClientMenu extends StatelessWidget {
  const _ClientMenu({
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Opções',
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined),
              SizedBox(width: 10),
              Text('Editar'),
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
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({
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
        Flexible(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}