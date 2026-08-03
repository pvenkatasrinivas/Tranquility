import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hive_service.dart';

class IOSInterventionState {
  final String? pendingAppName;
  final String? pendingUrlScheme;
  final bool isActive;

  const IOSInterventionState({
    this.pendingAppName,
    this.pendingUrlScheme,
    this.isActive = false,
  });
}

class IOSInterventionNotifier extends Notifier<IOSInterventionState> {
  @override
  IOSInterventionState build() => const IOSInterventionState();

  void trigger(String appName, String urlScheme) {
    HiveService.recordIOSAppOpen(appName);
    state = IOSInterventionState(
      pendingAppName:   appName,
      pendingUrlScheme: urlScheme,
      isActive:         true,
    );
  }

  void dismiss() {
    state = const IOSInterventionState();
  }
}

final iosInterventionProvider =
NotifierProvider<IOSInterventionNotifier, IOSInterventionState>(
  IOSInterventionNotifier.new,
);