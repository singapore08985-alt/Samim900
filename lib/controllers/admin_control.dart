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
  String adminPin = '0000'; // change this from the admin panel after first login

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
          'adminPin': '0000',
        });
      }
    });

    _doc.snapshots().listen((snap) {
      final data = snap.data();
      if (data == null) return;
      appEnabled = data['appEnabled'] as bool? ?? true;
      broadcast = data['broadcast'] as String? ?? '';
      adminPin = data['adminPin'] as String? ?? adminPin;
      notifyListeners();
    });
  }

  Future<void> setAppEnabled(bool value) => _doc.update({'appEnabled': value});

  Future<void> setBroadcast(String message) => _doc.update({'broadcast': message});

  Future<void> setAdminPin(String pin) => _doc.update({'adminPin': pin});

  bool checkPin(String input) => input == adminPin;
}
