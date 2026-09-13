import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'firebase_options.dart';

// Load environment variables before starting the app
// This is used to configure the LiveKit sandbox ID for development
// The file is optional; without it the app connects to a default agent (see app_ctrl.dart)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  try {
    await dotenv.load(fileName: 'assets/.env', isOptional: true);
  } catch (_) {
    // .env is optional, ignore failures loading it
  }

  try {
    // Powers the live admin panel (SK Sefa AI / Skendrik admin) - remote on/off
    // switch and broadcast messages, synced instantly to every install.
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    runApp(const VoiceAssistantApp());
  } catch (e, st) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('STARTUP ERROR: $e\n$st');
    }
    runApp(_StartupErrorApp(error: e.toString()));
  }
}

/// Shown instead of a black screen if startup fails (e.g. Firebase not
/// reachable, bad config) - so the real error is visible instead of a crash.
class _StartupErrorApp extends StatelessWidget {
  final String error;
  const _StartupErrorApp({required this.error});

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('startup failed', style: TextStyle(color: Color(0xFF00FF41), fontSize: 18)),
                  const SizedBox(height: 16),
                  Text(error, style: const TextStyle(color: Colors.white, fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
      );
}
