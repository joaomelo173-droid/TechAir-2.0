import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'widgets/stat_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1240 ? 5 : width >= 780 ? 3 : 2;

        return SingleChildScrollView(
          padding: EdgeInsets.all(width < 700 ? 16 : 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(isMobile: width < 700),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: width < 560 ? 1.12 : 1.28,
                children: const [
                  StatCard(
                    value: '12',
                    label: 'Manutenções',
                    caption: 'Agendadas para hoje',
                    icon: Icons.handyman_rounded,
                    accent: AppColors.blue,
                  ),
                  StatCard(
                    value: '3',
                    label: 'Avarias',
                    caption: 'Processos em aberto',
                    icon: Icons.warning_amber_rounded,
                    accent: AppColors.red,
                  ),
                  StatCard(
                    value: '5',
                    label: 'Modernizações',
                    caption: 'Trabalhos em curso',
                    icon: Icons.settings_suggest_rounded,
                    accent: AppColors.orange,
                  ),
                  StatCard(
                    value: '2',
                    label: 'Receções',
                    caption: 'Entradas de hoje',
                    icon: Icons.move_to_inbox_rounded,
                    accent: AppColors.purple,
                  ),
                  StatCard(
                    value: '18',
                    label: 'Relatórios',
                    caption: 'Documentos emitidos',
                    icon: Icons.task_alt_rounded,
                    accent: AppColors.green,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (width >= 940)
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _RecentActivity()),
                    SizedBox(width: 18),
                    Expanded(flex: 2, child: _OpenBreakdowns()),
                  ],
                )
              else
                const Column(
                  children: [
                    _RecentActivity(),
                    SizedBox(height: 18),
                    _OpenBreakdowns(),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF122A3E), Color(0xFF0B1D2B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bom trabalho, João 👋',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Aqui tens a visão geral da atividade técnica de hoje.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (!isMobile)
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded, size: 19),
              label: const Text('Nova intervenção'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Atividade recente',
      subtitle: 'Últimos documentos técnicos',
      child: Column(
        children: [
          ...[
            ('MAN-2026-0004', 'Bauer Junior II', 'Extincêndios', 'Concluída'),
            ('MAN-2026-0003', 'Bauer Mariner 200', 'Mar Norte', 'Concluída'),
            ('MAN-2026-0002', 'Bauer K14', 'ProtecFire', 'Em curso'),
          ].map(
            (row) => _ActivityRow(
              number: row.$1,
              equipment: row.$2,
              client: row.$3,
              status: row.$4,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenBreakdowns extends StatelessWidget {
  const _OpenBreakdowns();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Avarias em aberto',
      subtitle: 'Requerem acompanhamento',
      child: Column(
        children: [
          ...[
            ('AVA-2026-0004', 'Bauer Junior II', 'Extincêndios'),
            ('AVA-2026-0003', 'Bauer Mariner 200', 'Mar Norte'),
            ('AVA-2026-0002', 'Bauer K14', 'ProtecFire'),
          ].map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.red.withOpacity(.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(row.$1, style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text(
                          '${row.$2} · ${row.$3}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 3),
                      Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('Ver tudo')),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.number,
    required this.equipment,
    required this.client,
    required this.status,
  });

  final String number;
  final String equipment;
  final String client;
  final String status;

  @override
  Widget build(BuildContext context) {
    final complete = status == 'Concluída';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.handyman_rounded, color: AppColors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(number, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                  '$equipment · $client',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: (complete ? AppColors.green : AppColors.orange).withOpacity(.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: complete ? AppColors.green : AppColors.orange,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
