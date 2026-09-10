import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/sentence.dart';
import '../../repositories/sentence_repository.dart';
import '../../services/tts_service.dart';
import '../../services/gamification_service.dart';
import '../../theme/app_theme.dart';

class FlashcardScreen extends StatefulWidget {
  final List<Sentence> sentences;
  const FlashcardScreen({super.key, required this.sentences});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int _index = 0;
  bool _revealed = false;

  Sentence? get _current =>
      _index < widget.sentences.length ? widget.sentences[_index] : null;

  Future<void> _rate(bool knewIt) async {
    final repo = context.read<SentenceRepository>();
    final gamification = context.read<GamificationService>();
    final s = _current!;
    s.registerReview(wasCorrect: knewIt);
    await repo.update(s);
    if (knewIt) {
      await gamification.awardForCorrectAnswer();
    } else {
      await gamification.awardForWrongAnswer();
    }
    setState(() {
      _index += 1;
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tts = context.read<TtsService>();
    final s = _current;

    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards')),
      body: s == null
          ? const Center(child: Text('🎉 Done with this set!'))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  LinearProgressIndicator(value: _index / widget.sentences.length),
                  const SizedBox(height: 30),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _revealed = !_revealed),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: AppTheme.glowCard(AppTheme.neonPurple),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(s.text,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headlineMedium),
                              const SizedBox(height: 20),
                              IconButton(
                                iconSize: 40,
                                icon: const Icon(Icons.volume_up_rounded, color: AppTheme.neonCyan),
                                onPressed: () => tts.speak(s.text),
                              ),
                              if (_revealed) ...[
                                const Divider(height: 40),
                                Text(s.meaning,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyLarge),
                              ] else
                                Text('Tap card to reveal meaning',
                                    style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_revealed)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _rate(false),
                            child: const Text('Didn\'t know'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _rate(true),
                            child: const Text('Knew it!'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}
