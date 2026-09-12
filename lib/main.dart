import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'firebase_options.dart';

// Load environment variables before starting the app
// This is used to configure the LiveKit sandbox ID for development
// The file is optional; without it the app connects to a default agent (see app_ctrl.dart)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env', isOptional: true);
  // Powers the live admin panel (SK Sefa AI / Skendrik admin) - remote on/off
  // switch and broadcast messages, synced instantly to every install.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const VoiceAssistantApp());
}
