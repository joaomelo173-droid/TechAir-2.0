import 'package:flutter/material.dart';

enum AppSection {
  dashboard,
  reception,
  clients,
  compressors,
  interventions,
  maintenance,
  modernizations,
  breakdowns,
  works,
  reports,
  settings,
}

class NavigationItem {
  const NavigationItem({
    required this.section,
    required this.label,
    required this.icon,
    this.group,
  });

  final AppSection section;
  final String label;
  final IconData icon;
  final String? group;
}

const navigationItems = <NavigationItem>[
  NavigationItem(
    section: AppSection.dashboard,
    label: 'Dashboard',
    icon: Icons.dashboard_rounded,
  ),
  NavigationItem(
    section: AppSection.reception,
    label: 'Receção',
    icon: Icons.inventory_2_rounded,
    group: 'OPERAÇÕES',
  ),
  NavigationItem(
    section: AppSection.clients,
    label: 'Clientes',
    icon: Icons.business_rounded,
  ),
  NavigationItem(
    section: AppSection.compressors,
    label: 'Compressores',
    icon: Icons.air_rounded,
  ),
  NavigationItem(
    section: AppSection.interventions,
    label: 'Intervenções',
    icon: Icons.home_repair_service_rounded,
  ),
  NavigationItem(
    section: AppSection.works,
    label: 'Obras',
    icon: Icons.construction_rounded,
  ),
  NavigationItem(
    section: AppSection.reports,
    label: 'Relatórios',
    icon: Icons.description_rounded,
    group: 'GESTÃO',
  ),
  NavigationItem(
    section: AppSection.settings,
    label: 'Configurações',
    icon: Icons.tune_rounded,
    group: 'SISTEMA',
  ),
];