import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'package:flutter/foundation.dart'; // ← Required for web

import 'services/hive_service.dart';
import 'services/channel_service.dart';
import 'services/deep_link_service.dart';
import 'services/ios_channel_service.dart';
import 'providers/apps_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/ios_intervention_provider.dart';

import 'screens/focus_screen.dart';
import 'screens/breathe_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/intervention_screen.dart';
import 'screens/sliding_delay_screen.dart';
import 'screens/ios_setup_screen.dart';

import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0D1828),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Web Safe Hive Initialization
  if (!kIsWeb) {
    await HiveService.init();
  }
  // On web we skip full init to avoid late errors

  runApp(const ProviderScope(child: TranquilityApp()));
}

class TranquilityApp extends StatelessWidget {
  const TranquilityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tranquility',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const _Shell(),
    );
  }
}

class _Shell extends ConsumerStatefulWidget {
  const _Shell();

  @override
  ConsumerState<_Shell> createState() => _ShellState();
}

class _ShellState extends ConsumerState<_Shell> {
  int _tab = 0;
  bool _interventionVisible = false;
  bool _delayScreenVisible = false;
  bool _hardModeEnabled = false;      // default for web
  double _globalOpenLimit = 5.0;      // default for web

  static const _screens = [
    FocusScreen(),
    BreatheScreen(),
    SettingsScreen(),
    StatsScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Load values safely
    if (!kIsWeb) {
      _hardModeEnabled = HiveService.hardModeEnabled;
      _globalOpenLimit = HiveService.globalOpenLimit.toDouble();
    }
    // On web we keep the default values above

    if (kIsWeb) {
      return; // Skip Android/iOS specific initialization
    }

    if (Platform.isAndroid) {
      ChannelService.init();
      ChannelService.startMonitoring();

      ChannelService.onForegroundApp = (data) {
        final packageName = data['packageName'] as String? ?? '';
        final appName = data['appName'] as String? ?? packageName;
        final openCount = data['openCount'] as int? ?? 1;
        final isBlocked = data['blocked'] as bool? ?? false;

        ref.read(appsProvider.notifier).syncOpenCount(packageName, openCount);

        if (_interventionVisible || _delayScreenVisible) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _delayScreenVisible = true;

          Navigator.of(context).push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => SlidingDelayScreen(
              delaySeconds: 3,
              onFinished: () {
                Navigator.pop(context);
                _delayScreenVisible = false;
                _showAndroidIntervention(appName, openCount, isBlocked);
              },
            ),
          ));
        });
      };

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final apps = ref.read(appsProvider);
        ChannelService.updateRestrictedApps(apps);
      });
    }
    else if (Platform.isIOS) {
      DeepLinkService.onInterventionLink = (appName, urlScheme) {
        if (_interventionVisible || _delayScreenVisible) return;

        ref.read(iosInterventionProvider.notifier).trigger(appName, urlScheme);
        final openCount = HiveService.getIOSOpenCount(appName);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _delayScreenVisible = true;

          Navigator.of(context).push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => SlidingDelayScreen(
              delaySeconds: 3,
              onFinished: () {
                Navigator.pop(context);
                _delayScreenVisible = false;
                _showIOSIntervention(appName, urlScheme, openCount);
              },
            ),
          ));
        });
      };

      DeepLinkService.init();
    }
  }

  // === Your intervention and settings methods (unchanged) ===
  void _showAndroidIntervention(String appName, int openCount, bool isBlocked) {
    if (_interventionVisible) return;
    _interventionVisible = true;

    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) => InterventionScreen(
        appName: appName,
        openCount: openCount,
        usageMinutes: 0,
        isBlocked: isBlocked,
        onCancel: () async {
          Navigator.pop(context);
          _interventionVisible = false;
          ref.read(statsProvider.notifier).recordGoodDecision();
          await ChannelService.goHome();
        },
        onContinue: isBlocked
            ? null
            : () async {
          Navigator.pop(context);
          _interventionVisible = false;
          ref.read(statsProvider.notifier).recordBadDecision();
          await ChannelService.continueToApp();
        },
      ),
    )).then((_) {
      if (mounted) _interventionVisible = false;
    });
  }

  void _showIOSIntervention(String appName, String urlScheme, int openCount) {
    if (_interventionVisible) return;
    _interventionVisible = true;

    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) => InterventionScreen(
        appName: appName,
        openCount: openCount,
        usageMinutes: 0,
        isBlocked: false,
        onCancel: () async {
          Navigator.pop(context);
          _interventionVisible = false;
          ref.read(iosInterventionProvider.notifier).dismiss();
          ref.read(statsProvider.notifier).recordGoodDecision();
          await IOSChannelService.goHome();
        },
        onContinue: () async {
          Navigator.pop(context);
          _interventionVisible = false;
          ref.read(iosInterventionProvider.notifier).dismiss();
          ref.read(statsProvider.notifier).recordBadDecision();
          await IOSChannelService.openApp(urlScheme);
        },
      ),
    )).then((_) {
      if (mounted) _interventionVisible = false;
    });
  }

  void _showSettingsMenu(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Scaffold(
          backgroundColor: const Color(0xFF111827),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (!kIsWeb && Platform.isIOS) ...[
                      // iOS Setup Button
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const IOSSetupScreen()));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A2336),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFA4C9FF).withOpacity(0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.ios_share, color: Color(0xFFA4C9FF)),
                              SizedBox(width: 12),
                              Expanded(child: Text('Setup iOS Shortcuts', style: TextStyle(color: Colors.white))),
                              Icon(Icons.chevron_right, color: Color(0xFFA4C9FF)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (!kIsWeb && Platform.isAndroid) ...[
                      // Hard Mode (Android only)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFF1A2336), borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          children: [
                            const Icon(Icons.shield_outlined, color: Color(0xFFA4C9FF)),
                            const SizedBox(width: 12),
                            const Expanded(child: Text('Hard Mode', style: TextStyle(color: Colors.white))),
                            Switch(
                              value: _hardModeEnabled,
                              onChanged: (val) async {
                                setModalState(() {});
                                setState(() => _hardModeEnabled = val);
                                await HiveService.saveHardMode(val);
                                await ChannelService.updateHardMode(val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Global Open Limit (Android only)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFF1A2336), borderRadius: BorderRadius.circular(14)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Global Open Limit: ${_globalOpenLimit.toInt()}', style: const TextStyle(color: Colors.white)),
                            Slider(
                              value: _globalOpenLimit,
                              min: 0,
                              max: 20,
                              divisions: 20,
                              onChanged: (val) async {
                                setModalState(() {});
                                setState(() => _globalOpenLimit = val);
                                await HiveService.saveGlobalOpenLimit(val.toInt());
                                await ChannelService.updateGlobalOpenLimit(val.toInt());
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    DeepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF12233A),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFFA4C9FF)),
          onPressed: () => _showSettingsMenu(context),
        ),
        title: const Text(
          'Tranquility',
          style: TextStyle(color: Color(0xFFA4C9FF), fontSize: 20, fontWeight: FontWeight.w300),
        ),
        centerTitle: false,
      ),
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: _TranquilityNavBar(
        current: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}

// Bottom Navigation (unchanged)
class _TranquilityNavBar extends StatelessWidget {
  final int current;
  final void Function(int) onTap;

  const _TranquilityNavBar({super.key, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(icon: Icons.adjust_outlined, label: 'FOCUS'),
      _NavItem(icon: Icons.air_outlined, label: 'BREATHE'),
      _NavItem(icon: Icons.article_outlined, label: 'SETTINGS'),
      _NavItem(icon: Icons.bar_chart_outlined, label: 'STATS'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1828),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isActive = i == current;
              return GestureDetector(
                onTap: () => onTap(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 74,
                      height: 59,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9999),
                        gradient: isActive ? const LinearGradient(colors: [Color(0xFFA4C9FF), Color(0xFF00315D)]) : null,
                      ),
                      child: Icon(items[i].icon, color: isActive ? Colors.white : const Color(0xFF6B86A5)),
                    ),
                    const SizedBox(height: 4),
                    Text(items[i].label, style: TextStyle(fontSize: 10, color: isActive ? const Color(0xFFA4C9FF) : const Color(0xFF6B86A5))),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}