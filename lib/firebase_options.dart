import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => android;

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCcNjCpzd5_gbDSRGb_3Pruvl9-9lHsEG0',
    appId: '1:206492608803:android:6b11b36eeecec6745a8496',
    messagingSenderId: '206492608803',
    projectId: 'sksamimaiapp',
    storageBucket: 'sksamimaiapp.firebasestorage.app',
  );
}
