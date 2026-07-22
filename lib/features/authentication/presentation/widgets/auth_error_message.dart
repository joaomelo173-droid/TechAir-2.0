import 'package:firebase_auth/firebase_auth.dart';

String authErrorMessage(Object error) {
  if (error is! FirebaseAuthException) {
    return 'Não foi possível concluir a operação. Tenta novamente.';
  }

  return switch (error.code) {
    'invalid-email' => 'O endereço de email não é válido.',
    'user-disabled' => 'Esta conta foi desativada.',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' =>
      'Email ou palavra-passe incorretos.',
    'too-many-requests' =>
      'Foram feitas demasiadas tentativas. Aguarda alguns minutos.',
    'network-request-failed' =>
      'Não foi possível ligar ao servidor. Verifica a internet.',
    'operation-not-allowed' =>
      'O login por email e palavra-passe não está ativo no Firebase.',
    _ => error.message ?? 'Ocorreu um erro de autenticação.',
  };
}
