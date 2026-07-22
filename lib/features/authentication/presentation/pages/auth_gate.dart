import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/firebase/firebase_status.dart';
import '../../../shell/presentation/app_shell.dart';
import '../../data/auth_service.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  AuthGate({super.key}) : _authService = AuthService();

  final AuthService _authService;

  @override
  Widget build(BuildContext context) {
    if (!FirebaseStatus.isReady) {
      return const _FirebaseUnavailablePage();
    }

    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _FirebaseUnavailablePage(message: snapshot.error.toString());
        }

        final user = snapshot.data;
        if (user == null) return LoginPage(authService: _authService);

        return AppShell(authService: _authService, user: user);
      },
    );
  }
}

class _FirebaseUnavailablePage extends StatelessWidget {
  const _FirebaseUnavailablePage({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 56),
                const SizedBox(height: 18),
                const Text(
                  'Firebase não está configurado',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Confirma a configuração da plataforma e reinicia a aplicação.',
                  textAlign: TextAlign.center,
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  SelectableText(
                    message!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
