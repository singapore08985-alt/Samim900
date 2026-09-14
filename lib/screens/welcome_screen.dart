import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as sdk;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl, LaunchMode;
import '../controllers/admin_control.dart';
import '../controllers/app_ctrl.dart' as ctrl;
import '../widgets/agent_status_indicator.dart';
import '../widgets/button.dart' as buttons;
import 'admin_login_screen.dart';
import 'coding_assistant_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext ctx) => Material(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 30,
              children: [
                Consumer<AdminControl>(
                  builder: (ctx, admin, _) => GestureDetector(
                    onLongPress: () => Navigator.of(ctx).push(
                      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                    ),
                    child: admin.logoUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              admin.logoUrl,
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset('assets/sk_sefa_logo.png', width: 96, height: 96),
                            ),
                          )
                        : Image.asset('assets/sk_sefa_logo.png', width: 96, height: 96),
                  ),
                ),
                Text(
                  'SK Sefa AI',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.brightnessOf(ctx) == Brightness.light ? Colors.black : Colors.white,
                  ),
                ),
                const Text(
                  'Start a call to chat with your voice agent.',
                  textAlign: TextAlign.center,
                ),
                Consumer<AdminControl>(
                  builder: (ctx, admin, _) {
                    if (admin.youtubeUrl.isEmpty && admin.telegramUrl.isEmpty) return const SizedBox.shrink();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 16,
                      children: [
                        if (admin.youtubeUrl.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.smart_display, color: Colors.red),
                            tooltip: 'YouTube',
                            onPressed: () => launchUrl(Uri.parse(admin.youtubeUrl), mode: LaunchMode.externalApplication),
                          ),
                        if (admin.telegramUrl.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.send, color: Colors.lightBlue),
                            tooltip: 'Telegram',
                            onPressed: () => launchUrl(Uri.parse(admin.telegramUrl), mode: LaunchMode.externalApplication),
                          ),
                      ],
                    );
                  },
                ),
                // Agent status indicator
                const AgentStatusIndicator(),
                Consumer<AdminControl>(
                  builder: (ctx, admin, _) {
                    if (!admin.codingModeEnabled) return const SizedBox.shrink();
                    return TextButton.icon(
                      onPressed: () => Navigator.of(ctx).push(
                        MaterialPageRoute(builder: (_) => const CodingAssistantScreen()),
                      ),
                      icon: const Icon(Icons.terminal, color: Color(0xFF00FF41)),
                      label: const Text('aether_assistant', style: TextStyle(color: Color(0xFF00FF41))),
                    );
                  },
                ),
                Consumer2<ctrl.AppCtrl, sdk.Session>(
                  builder: (ctx, appCtrl, session, child) {
                    final isProgressing =
                        appCtrl.isSessionStarting || session.connectionState != sdk.ConnectionState.disconnected;
                    return buttons.Button(
                      text: isProgressing ? 'Connecting' : 'Start call',
                      isProgressing: isProgressing,
                      onPressed: () => appCtrl.connect(),
                    );
                  },
                ),
                Consumer<AdminControl>(
                  builder: (ctx, admin, _) => Text(
                    'SK Sefa AI  •  Support: ${admin.supportNumber}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.brightnessOf(ctx) == Brightness.light ? Colors.black54 : Colors.white54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
