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
  final _youtubeController = TextEditingController();
  final _telegramController = TextEditingController();
  final _logoController = TextEditingController();
  final _apiKeyController = TextEditingController();
  String _selectedType = 'info';
  bool _linksLoaded = false;

  static const Map<String, Color> _typeColors = {
    'info': Colors.blue,
    'warning': Colors.amber,
    'urgent': Colors.red,
  };

  static const Map<String, String> _typeLabels = {
    'info': 'Info',
    'warning': 'Warning',
    'urgent': 'Urgent',
  };

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminControl>();
    _broadcastController.text = admin.broadcast;
    if (!_linksLoaded) {
      _youtubeController.text = admin.youtubeUrl;
      _telegramController.text = admin.telegramUrl;
      _logoController.text = admin.logoUrl;
      _apiKeyController.text = admin.geminiApiKey;
      _linksLoaded = true;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Admin Panel - ${admin.adminName}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('App Enabled'),
                  subtitle: const Text('Turn OFF to show a maintenance screen to every user, live.'),
                  value: admin.appEnabled,
                  onChanged: (val) async {
                    await admin.setAppEnabled(val);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val ? 'App turned ON for everyone' : 'App turned OFF for everyone'),
                        action: SnackBarAction(
                          label: 'Preview',
                          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                        ),
                      ),
                    );
                  },
                ),
                if (!admin.appEnabled)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                        icon: const Icon(Icons.visibility),
                        label: const Text('Go back and see what users see'),
                      ),
                    ),
                  ),
              ],
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
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: _typeLabels.entries.map((e) {
                      final selected = _selectedType == e.key;
                      return ChoiceChip(
                        label: Text(e.value),
                        selected: selected,
                        selectedColor: _typeColors[e.key]!.withValues(alpha: 0.35),
                        onSelected: (_) => setState(() => _selectedType = e.key),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _broadcastController,
                    decoration: const InputDecoration(
                      hintText: 'Message shown as a banner to every user',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (admin.broadcast.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (_typeColors[admin.broadcastType] ?? Colors.blue).withValues(alpha: 0.2),
                          border: Border.all(color: _typeColors[admin.broadcastType] ?? Colors.blue),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Currently live (${_typeLabels[admin.broadcastType] ?? 'Info'}): ${admin.broadcast}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _broadcastController.clear();
                          admin.clearBroadcast();
                        },
                        child: const Text('Clear'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => admin.setBroadcast(_broadcastController.text.trim(), type: _selectedType),
                        child: const Text('Send / Update'),
                      ),
                    ],
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
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Channels & Logo', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text(
                    'Changes here go live to every user instantly.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _youtubeController,
                    decoration: const InputDecoration(
                      labelText: 'YouTube channel link',
                      prefixIcon: Icon(Icons.smart_display_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _telegramController,
                    decoration: const InputDecoration(
                      labelText: 'Telegram channel link',
                      prefixIcon: Icon(Icons.send_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _logoController,
                    decoration: const InputDecoration(
                      labelText: 'Logo image URL (leave blank for default)',
                      prefixIcon: Icon(Icons.image_outlined),
                      border: OutlineInputBorder(),
                      helperText: 'Paste a direct image link (.png/.jpg). Upload the image anywhere and paste its link here.',
                      helperMaxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        await admin.setLinks(
                          youtube: _youtubeController.text.trim(),
                          telegram: _telegramController.text.trim(),
                        );
                        await admin.setLogoUrl(_logoController.text.trim());
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Updated for everyone')),
                        );
                      },
                      child: const Text('Save & Publish'),
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
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Coding Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Switch(
                        value: admin.codingModeEnabled,
                        onChanged: (val) => admin.setCodingMode(enabled: val, apiKey: admin.geminiApiKey),
                      ),
                    ],
                  ),
                  const Text(
                    'Lets every user chat with a coding assistant (Gemini). Get a free key at aistudio.google.com/apikey.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Gemini API key',
                      prefixIcon: Icon(Icons.vpn_key_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        await admin.setCodingMode(
                          enabled: admin.codingModeEnabled,
                          apiKey: _apiKeyController.text.trim(),
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coding mode key saved')),
                        );
                      },
                      child: const Text('Save Key'),
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
