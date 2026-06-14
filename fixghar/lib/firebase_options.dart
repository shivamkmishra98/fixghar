// IMPORTANT: This file is a TEMPLATE.
// Replace ALL placeholder values below with the actual values from your
// Firebase project's google-services.json (Android) and GoogleService-Info.plist (iOS).
//
// How to generate this file automatically:
//   1. Install FlutterFire CLI:  dart pub global activate flutterfire_cli
//   2. Run from your project root: flutterfire configure
//   This will regenerate this file with your real values automatically.
//
// Manual setup:
//   1. Go to https://console.firebase.google.com/
//   2. Create or open your project
//   3. Add Android app (package: com.example.fixghar) and iOS app
//   4. Download google-services.json -> place in android/app/
//   5. Download GoogleService-Info.plist -> place in ios/Runner/
//   6. Replace the placeholder values below with values from those files.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
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
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // -----------------------------------------------------------------------
  // REPLACE these values with your Firebase project's config
  // -----------------------------------------------------------------------

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAREdmATQmAblLsbn3JROM70nIh9AEIwAk',
    appId: '1:112691437099:web:1827903bcb4bd459b6d46e',
    messagingSenderId: '112691437099',
    projectId: 'fixghar-25bb6',
    authDomain: 'fixghar-25bb6.firebaseapp.com',
    storageBucket: 'fixghar-25bb6.firebasestorage.app',
    measurementId: 'G-N6DN107XNJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey:"AIzaSyDs9qcIrsrapcfIkWndbuZOpZKnT1P2E30",
    appId: '1:112691437099:android:6e04249ef9a2615db6d46e',
    messagingSenderId:"112691437099",
    projectId:  "fixghar-25bb6",
    storageBucket:"fixghar-25bb6.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.example.fixghar',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.example.fixghar',
  );
}
