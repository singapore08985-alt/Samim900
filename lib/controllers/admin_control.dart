import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Live remote control for the app, backed by Firestore.
/// Document: config/live_control
/// Fields:
///   appEnabled   (bool)   - master switch, if false all users see a maintenance screen
///   broadcast    (string) - message shown as a banner to every user, empty = no banner
///   adminPin     (string) - PIN required to open the admin panel
class AdminControl extends ChangeNotifier {
  static const String _adminName = 'Skendrik';
  static const String _supportNumber = '+91 92391 82739';

  bool appEnabled = true;
  String broadcast = '';
  String broadcastType = 'info'; // info, warning, urgent
  String adminPin = '0000'; // change this from the admin panel after first login
  String youtubeUrl = '';
  String telegramUrl = '';
  String logoUrl = ''; // if set, shown instead of the built-in logo, live for everyone
  bool codingModeEnabled = false;
  String geminiApiKey = '';

  String get adminName => _adminName;
  String get supportNumber => _supportNumber;

  DocumentReference<Map<String, dynamic>> get _doc =>
      FirebaseFirestore.instance.collection('config').doc('live_control');

  /// Call once at app startup. Creates the control doc if it doesn't exist yet,
  /// then listens for live changes made from the admin panel (any device).
  void start() {
    _doc.get().then((snap) {
      if (!snap.exists) {
        _doc.set({
          'appEnabled': true,
          'broadcast': '',
          'broadcastType': 'info',
          'adminPin': '0000',
          'youtubeUrl': '',
          'telegramUrl': '',
          'logoUrl': '',
          'codingModeEnabled': false,
          'geminiApiKey': '',
        });
      }
    });

    _doc.snapshots().listen((snap) {
      final data = snap.data();
      if (data == null) return;
      appEnabled = data['appEnabled'] as bool? ?? true;
      broadcast = data['broadcast'] as String? ?? '';
      broadcastType = data['broadcastType'] as String? ?? 'info';
      adminPin = data['adminPin'] as String? ?? adminPin;
      youtubeUrl = data['youtubeUrl'] as String? ?? '';
      telegramUrl = data['telegramUrl'] as String? ?? '';
      logoUrl = data['logoUrl'] as String? ?? '';
      codingModeEnabled = data['codingModeEnabled'] as bool? ?? false;
      geminiApiKey = data['geminiApiKey'] as String? ?? '';
      notifyListeners();
    });
  }

  Future<void> setAppEnabled(bool value) => _doc.update({'appEnabled': value});

  Future<void> setBroadcast(String message, {String type = 'info'}) =>
      _doc.update({'broadcast': message, 'broadcastType': type});

  Future<void> clearBroadcast() => _doc.update({'broadcast': '', 'broadcastType': 'info'});

  Future<void> setAdminPin(String pin) => _doc.update({'adminPin': pin});

  Future<void> setLinks({String? youtube, String? telegram}) => _doc.update({
        if (youtube != null) 'youtubeUrl': youtube,
        if (telegram != null) 'telegramUrl': telegram,
      });

  Future<void> setLogoUrl(String url) => _doc.update({'logoUrl': url});

  Future<void> setCodingMode({required bool enabled, required String apiKey}) =>
      _doc.update({'codingModeEnabled': enabled, 'geminiApiKey': apiKey});

  bool checkPin(String input) => input == adminPin;
}
