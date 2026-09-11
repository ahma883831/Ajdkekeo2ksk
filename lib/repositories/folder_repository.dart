import 'package:hive/hive.dart';

/// Stores folder/category names as their own entities (key == name == value)
/// so a folder can exist (and be shown/tapped) even before it has any
/// sentences in it.
class FolderRepository {
  static const String boxName = 'folders';
  final Box<String> _box = Hive.box<String>(boxName);

  List<String> getAll() {
    final names = _box.values.toList();
    names.sort();
    return names;
  }

  Future<void> create(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await _box.put(trimmed, trimmed);
  }

  Future<void> delete(String name) async {
    await _box.delete(name);
  }

  bool exists(String name) => _box.containsKey(name.trim());
}
