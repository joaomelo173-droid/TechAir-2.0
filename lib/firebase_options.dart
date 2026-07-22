import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;

      case TargetPlatform.windows:
        return windows;

      default:
        throw UnsupportedError('Plataforma não suportada.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA5Sh4PXTxvmPrMm2iOavzUrMM2wltty0w',
    appId: '1:278292883822:android:c7309e0204d72d9141397f',
    messagingSenderId: '278292883822',
    projectId: 'techair-2',
    storageBucket: 'techair-2.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDVyCgc9-OollCRFPvQLpdfmcB0bqgAQi0',
    appId: '1:278292883822:web:fa07de5efe1d7bc641397f',
    messagingSenderId: '278292883822',
    projectId: 'techair-2',
    authDomain: 'techair-2.firebaseapp.com',
    storageBucket: 'techair-2.firebasestorage.app',
    measurementId: 'G-ZKK1ZRNYXJ',
  );
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDVyCgc9-OollCRFPvQLpdfmcB0bqgAQi0',
    appId: '1:278292883822:web:7074dd1800bc1f1741397f',
    messagingSenderId: '278292883822',
    projectId: 'techair-2',
    authDomain: 'techair-2.firebaseapp.com',
    storageBucket: 'techair-2.firebasestorage.app',
    measurementId: 'G-T2JF85B5K8',
  );
}
