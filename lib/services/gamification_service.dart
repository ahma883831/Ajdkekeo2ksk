import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/user_progress.dart';

/// Central place that awards XP/coins and tracks streaks & achievements.
/// Exposed as a ChangeNotifier so UI can react to progress changes.
class GamificationService extends ChangeNotifier {
  static const String boxName = 'user_progress';
  static const String key = 'main';

  final Box<UserProgress> _box = Hive.box<UserProgress>(boxName);

  UserProgress get progress {
    var p = _box.get(key);
    if (p == null) {
      p = UserProgress();
      _box.put(key, p);
    }
    return p;
  }

  Future<void> awardForCorrectAnswer({int xp = 10, int coins = 2}) async {
    final p = progress;
    p.addXp(xp);
    p.addCoins(coins);
    _checkAchievements(p);
    await p.save();
    notifyListeners();
  }

  Future<void> awardForWrongAnswer({int xp = 2}) async {
    final p = progress;
    p.addXp(xp); // small consolation XP so practice always feels rewarded
    await p.save();
    notifyListeners();
  }

  Future<void> onSentenceSaved(int totalSentenceCount) async {
    final p = progress;
    if (totalSentenceCount >= 10) p.unlockAchievement('10_sentences');
    if (totalSentenceCount >= 50) p.unlockAchievement('50_sentences');
    await p.save();
    notifyListeners();
  }

  void _checkAchievements(UserProgress p) {
    if (p.streakCount >= 7) p.unlockAchievement('7_day_streak');
    if (p.streakCount >= 30) p.unlockAchievement('30_day_streak');
  }
}
