import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sentence.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import 'add_edit_sentence_screen.dart';

class SentenceDetailScreen extends StatelessWidget {
  final Sentence sentence;
  const SentenceDetailScreen({super.key, required this.sentence});

  @override
  Widget build(BuildContext context) {
    final tts = context.read<TtsService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditSentenceScreen(existing: sentence),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.glowCard(AppTheme.neonPurple),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sentence.text, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  Text(sentence.meaning, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 20),
                  Center(
                    child: IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.volume_up_rounded, color: AppTheme.neonCyan),
                      onPressed: () => tts.speak(sentence.text),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Mastery: ${sentence.masteryLevel}/5', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: sentence.masteryLevel / 5,
              backgroundColor: AppTheme.surface,
              color: AppTheme.neonPink,
            ),
            const SizedBox(height: 12),
            Text(
              'Reviewed ${sentence.timesReviewed} time(s)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
