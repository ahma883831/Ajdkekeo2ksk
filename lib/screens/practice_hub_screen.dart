import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sentence.dart';
import '../repositories/sentence_repository.dart';
import '../services/gamification_service.dart';
import '../theme/app_theme.dart';
import 'practice/flashcard_screen.dart';
import 'practice/listening_screen.dart';
import 'practice/quiz_screen.dart';
import 'practice/dictation_screen.dart';
import 'practice/fill_blank_screen.dart';
import 'practice/speaking_screen.dart';

class PracticeHubScreen extends StatelessWidget {
  final List<Sentence>? sentences; // null = use all sentences from repo
  final String title;
  const PracticeHubScreen({super.key, this.sentences, this.title = 'Practice'});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<SentenceRepository>();
    final gamification = context.watch<GamificationService>();
    final progress = gamification.progress;
    final scope = sentences ?? repo.getAll();
    final due = sentences == null
        ? repo.dueForReview()
        : scope.where((s) =>
            s.nextReviewDate == null || !s.nextReviewDate!.isAfter(DateTime.now())).toList();

    final modules = [
      _Module('Flashcards', Icons.style_rounded, AppTheme.neonPurple,
          (ctx) => FlashcardScreen(sentences: due.isEmpty ? scope : due)),
      _Module('Listening', Icons.headphones_rounded, AppTheme.neonCyan,
          (ctx) => ListeningScreen(sentences: scope)),
      _Module('Meaning Quiz', Icons.quiz_rounded, AppTheme.neonPink,
          (ctx) => QuizScreen(sentences: scope)),
      _Module('Dictation', Icons.keyboard_rounded, AppTheme.neonPurple,
          (ctx) => DictationScreen(sentences: scope)),
      _Module('Fill the Blank', Icons.text_fields_rounded, AppTheme.neonCyan,
          (ctx) => FillBlankScreen(sentences: scope)),
      _Module('Speaking', Icons.mic_rounded, AppTheme.neonPink,
          (ctx) => SpeakingScreen(sentences: scope)),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _StatChip(icon: Icons.bolt, label: 'Lv ${progress.level}', color: AppTheme.neonPurple),
                const SizedBox(width: 10),
                _StatChip(icon: Icons.local_fire_department, label: '${progress.streakCount}d streak', color: AppTheme.neonPink),
                const SizedBox(width: 10),
                _StatChip(icon: Icons.monetization_on, label: '${progress.coins}', color: AppTheme.neonCyan),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.1,
              ),
              itemCount: modules.length,
              itemBuilder: (context, i) {
                final m = modules[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: m.builder),
                  ),
                  child: Container(
                    decoration: AppTheme.glowCard(m.color),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(m.icon, size: 40, color: m.color),
                        const SizedBox(height: 12),
                        Text(m.title, textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Module {
  final String title;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
  _Module(this.title, this.icon, this.color, this.builder);
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
