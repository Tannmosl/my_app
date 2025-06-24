// lock_setting.dart

class LockSetting {
  final Duration duration;
  final List<dynamic> apps;
  final List<String> urls;

  LockSetting({
    required this.duration,
    required this.apps,
    required this.urls,
  });
}
