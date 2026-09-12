import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/admin_control.dart';

/// Everything here writes straight to Firestore, so changes go "live" to every
/// installed copy of the app instantly - no rebuild, no republish needed.
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final _broadcastController = TextEditingController();
  final _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminControl>();
    _broadcastController.text = admin.broadcast;

    return Scaffold(
      appBar: AppBar(title: Text('Admin Panel - ${admin.adminName}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('App Enabled'),
              subtitle: const Text('Turn OFF to show a maintenance screen to every user, live.'),
              value: admin.appEnabled,
              onChanged: (val) => admin.setAppEnabled(val),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Broadcast Message', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _broadcastController,
                    decoration: const InputDecoration(
                      hintText: 'Message shown as a banner to every user (blank = hide)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => admin.setBroadcast(_broadcastController.text.trim()),
                      child: const Text('Send / Update'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Change Admin PIN', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'New PIN',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_pinController.text.trim().isNotEmpty) {
                          admin.setAdminPin(_pinController.text.trim());
                          _pinController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('PIN updated')),
                          );
                        }
                      },
                      child: const Text('Update PIN'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Support number: ${admin.supportNumber}', textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text(
            'More admin controls (user list, analytics, etc.) can be added here later.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
