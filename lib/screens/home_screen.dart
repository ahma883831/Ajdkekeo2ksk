import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sentence.dart';
import '../repositories/sentence_repository.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import 'add_edit_sentence_screen.dart';
import 'sentence_detail_screen.dart';
import 'practice_hub_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final repo = context.read<SentenceRepository>();
    final tts = context.read<TtsService>();
    final all = repo.getAll();
    final filtered = _query.isEmpty
        ? all
        : all
            .where((s) =>
                s.text.toLowerCase().contains(_query.toLowerCase()) ||
                s.meaning.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('LinguaLines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatsScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditSentenceScreen()),
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
                hintText: 'Search sentences...',
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
                label: const Text('Start Practice'),
                onPressed: all.isEmpty
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PracticeHubScreen()),
                        ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      all.isEmpty
                          ? 'No sentences yet.\nTap "+ Sentence" to add your first one.'
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
