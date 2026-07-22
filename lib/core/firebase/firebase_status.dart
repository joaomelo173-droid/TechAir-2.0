import 'package:firebase_core/firebase_core.dart';

class FirebaseStatus {
  const FirebaseStatus._();

  static bool get isReady => Firebase.apps.isNotEmpty;
}
