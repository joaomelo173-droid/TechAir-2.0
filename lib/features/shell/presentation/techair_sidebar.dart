import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'navigation_item.dart';
import '../../../core/widgets/techair_icon.dart';

class TechAirSidebar extends StatelessWidget {
  const TechAirSidebar({
    required this.selected,
    required this.onSelected,
    required this.user,
    this.compact = false,
    super.key,
  });

  final AppSection selected;
  final ValueChanged<AppSection> onSelected;
  final User user;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 92 : 284,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 16 : 22,
                20,
                compact ? 16 : 18,
                10,
              ),
              child: _Brand(compact: compact),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: navigationItems.length,
                itemBuilder: (context, index) {
                  final item = navigationItems[index];

                  final previousGroup = index == 0
                      ? null
                      : navigationItems[index - 1].group;

                  final showGroup =
                      item.group != null && item.group != previousGroup;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showGroup && !compact)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            12,
                            18,
                            12,
                            8,
                          ),
                          child: Text(
                            item.group!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.25,
                            ),
                          ),
                        ),
                      _SidebarTile(
                        item: item,
                        selected: item.section == selected,
                        compact: compact,
                        onTap: () => onSelected(item.section),
                      ),
                    ],
                  );
                },
              ),
            ),
            _ProfileCard(
              user: user,
              compact: compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({
    required this.compact,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          compact ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Container(
          width: 54,
          height: 54,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                AppColors.orange,
                AppColors.orangeLight,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withValues(alpha: .24),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/branding/techair_badge.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'TechAir '),
                      TextSpan(
                        text: '2.0',
                        style: TextStyle(
                          color: AppColors.orange,
                        ),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'ASSISTÊNCIA TÉCNICA',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.item,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final NavigationItem item;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tile = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        gradient: selected
            ? const LinearGradient(
                colors: [
                  AppColors.orange,
                  AppColors.orangeLight,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: selected ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.orange.withValues(alpha: .23),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ]
            : null,
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        minLeadingWidth: 24,
        horizontalTitleGap: 12,
        contentPadding: EdgeInsets.symmetric(
          horizontal: compact ? 19 : 15,
          vertical: 4,
        ),
        leading: _NavigationIcon(
          section: item.section,
          fallbackIcon: item.icon,
          selected: selected,
        ),
        title: compact
            ? null
            : Text(
                item.label,
                style: TextStyle(
                  color:
                      selected ? Colors.white : AppColors.textPrimary,
                  fontWeight:
                      selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
      ),
    );

    if (compact) {
      return Tooltip(
        message: item.label,
        child: tile,
      );
    }

    return tile;
  }
}

class _NavigationIcon extends StatelessWidget {
  const _NavigationIcon({
    required this.section,
    required this.fallbackIcon,
    required this.selected,
  });

  final AppSection section;
  final IconData fallbackIcon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? Colors.white : AppColors.textSecondary;

if (section == AppSection.compressors) {
  return TechAirIcon(
    type: TechAirIconType.compressor,
    size: 24,
    color: color,
  );
}

    return Icon(
      fallbackIcon,
      color: color,
      size: 22,
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.user,
    required this.compact,
  });

  final User user;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final name = (user.displayName?.trim().isNotEmpty ?? false)
        ? user.displayName!.trim()
        : (user.email?.split('@').first ?? 'Utilizador');

    return Container(
      margin: const EdgeInsets.all(14),
      padding: EdgeInsets.all(compact ? 8 : 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.orange,
            child: Text(
              _initials(name),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Sessão ativa',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.more_horiz_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  String _initials(String value) {
    final parts = value
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'U';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}