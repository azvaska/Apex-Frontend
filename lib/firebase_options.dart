import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      default:
        return android;
    }
  }

  static FirebaseOptions android = FirebaseOptions(
    apiKey: _firebaseEnv('FIREBASE_API_KEY'),
    appId: _firebaseEnv('FIREBASE_ANDROID_APP_ID'),
    messagingSenderId: _firebaseEnv('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _firebaseEnv('FIREBASE_PROJECT_ID'),
    storageBucket: _firebaseEnv('FIREBASE_STORAGE_BUCKET'),
  );

  static FirebaseOptions ios = FirebaseOptions(
    apiKey: _firebaseEnv('FIREBASE_API_KEY'),
    appId: _firebaseEnv('FIREBASE_IOS_APP_ID'),
    messagingSenderId: _firebaseEnv('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _firebaseEnv('FIREBASE_PROJECT_ID'),
    storageBucket: _firebaseEnv('FIREBASE_STORAGE_BUCKET'),
    iosBundleId: _firebaseEnv('FIREBASE_IOS_BUNDLE_ID'),
  );
}

String _firebaseEnv(String key) {
  return dotenv.env[key] ?? '';
}
