import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 1)
class AppSettings extends HiveObject {
  @HiveField(0)
  int delaySeconds;

  @HiveField(1)
  bool silentMode;

  @HiveField(2)
  bool quickPause;


  @HiveField(3)
  bool hardModeEnabled;

  @HiveField(4)
  int globalOpenLimit;

  AppSettings({
    this.delaySeconds = 3,
    this.silentMode = true,
    this.quickPause = false,


    this.hardModeEnabled = false,
    this.globalOpenLimit = 0,
  });
}