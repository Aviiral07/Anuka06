import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'This MVP supports Android and iOS. Replace firebase_options.dart '
          'with your generated FlutterFire config before running.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA39JNKyckTBeXoRQC1rG6CwsV91iXVgJ8',
    appId: '1:581723574214:android:ebb36cb8bb6d62655cecc7',
    messagingSenderId: '581723574214',
    projectId: 'anuka-eeec5',
    storageBucket: 'anuka-eeec5.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAvw76gEhD2zBnqzQ8MLVeb17R_jL79Ra0',
    appId: '1:581723574214:ios:50c1f3bc12ee319d5cecc7',
    messagingSenderId: '581723574214',
    projectId: 'anuka-eeec5',
    storageBucket: 'anuka-eeec5.firebasestorage.app',
    iosBundleId: 'com.anuka.app',
  );
}
