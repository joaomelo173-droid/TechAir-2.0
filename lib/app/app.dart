import 'package:flutter/material.dart';

import '../features/authentication/presentation/pages/auth_gate.dart';
import 'theme/techair_theme.dart';

class TechAirApp extends StatelessWidget {
  const TechAirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechAir 2.0',
      debugShowCheckedModeBanner: false,
      theme: TechAirTheme.dark,
      home: AuthGate(),
    );
  }
}
