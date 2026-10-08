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
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDSABOuVukqyRg9rTukvTShmhNNiH-y-qU',
    appId: '1:794943856604:web:8b83e06404caae8454b919',
    messagingSenderId: '794943856604',
    projectId: 'pdm-midl',
    authDomain: 'pdm-midl.firebaseapp.com',
    storageBucket: 'pdm-midl.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDSABOuVukqyRg9rTukvTShmhNNiH-y-qU',
    appId: '1:794943856604:web:8b83e06404caae8454b919',
    messagingSenderId: '794943856604',
    projectId: 'pdm-midl',
    authDomain: 'pdm-midl.firebaseapp.com',
    storageBucket: 'pdm-midl.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDSABOuVukqyRg9rTukvTShmhNNiH-y-qU',
    appId: '1:794943856604:web:8b83e06404caae8454b919',
    messagingSenderId: '794943856604',
    projectId: 'pdm-midl',
    authDomain: 'pdm-midl.firebaseapp.com',
    storageBucket: 'pdm-midl.firebasestorage.app',
  );
}