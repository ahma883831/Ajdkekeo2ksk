import 'package:hive/hive.dart';

class UserProgress extends HiveObject {
  int xp;
  int level;
  int streakCount;
  DateTime? lastActiveDate;
  int coins;
  List<String> achievements;

  UserProgress({
    this.xp = 0,
    this.level = 1,
    this.streakCount = 0,
    this.lastActiveDate,
    this.coins = 0,
    List<String>? achievements,
  }) : achievements = achievements ?? [];

  /// XP required to reach the next level (simple curve).
  int get xpForNextLevel => level * 100;

  void addXp(int amount) {
    xp += amount;
    while (xp >= xpForNextLevel) {
      xp -= xpForNextLevel;
      level += 1;
    }
    _registerActivityToday();
  }

  void addCoins(int amount) => coins += amount;

  void unlockAchievement(String key) {
    if (!achievements.contains(key)) achievements.add(key);
  }

  void _registerActivityToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (lastActiveDate == null) {
      streakCount = 1;
    } else {
      final last = DateTime(
        lastActiveDate!.year,
        lastActiveDate!.month,
        lastActiveDate!.day,
      );
      final diff = today.difference(last).inDays;
      if (diff == 1) {
        streakCount += 1;
      } else if (diff > 1) {
        streakCount = 1;
      }
      // diff == 0 -> already active today, keep streak as is
    }
    lastActiveDate = today;
  }
}

class UserProgressAdapter extends TypeAdapter<UserProgress> {
  @override
  final int typeId = 1;

  @override
  UserProgress read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return UserProgress(
      xp: fields[0] as int,
      level: fields[1] as int,
      streakCount: fields[2] as int,
      lastActiveDate: fields[3] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(fields[3] as int),
      coins: fields[4] as int,
      achievements: (fields[5] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserProgress obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.xp)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.streakCount)
      ..writeByte(3)
      ..write(obj.lastActiveDate?.millisecondsSinceEpoch)
      ..writeByte(4)
      ..write(obj.coins)
      ..writeByte(5)
      ..write(obj.achievements);
  }
}
