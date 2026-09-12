import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/admin_control.dart';
import 'admin_panel_screen.dart';

/// Entry gate for the admin panel. Regular users never see this unless
/// they open it explicitly (see the hidden access point in welcome_screen.dart).
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _pinController = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminControl>();
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.admin_panel_settings, size: 56),
              const SizedBox(height: 16),
              Text('Signed in as: ${admin.adminName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Admin PIN',
                  border: const OutlineInputBorder(),
                  errorText: _error,
                ),
                onSubmitted: (_) => _tryLogin(context, admin),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _tryLogin(context, admin),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _tryLogin(BuildContext context, AdminControl admin) {
    if (admin.checkPin(_pinController.text.trim())) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
      );
    } else {
      setState(() => _error = 'Wrong PIN');
    }
  }
}
