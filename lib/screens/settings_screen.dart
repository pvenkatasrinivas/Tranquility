import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/apps_provider.dart';
import '../providers/settings_provider.dart';
import '../models/restricted_app.dart';
import '../services/channel_service.dart';
import '../theme/app_theme.dart';   // This contains AppColors and AppTextStyles

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _settingsScreenState();
}

class _settingsScreenState extends ConsumerState<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final apps = ref.watch(appsProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D1B3E),
                  Color(0xFF0A1628),
                  Color(0xFF060D1F),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Subtitle
                  const Text(
                    'Focus Controls',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Customize your digital sanctuary. Manage\ninterruptions and regain your time.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Silent Mode
                  _buildPremiumCard(
                    icon: Icons.volume_off_outlined,
                    title: 'Silent Mode',
                    subtitle: 'Hide notification when monitoring',
                    value: settings.silentMode,
                    onChanged: (_) => ref.read(settingsProvider.notifier).toggleSilentMode(),
                  ),
                  const SizedBox(height: 16),

                  // Quick Pause
                  _buildPremiumCard(
                    icon: Icons.pause_circle_outline,
                    title: 'Quick Pause',
                    subtitle: 'Pause monitoring for 15 minutes',
                    value: settings.quickPause,
                    onChanged: (_) => ref.read(settingsProvider.notifier).toggleQuickPause(),
                  ),
                  const SizedBox(height: 16),

                  // Delay Configuration
                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Delay Configuration',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'How long to wait before showing intervention',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${settings.delaySeconds}s',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFA4C9FF),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text('1s (SWIFT)', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            Expanded(
                              child: Slider(
                                value: settings.delaySeconds.toDouble(),
                                min: 1,
                                max: 10,
                                divisions: 9,
                                activeColor: const Color(0xFFA4C9FF),
                                inactiveColor: const Color(0xFFA4C9FF).withOpacity(0.15),
                                thumbColor: const Color(0xFFA4C9FF),
                                onChanged: (v) => ref.read(settingsProvider.notifier).setDelay(v.round()),
                              ),
                            ),
                            const Text('10s (DEEP FOCUS)', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Permissions
                  if (!Platform.isIOS)
                  _buildGlassCard(child: Column(
                      children: [
                        _PermRow(
                          label: 'Accessibility Service',
                          subtitle: 'Required for real-time app detection',
                          onTap: () => ChannelService.openAccessibilitySettings(),
                        ),
                        const Divider(color: Colors.white24, height: 20),
                        _PermRow(
                          label: 'Usage Access',
                          subtitle: 'Required for screen time data',
                          onTap: () => ChannelService.openUsageAccessSettings(),
                        ),
                      ],
                    ),),

                  const SizedBox(height: 40),

                  // Quote Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(48),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF222A3D).withOpacity(0.40),
                          borderRadius: BorderRadius.circular(48),
                          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.format_quote, color: const Color(0xFFA4C9FF).withOpacity(0.4), size: 36),
                            const SizedBox(height: 16),
                            const Text(
                              '"Silence is the sleep that\nnourishes wisdom."',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textPrimary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '— Francis Bacon',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Glass Card
  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF222A3D).withOpacity(0.40),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }

  // Premium Card
  Widget _buildPremiumCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF222A3D).withOpacity(0.40),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFA4C9FF).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA4C9FF).withOpacity(0.15), width: 1),
                ),
                child: Icon(icon, color: const Color(0xFFA4C9FF), size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'PREMIUM',
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.gold, letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
              ),
              _buildSwitch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }

  // Custom Switch
  Widget _buildSwitch({required bool value, required ValueChanged<bool> onChanged}) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 48,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9999),
          color: value ? const Color(0xFFA4C9FF).withOpacity(0.20) : Colors.white.withOpacity(0.06),
          border: Border.all(
            color: value ? const Color(0xFFA4C9FF).withOpacity(0.30) : Colors.white.withOpacity(0.10),
            width: 1,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? const Color(0xFFA4C9FF) : AppColors.textSecondary.withOpacity(0.5),
              boxShadow: value
                  ? [BoxShadow(color: const Color(0xFFA4C9FF).withOpacity(0.4), blurRadius: 6, spreadRadius: 1)]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

// Permission Row
class _PermRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _PermRow({required this.label, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Row(
      children: [
        const Icon(Icons.open_in_new, color: Color(0xFFA4C9FF), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
      ],
    ),
  );
}