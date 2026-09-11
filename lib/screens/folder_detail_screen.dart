import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sentence.dart';
import '../repositories/sentence_repository.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import 'add_edit_sentence_screen.dart';
import 'sentence_detail_screen.dart';
import 'practice_hub_screen.dart';

/// Shows the sentences that belong to one folder.
/// folderFilter == null  -> all sentences (no filter)
/// folderFilter == ''    -> uncategorized sentences (folder == '')
/// folderFilter == name  -> sentences in that specific folder
class FolderDetailScreen extends StatefulWidget {
  final String? folderFilter;
  final String title;
  const FolderDetailScreen({super.key, required this.folderFilter, required this.title});

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final repo = context.read<SentenceRepository>();
    final tts = context.read<TtsService>();

    final base = widget.folderFilter == null
        ? repo.getAll()
        : repo.getByFolder(widget.folderFilter!);
    final filtered = _query.isEmpty
        ? base
        : base
            .where((s) =>
                s.text.toLowerCase().contains(_query.toLowerCase()) ||
                s.meaning.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    // Sentences added from inside a folder default to that folder
    // ('' and null both mean "no preset folder" for the add screen).
    final presetFolder = (widget.folderFilter == null || widget.folderFilter == '')
        ? ''
        : widget.folderFilter!;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditSentenceScreen(initialFolder: presetFolder),
            ),
          );
          setState(() {});
        },
        icon: const Icon(Icons.add),
        label: const Text('Sentence'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search in this folder...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_fill),
                label: const Text('Practice this folder'),
                onPressed: base.isEmpty
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PracticeHubScreen(sentences: base, title: widget.title),
                          ),
                        ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      base.isEmpty
                          ? 'No sentences here yet.\nTap "+ Sentence" to add one.'
                          : 'No matches.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final s = filtered[i];
                      return _SentenceTile(
                        sentence: s,
                        onSpeak: () => tts.speak(s.text),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SentenceDetailScreen(sentence: s),
                            ),
                          );
                          setState(() {});
                        },
                        onDelete: () async {
                          await repo.delete(s.id);
                          setState(() {});
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SentenceTile extends StatelessWidget {
  final Sentence sentence;
  final VoidCallback onSpeak;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SentenceTile({
    required this.sentence,
    required this.onSpeak,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(sentence.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.redAccent),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          onTap: onTap,
          title: Text(sentence.text, style: Theme.of(context).textTheme.bodyLarge),
          subtitle: Text(sentence.meaning, style: Theme.of(context).textTheme.bodyMedium),
          trailing: IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: AppTheme.neonCyan),
            onPressed: onSpeak,
          ),
        ),
      ),
    );
  }
}
