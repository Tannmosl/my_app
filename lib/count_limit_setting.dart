// 回数制限設定の情報を保持するクラス
class CountLimitSetting {
  final List<dynamic> apps;      // ロック対象のアプリ
  final List<String> urls;       // ロック対象のURL
  final int limitCount;          // 上限回数
  bool isActive;

  CountLimitSetting({
    required this.apps,
    required this.urls,
    required this.limitCount,
     this.isActive = true,
  });
}