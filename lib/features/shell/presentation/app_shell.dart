import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../compressors/presentation/pages/all_compressors_page.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/feature_placeholder.dart';
import '../../authentication/data/auth_service.dart';
import '../../dashboard/presentation/dashboard_page.dart';
import '../../clients/presentation/pages/clients_page.dart';
import 'navigation_item.dart';
import 'techair_sidebar.dart';
import '../../interventions/presentation/pages/interventions_page.dart';
import '../../receptions/presentation/pages/receptions_page.dart';
import '../../workshop/presentation/pages/workshop_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.authService,
    required this.user,
  });

  final AuthService authService;
  final User user;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppSection _selected = AppSection.dashboard;

  void _select(AppSection section) {
    setState(() => _selected = section);
    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 760;
        final compact = constraints.maxWidth >= 760 && constraints.maxWidth < 1060;

        return Scaffold(
          drawer: mobile
              ? Drawer(
                  width: 294,
                  child: TechAirSidebar(selected: _selected, onSelected: _select, user: widget.user),
                )
              : null,
          appBar: mobile
              ? _MobileAppBar(
                  authService: widget.authService,
                  user: widget.user,
                )
              : null,
          body: Row(
            children: [
              if (!mobile)
                TechAirSidebar(
                  selected: _selected,
                  onSelected: _select,
                  user: widget.user,
                  compact: compact,
                ),
              Expanded(
                child: Column(
                  children: [
                    if (!mobile)
                      _DesktopTopBar(
                        authService: widget.authService,
                        user: widget.user,
                      ),
                    Expanded(child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: KeyedSubtree(
                        key: ValueKey(_selected),
                        child: _pageFor(_selected),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: mobile
              ? NavigationBar(
                  selectedIndex: _mobileIndex(_selected),
                  onDestinationSelected: (index) {
                    final sections = [
                      AppSection.dashboard,
                      AppSection.clients,
                      AppSection.compressors,
                      AppSection.maintenance,
                    ];
                    _select(sections[index]);
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.grid_view_rounded),
                      label: 'Dashboard',
                    ),
                    NavigationDestination(icon: Icon(Icons.groups_rounded), label: 'Clientes'),
                    NavigationDestination(
                      icon: Icon(Icons.precision_manufacturing_rounded),
                      label: 'Compressores',
                    ),
                    NavigationDestination(icon: Icon(Icons.handyman_rounded), label: 'Manutenções'),
                  ],
                )
              : null,
        );
      },
    );
  }

  int _mobileIndex(AppSection section) {
    return switch (section) {
      AppSection.clients => 1,
      AppSection.compressors => 2,
      AppSection.maintenance => 3,
      _ => 0,
    };
  }

  Widget _pageFor(AppSection section) {
  return switch (section) {
    AppSection.dashboard => const DashboardPage(),

    AppSection.reception => const ReceptionsPage(),

    AppSection.clients => const ClientsPage(),

    AppSection.compressors =>
      const AllCompressorsPage(),

    AppSection.interventions =>
      const InterventionsPage(),

    AppSection.maintenance =>
      const FeaturePlaceholder(
        title: 'Manutenções',
        description: 'Gestão de manutenções.',
        icon: Icons.handyman_rounded,
      ),

    AppSection.modernizations =>
      const FeaturePlaceholder(
        title: 'Modernizações',
        description:
            'Planeamento, trabalhos realizados, próxima intervenção e relatório PDF.',
        icon: Icons.settings_suggest_rounded,
      ),

    AppSection.breakdowns =>
      const FeaturePlaceholder(
        title: 'Avarias',
        description:
            'Prioridade, diagnóstico, trabalhos realizados e acompanhamento do estado.',
        icon: Icons.warning_amber_rounded,
      ),

    AppSection.works => const WorkshopPage(),
        

    AppSection.reports =>
      const FeaturePlaceholder(
        title: 'Relatórios',
        description:
            'Arquivo central dos PDFs emitidos, pesquisa, impressão e partilha.',
        icon: Icons.analytics_rounded,
      ),

    AppSection.settings =>
      const FeaturePlaceholder(
        title: 'Configurações',
        description:
            'Empresa, utilizadores, permissões, numeração, sincronização e identidade visual.',
        icon: Icons.settings_rounded,
      ),
  };
}
}

class _DesktopTopBar extends StatelessWidget {
  const _DesktopTopBar({
    required this.authService,
    required this.user,
  });

  final AuthService authService;
  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 320,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Pesquisar...',
                prefixIcon: Icon(Icons.search_rounded),
                isDense: true,
              ),
            ),
          ),
          const Spacer(),
          const Icon(Icons.business_rounded, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 8),
          const Text('Extincêndios — Equipamentos de Proteção'),
          const SizedBox(width: 18),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          PopupMenuButton<String>(
            tooltip: 'Conta',
            onSelected: (value) async {
              if (value == 'logout') await authService.signOut();
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Text(user.email ?? 'Utilizador'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 20),
                    SizedBox(width: 10),
                    Text('Terminar sessão'),
                  ],
                ),
              ),
            ],
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.surfaceElevated,
              child: Text(_initials(user)),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(User user) {
    final source = (user.displayName?.trim().isNotEmpty ?? false)
        ? user.displayName!.trim()
        : (user.email ?? 'U');
    final parts = source.split(RegExp(r'\s+|@')).where((part) => part.isNotEmpty).toList();
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }
}

class _MobileAppBar extends AppBar {
  _MobileAppBar({
    required AuthService authService,
    required User user,
  }) : super(
          titleSpacing: 0,
          title: const Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'TechAir '),
                TextSpan(
                  text: '2.0',
                  style: TextStyle(color: AppColors.orange),
                ),
              ],
            ),
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            PopupMenuButton<String>(
              tooltip: 'Conta',
              onSelected: (value) async {
                if (value == 'logout') await authService.signOut();
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Text(user.email ?? 'Utilizador'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, size: 20),
                      SizedBox(width: 10),
                      Text('Terminar sessão'),
                    ],
                  ),
                ),
              ],
              icon: const Icon(Icons.account_circle_outlined),
            ),
            const SizedBox(width: 6),
          ],
        );
}
