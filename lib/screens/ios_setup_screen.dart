import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IOSSetupScreen extends StatefulWidget {
  const IOSSetupScreen({super.key});

  @override
  State<IOSSetupScreen> createState() => _IOSSetupScreenState();
}

class _IOSSetupScreenState extends State<IOSSetupScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  int _currentStep = 0;

  final List<_SetupStep> _steps = [
    _SetupStep(
      icon: Icons.ios_share_outlined,
      title: 'Open Shortcuts App',
      description:
      'Find the "Shortcuts" app on your iPhone. It comes pre-installed '
          'with iOS. If you deleted it, download it free from the App Store.',
      tip: 'Search "Shortcuts" in Spotlight — swipe down on your home screen',
    ),
    _SetupStep(
      icon: Icons.autorenew_outlined,
      title: 'Go to Automation Tab',
      description:
      'At the bottom of the Shortcuts app, tap the "Automation" tab '
          '(the clock icon). This is where phone-triggered automations live.',
      tip: 'Automation tab is at the bottom center of the Shortcuts app',
    ),
    _SetupStep(
      icon: Icons.add_circle_outline,
      title: 'Create New Automation',
      description:
      'Tap "+" → select "App" from the list. Choose the app you want '
          'to monitor (e.g. Instagram). Make sure "Opens" is checked. '
          'Tap Next.',
      tip: 'Repeat this for each app you want to monitor separately',
    ),
    _SetupStep(
      icon: Icons.link_outlined,
      title: 'Add Open URLs Action',
      description:
      'Tap "New Blank Automation" → "Add Action" → search "Open URLs". '
          'Paste the Tranquility link below into the URL field.',
      tip: 'Copy the link from the box below, then paste it in the URL field',
    ),
    _SetupStep(
      icon: Icons.toggle_off_outlined,
      title: 'Turn OFF Ask Before Running',
      description:
      'This is the most important step. Toggle OFF "Ask Before Running" '
          'at the top of the automation. Without this, iOS asks permission '
          'every time — breaking the whole flow.',
      tip: 'iOS 17+: find this in the three-dot menu (⋯) at top right',
    ),
    _SetupStep(
      icon: Icons.check_circle_outline,
      title: 'Done! Test it now.',
      description:
      'Now when you try to open Instagram, iOS will automatically '
          'open Tranquility first. You will see the breathing screen, '
          'then the decision screen. Repeat for each app.',
      tip: 'Repeat steps 3–5 for YouTube, WhatsApp, Snapchat etc.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < _steps.length - 1) {
      _fadeCtrl.reverse().then((_) {
        setState(() => _currentStep++);
        _fadeCtrl.forward();
      });
    }
  }

  void _prev() {
    if (_currentStep > 0) {
      _fadeCtrl.reverse().then((_) {
        setState(() => _currentStep--);
        _fadeCtrl.forward();
      });
    }
  }

  // URL table for copy-paste
  final List<Map<String, String>> _urlTable = [
    {'app': 'Instagram', 'url': 'tranquility://intervention?app=Instagram&scheme=instagram://'},
    {'app': 'YouTube',   'url': 'tranquility://intervention?app=YouTube&scheme=youtube://'},
    {'app': 'WhatsApp',  'url': 'tranquility://intervention?app=WhatsApp&scheme=whatsapp://'},
    {'app': 'Facebook',  'url': 'tranquility://intervention?app=Facebook&scheme=fb://'},
    {'app': 'Snapchat',  'url': 'tranquility://intervention?app=Snapchat&scheme=snapchat://'},
    {'app': 'TikTok',    'url': 'tranquility://intervention?app=TikTok&scheme=snssdk1233://'},
    {'app': 'Twitter',   'url': 'tranquility://intervention?app=Twitter&scheme=twitter://'},
    {'app': 'Reddit',    'url': 'tranquility://intervention?app=Reddit&scheme=reddit://'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B3E), Color(0xFF0A1628), Color(0xFF060D1F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2336),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Color(0xFFA4C9FF), size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('iOS Setup',
                            style: TextStyle(fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD0E4F8))),
                        Text('Shortcuts Automation Guide',
                            style: TextStyle(fontSize: 12,
                                color: Color(0xFF6B84A8))),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (i) {
                  final isActive   = i == _currentStep;
                  final isComplete = i < _currentStep;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: isActive ? 24 : 8, height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9999),
                      color: isComplete
                          ? const Color(0xFF4CAF83)
                          : isActive
                          ? const Color(0xFFA4C9FF)
                          : const Color(0xFF1E304F),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Step card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: _buildCard(_steps[_currentStep]),
                  ),
                ),
              ),

              // URL copy section (shown on step 4)
              if (_currentStep == 3)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  child: _buildUrlList(),
                ),

              // Nav buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Row(
                  children: [
                    if (_currentStep > 0) ...[
                      Expanded(
                        child: GestureDetector(
                          onTap: _prev,
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                  color: const Color(0xFF1E304F), width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: const Text('← Back',
                                style: TextStyle(color: Color(0xFF6B84A8),
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: _currentStep == _steps.length - 1
                            ? () => Navigator.pop(context)
                            : _next,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFA4C9FF), Color(0xFF00315D)],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _currentStep == _steps.length - 1
                                ? '✓  Done'
                                : 'Next Step →',
                            style: const TextStyle(color: Colors.white,
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(_SetupStep step) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF222A3D).withOpacity(0.40),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('STEP ${_currentStep + 1} OF ${_steps.length}',
                  style: const TextStyle(fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFA4C9FF), letterSpacing: 2)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA4C9FF).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(step.icon,
                        color: const Color(0xFFA4C9FF), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(step.title,
                        style: const TextStyle(fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD0E4F8))),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(color: Color(0xFF1E304F)),
              const SizedBox(height: 16),
              Text(step.description,
                  style: const TextStyle(fontSize: 14,
                      color: Color(0xFFD0E4F8), height: 1.65)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFA4C9FF).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFA4C9FF).withOpacity(0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Text(step.tip,
                          style: const TextStyle(fontSize: 12,
                              color: Color(0xFF6B84A8), height: 1.5)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrlList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _urlTable.length,
        itemBuilder: (_, i) {
          final item = _urlTable[i];
          return GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: item['url']!));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item['app']} URL copied!'),
                  backgroundColor: const Color(0xFF4CAF83),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2336),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1E304F)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['app']!,
                      style: const TextStyle(color: Color(0xFFD0E4F8),
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(item['url']!,
                      style: const TextStyle(color: Color(0xFF6B84A8),
                          fontSize: 9, height: 1.4),
                      maxLines: 3, overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  const Row(
                    children: [
                      Icon(Icons.copy, color: Color(0xFFA4C9FF), size: 12),
                      SizedBox(width: 4),
                      Text('Tap to copy',
                          style: TextStyle(color: Color(0xFFA4C9FF),
                              fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SetupStep {
  final IconData icon;
  final String title;
  final String description;
  final String tip;
  const _SetupStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.tip,
  });
}