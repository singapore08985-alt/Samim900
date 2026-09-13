// ⚠️ PLACEHOLDER FILE — DO NOT USE AS-IS.
//
// Run this once from Termux, inside the project folder, to replace this
// entire file with your real project's config automatically:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// It will ask you to log in to Firebase and pick/create a project, then
// overwrite this file for real. Full steps are in the message where this
// project was set up.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'dart:io' show Platform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isAndroid) {
      throw UnsupportedError(
        'firebase_options.dart is a placeholder. Run `flutterfire configure` first.',
      );
    }
    throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
  }
}
