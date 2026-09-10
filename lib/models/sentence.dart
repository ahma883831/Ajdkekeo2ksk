import 'package:hive/hive.dart';

/// A single saved English sentence with its meaning and spaced-repetition
/// tracking data.
class Sentence extends HiveObject {
  String id;
  String text;
  String meaning;
  List<String> tags;
  DateTime dateAdded;
  int timesReviewed;
  DateTime? lastReviewed;
  DateTime? nextReviewDate;
  int masteryLevel; // 0-5

  Sentence({
    required this.id,
    required this.text,
    required this.meaning,
    List<String>? tags,
    DateTime? dateAdded,
    this.timesReviewed = 0,
    this.lastReviewed,
    this.nextReviewDate,
    this.masteryLevel = 0,
  })  : tags = tags ?? [],
        dateAdded = dateAdded ?? DateTime.now();

  /// Simple spaced-repetition interval (days) based on mastery level.
  static const List<int> _intervalDays = [0, 1, 3, 7, 14, 30];

  void registerReview({required bool wasCorrect}) {
    timesReviewed += 1;
    lastReviewed = DateTime.now();
    if (wasCorrect) {
      if (masteryLevel < 5) masteryLevel += 1;
    } else {
      masteryLevel = (masteryLevel - 1).clamp(0, 5);
    }
    final days = _intervalDays[masteryLevel];
    nextReviewDate = DateTime.now().add(Duration(days: days));
  }
}

/// Hand-written Hive adapter (avoids needing build_runner in CI).
class SentenceAdapter extends TypeAdapter<Sentence> {
  @override
  final int typeId = 0;

  @override
  Sentence read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };
    return Sentence(
      id: fields[0] as String,
      text: fields[1] as String,
      meaning: fields[2] as String,
      tags: (fields[3] as List).cast<String>(),
      dateAdded: DateTime.fromMillisecondsSinceEpoch(fields[4] as int),
      timesReviewed: fields[5] as int,
      lastReviewed: fields[6] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(fields[6] as int),
      nextReviewDate: fields[7] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(fields[7] as int),
      masteryLevel: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Sentence obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.meaning)
      ..writeByte(3)
      ..write(obj.tags)
      ..writeByte(4)
      ..write(obj.dateAdded.millisecondsSinceEpoch)
      ..writeByte(5)
      ..write(obj.timesReviewed)
      ..writeByte(6)
      ..write(obj.lastReviewed?.millisecondsSinceEpoch)
      ..writeByte(7)
      ..write(obj.nextReviewDate?.millisecondsSinceEpoch)
      ..writeByte(8)
      ..write(obj.masteryLevel);
  }
}
