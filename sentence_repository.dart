import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/sentence.dart';

class SentenceRepository {
  static const String boxName = 'sentences';
  final Box<Sentence> _box = Hive.box<Sentence>(boxName);
  final _uuid = const Uuid();

  List<Sentence> getAll() => _box.values.toList()
    ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

  List<Sentence> dueForReview() {
    final now = DateTime.now();
    return _box.values
        .where((s) => s.nextReviewDate == null || !s.nextReviewDate!.isAfter(now))
        .toList();
  }

  Future<Sentence> add({required String text, required String meaning, List<String>? tags}) async {
    final sentence = Sentence(id: _uuid.v4(), text: text, meaning: meaning, tags: tags);
    await _box.put(sentence.id, sentence);
    return sentence;
  }

  Future<void> update(Sentence sentence) async {
    await sentence.save();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  int get count => _box.length;
}
