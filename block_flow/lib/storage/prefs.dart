import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static const _best = 'best_score';

  static Future<int> loadBest() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_best) ?? 0;
  }

  static Future<void> saveBest(int v) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_best, v);
  }
}
