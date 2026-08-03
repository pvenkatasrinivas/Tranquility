import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/apps_provider.dart';
import '../providers/stats_provider.dart';
import '../theme/app_theme.dart';
import '../services/hive_service.dart';
import '../services/channel_service.dart';
import 'intervention_screen.dart';
import 'settings_screen.dart';

import 'dart:io';
// import '../services/ios_control.dart';


import '../models/restricted_app.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  bool _focusActive = false;
  int _focusSecondsLeft = 25 * 60;
  Timer? _timer;

  // ✅ NEW: Hard Mode + Limit state
  bool _hardModeEnabled = false;
  double _globalOpenLimit = 0;

  // Default 6 apps (Fixed)
  final List<Map<String, String>> _defaultApps = [
    {'name': 'WhatsApp', 'packageName': 'com.whatsapp'},
    {'name': 'YouTube', 'packageName': 'com.google.android.youtube'},
    {'name': 'Instagram', 'packageName': 'com.instagram.android'},
    {'name': 'Facebook', 'packageName': 'com.facebook.katana'},
    {'name': 'Snapchat', 'packageName': 'com.snapchat.android'},
    {'name': 'Gmail', 'packageName': 'com.google.android.gm'},
  ];

  @override
  void initState() {
    super.initState();
    // ✅ Load saved settings
    _hardModeEnabled = HiveService.hardModeEnabled;
    _globalOpenLimit = HiveService.globalOpenLimit.toDouble();

    // Auto-add default 6 apps if not present
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureDefaultAppsExist();
    });
  }

  Future<void> _ensureDefaultAppsExist() async {
    final currentApps = ref.read(appsProvider);
    final existingPackages = currentApps.map((a) => a.packageName).toSet();

    for (final def in _defaultApps) {
      if (!existingPackages.contains(def['packageName'])) {
        final newApp = RestrictedApp(
          id: def['packageName']!,
          name: def['name']!,
          packageName: def['packageName']!,
          enabled: false,
        );
        await ref.read(appsProvider.notifier).addApp(newApp);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startFocus() {
    _timer?.cancel();

    // ✅ iOS integration
    // await IOSControl.requestPermission();
    // await IOSControl.selectApps();
    // await IOSControl.startFocus();

    setState(() {
      _focusActive = true;
      _focusSecondsLeft = 25 * 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_focusSecondsLeft <= 1) {
          t.cancel();
          _focusActive = false;
          _focusSecondsLeft = 25 * 60;
          ref.read(statsProvider.notifier).recordFocusSession();
        } else {
          _focusSecondsLeft--;
        }
      });
    });
  }

  void _stopFocus() {
    _timer?.cancel();
    if (!mounted) return;
    setState(() {
      _focusActive = false;
      _focusSecondsLeft = 25 * 60;
    });
  }

  String _formatTime(int secs) {
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _simulateOpen(RestrictedApp app) {
    if (!mounted) return;

    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (ctx, anim, _) => FadeTransition(
        opacity: anim,
        child: InterventionScreen(
          appName: app.name,
          openCount: app.openCount,
          usageMinutes: app.usageMinutes,
          isBlocked: false,
          onCancel: () {
            Navigator.pop(ctx);
            ref.read(statsProvider.notifier).recordGoodDecision();
          },
          onContinue: () {
            Navigator.pop(ctx);
            ref.read(appsProvider.notifier).recordOpen(app.packageName);
            ref.read(statsProvider.notifier).recordBadDecision();
          },
        ),
      ),
    ));
  }

  // Open Manage All Modal (moved from settings)
  void _openManageAppsModal() {
    // On iOS, the modal tries to call ChannelService.getInstalledApps()
    // which doesn't exist on iOS — so we block it on iOS entirely.
    if (Platform.isIOS) return;

    final existing = ref.read(appsProvider).map((a) => a.packageName).toSet();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ManageAppsModal(
        onSelect: (info) {
          final restricted = RestrictedApp(
            id: info.packageName,
            name: info.appName,
            packageName: info.packageName,
          );
          ref.read(appsProvider.notifier).addApp(restricted);
        },
        existing: existing,
      ),
    );
  }

  // Reusable App Toggle Icon Widget
  Widget _buildAppToggle(RestrictedApp app, {bool isDefault = false}) {
    final isEnabled = app.enabled;

    return GestureDetector(
      onTap: () {
        ref.read(appsProvider.notifier).toggleApp(app.id);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with glow effect
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isEnabled
                    ? const Color(0xFFA4C9FF).withOpacity(0.6)
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: isEnabled
                  ? [
                BoxShadow(
                  color: const Color(0xFFA4C9FF).withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: const Color(0xFFA4C9FF).withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 8,
                ),
              ]
                  : [],
            ),
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A2336),
                border: Border.all(
                  color: isEnabled
                      ? const Color(0xFFA4C9FF)
                      : Colors.white.withOpacity(0.15),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    _getAppImage(app.packageName),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Status Text
          Text(
            isEnabled ? "Enabled" : "Disabled",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isEnabled
                  ? const Color(0xFFA4C9FF)
                  : Colors.white.withOpacity(0.5),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            app.name,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getAppImage(String packageName) {
    if (packageName.contains('whatsapp')) return 'lib/assets/icons/whatsapp.png';
    if (packageName.contains('youtube')) return 'lib/assets/icons/youtube.png';
    if (packageName.contains('instagram')) return 'lib/assets/icons/instagram.png';
    if (packageName.contains('facebook')) return 'lib/assets/icons/facebook.png';
    if (packageName.contains('snapchat')) return 'lib/assets/icons/snapchat.png';
    if (packageName.contains('gmail') || packageName.contains('gm')) return 'lib/assets/icons/gmail.png';
    return 'lib/assets/icons/default.png'; // optional fallback
  }

  @override
  Widget build(BuildContext context) {
    final allApps = ref.watch(appsProvider);
    final stats = ref.watch(statsProvider);
    final total = stats.goodDecisions + stats.badDecisions;
    final score = total == 0 ? 100 : (stats.goodDecisions * 100) ~/ total;

    // Split apps
    final defaultPackages = _defaultApps.map((e) => e['packageName']).toSet();
    final defaultAppsList = allApps
        .where((a) => defaultPackages.contains(a.packageName))
        .toList();

    final userAddedApps = allApps
        .where((a) => !defaultPackages.contains(a.packageName))
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          // ── BACKGROUND BASE ──
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF0A0E1A),
          ),

          // ── BACKGROUND RADIAL GRADIENT ──
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, -1.0),
                radius: 1.4,
                colors: [
                  Color(0xFF1E3358),
                  Color(0xFF112040),
                  Color(0xFF0A0E1A),
                  Color(0xFF080C18),
                ],
                stops: [0.0, 0.35, 0.75, 1.0],
              ),
            ),
          ),

          // ── FIGMA OVERLAY BLUR CIRCLE ──
          Positioned(
            top: 71.38,
            left: -105,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(
                width: 600,
                height: 600,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x1AA4C9FF),
                ),
              ),
            ),
          ),

          // ── MAIN CONTENT ──
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      heightFactor: 0.70,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15.7),
                        child: _buildEye(),
                      ),
                    ),
                  ),
                ),

                // ── Active label ──
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 16),
                    child: Text(
                      'Tranquility Active',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),

                // ── Stats row ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          _StatItem(
                            label: 'RESISTED',
                            value: '${stats.goodDecisions}',
                            color: AppColors.green,
                          ),
                          _Divider(),
                          _StatItem(
                            label: 'SCORE',
                            value: '$score',
                            color: AppColors.blueLight,
                          ),
                          _Divider(),
                          _StatItem(
                            label: 'BREATHING',
                            value: '${stats.breathingSessions}',
                            color: AppColors.purple,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // ── Focus session button ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: _focusActive ? _stopFocus : _startFocus,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          gradient: _focusActive
                              ? null
                              : const LinearGradient(
                            colors: [
                              Color(0xFFA4C9FF),
                              Color(0xFF00315D),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          color: _focusActive
                              ? const Color(0xFF1A2B47).withOpacity(0.85)
                              : null,
                          border: _focusActive
                              ? Border.all(
                            color: const Color(0xFFA4C9FF).withOpacity(0.15),
                            width: 1,
                          )
                              : null,
                          boxShadow: _focusActive
                              ? null
                              : [
                            BoxShadow(
                              color: const Color(0xFFA4C9FF).withOpacity(0.30),
                              blurRadius: 20,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _focusActive
                                  ? Icons.stop_circle_outlined
                                  : Icons.timer_outlined,
                              color: _focusActive
                                  ? const Color(0xFFD0E8FF)
                                  : const Color(0xFF0D1525),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _focusActive
                                  ? 'Stop · ${_formatTime(_focusSecondsLeft)}'
                                  : 'Start 25-min Focus Session',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _focusActive
                                    ? const Color(0xFFD0E8FF)
                                    : const Color(0xFF0D1525),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // ── 3 Dots Menu Button ──
                // ── 3 Dots Menu Button ──
                if (!Platform.isIOS)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _openManageAppsModal,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A2336),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.more_vert,
                              color: Color(0xFFA4C9FF),
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── Default 6 Apps Section ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Controls',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 24,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.78,
                          ),
                          itemCount: defaultAppsList.length,
                          itemBuilder: (context, index) {
                            return _buildAppToggle(defaultAppsList[index], isDefault: true);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),

                // ── User Added Apps Section ──
                if (userAddedApps.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Additional Apps',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 24,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.78,
                            ),
                            itemCount: userAddedApps.length,
                            itemBuilder: (context, index) {
                              return _buildAppToggle(userAddedApps[index]);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEye() {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1A2336).withOpacity(0.45),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA4C9FF).withOpacity(0.08),
            blurRadius: 60,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFA4C9FF).withOpacity(0.08),
                width: 1,
              ),
            ),
          ),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFA4C9FF).withOpacity(0.10),
                width: 1,
              ),
            ),
          ),
          Container(
            width: 155,
            height: 155,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFA4C9FF).withOpacity(0.15),
                width: 1,
              ),
            ),
          ),
          const Icon(
            Icons.remove_red_eye_outlined,
            color: Color(0xFFA4C9FF),
            size: 56,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        value,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 1,
        ),
      ),
    ]),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 44,
    margin: const EdgeInsets.symmetric(horizontal: 12),
    color: const Color(0xFFA4C9FF).withOpacity(0.2),
  );
}

// Manage Apps Modal (copied from settings - unchanged)
class _ManageAppsModal extends StatefulWidget {
  final void Function(InstalledAppInfo) onSelect;
  final Set<String> existing;

  const _ManageAppsModal({required this.onSelect, required this.existing});

  @override
  State<_ManageAppsModal> createState() => _ManageAppsModalState();
}

class _ManageAppsModalState extends State<_ManageAppsModal> {
  List<InstalledAppInfo> _all = [];
  List<InstalledAppInfo> _filtered = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final apps = await ChannelService.getInstalledApps();
    if (!mounted) return;
    setState(() {
      _all = apps;
      _filtered = apps;
      _loading = false;
    });
  }

  void _filter(String q) {
    setState(() {
      _query = q;
      _filtered = _all
          .where((a) =>
      a.appName.toLowerCase().contains(q.toLowerCase()) ||
          a.packageName.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF0D1828),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          const Text('Select Apps to Restrict', style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text('Tap Add to restrict an app', style: AppTextStyles.caption),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: _filter,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search apps...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceHigh,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFA4C9FF)))
                : _filtered.isEmpty
                ? Center(
              child: Text(
                _query.isEmpty ? 'No apps found' : 'No results for "$_query"',
                style: AppTextStyles.bodyMuted,
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final app = _filtered[i];
                final alreadyAdded = widget.existing.contains(app.packageName);
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA4C9FF).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.apps_outlined, color: Color(0xFFA4C9FF), size: 20),
                  ),
                  title: Text(app.appName, style: AppTextStyles.body),
                  subtitle: Text(app.packageName, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: alreadyAdded
                      ? const Icon(Icons.check_circle, color: Colors.green, size: 22)
                      : GestureDetector(
                    onTap: () {
                      widget.onSelect(app);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA4C9FF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderFaint),
                      ),
                      child: const Text('Add',
                          style: TextStyle(color: Color(0xFFA4C9FF), fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}