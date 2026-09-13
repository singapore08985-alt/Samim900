import 'package:flutter/material.dart';
import 'package:livekit_components/livekit_components.dart' as components;
import 'package:provider/provider.dart';

import 'controllers/admin_control.dart';
import 'controllers/app_ctrl.dart';
import 'screens/agent_screen.dart';
import 'screens/welcome_screen.dart';
import 'ui/color_pallette.dart' show LKColorPaletteLight, LKColorPaletteDark;
import 'widgets/app_layout_switcher.dart';
import 'widgets/session_error_banner.dart';

final appCtrl = AppCtrl();
final adminControl = AdminControl()..start();

class VoiceAssistantApp extends StatelessWidget {
  const VoiceAssistantApp({super.key});

  ThemeData buildTheme({required bool isLight}) {
    final colorPallete = isLight ? LKColorPaletteLight() : LKColorPaletteDark();

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'monospace',
      cardColor: colorPallete.bg2,
      scaffoldBackgroundColor: colorPallete.bg1,
      canvasColor: colorPallete.bg1,
      inputDecorationTheme: InputDecorationTheme(
        fillColor: colorPallete.bg2,
        hintStyle: TextStyle(
          color: colorPallete.fg4,
          fontSize: 14,
        ),
      ),
      buttonTheme: ButtonThemeData(
        disabledColor: Colors.red,
        colorScheme: ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.white,
          surface: colorPallete.fgAccent,
        ),
      ),
      colorScheme: isLight
          ? const ColorScheme.light(
              primary: Colors.black,
              secondary: Colors.black,
              surface: Colors.white,
            )
          : const ColorScheme.dark(
              primary: Colors.white,
              secondary: Colors.white,
              surface: Colors.black,
            ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: appCtrl),
          ChangeNotifierProvider.value(value: appCtrl.session),
          ChangeNotifierProvider.value(value: appCtrl.roomContext),
          ChangeNotifierProvider.value(value: adminControl),
        ],
        child: components.SessionContext(
          session: appCtrl.session,
          child: MaterialApp(
            title: 'SK Sefa AI',
            theme: buildTheme(isLight: false),
            darkTheme: buildTheme(isLight: false),
            themeMode: ThemeMode.dark,
            home: Builder(
              builder: (ctx) => Consumer<AdminControl>(
                builder: (ctx, admin, _) {
                  if (!admin.appEnabled) {
                    return const _MaintenanceScreen();
                  }
                  return Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 620),
                      child: Stack(
                        children: [
                          Selector<AppCtrl, AppScreenState>(
                            selector: (ctx, appCtx) => appCtx.appScreenState,
                            builder: (ctx, screen, _) => AppLayoutSwitcher(
                              frontBuilder: (ctx) => const WelcomeScreen(),
                              backBuilder: (ctx) => const AgentScreen(),
                              isFront: screen == AppScreenState.welcome,
                            ),
                          ),
                          const SessionErrorBanner(),
                          if (admin.broadcast.isNotEmpty)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Material(
                                color: {
                                      'warning': Colors.amber,
                                      'urgent': Colors.red,
                                    }[admin.broadcastType] ??
                                    Colors.blue,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    admin.broadcast,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: admin.broadcastType == 'warning' ? Colors.black : Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
}

class _MaintenanceScreen extends StatelessWidget {
  const _MaintenanceScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.build_circle_outlined, size: 64),
                SizedBox(height: 16),
                Text(
                  'SK Sefa AI is temporarily unavailable.\nPlease check back soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
}
