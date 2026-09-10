import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/sentence.dart';
import '../../services/tts_service.dart';
import '../../services/gamification_service.dart';
import '../../theme/app_theme.dart';

class ListeningScreen extends StatefulWidget {
  final List<Sentence> sentences;
  const ListeningScreen({super.key, required this.sentences});

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  final _rand = Random();
  int _index = 0;
  List<Sentence> _choices = [];
  String? _selectedId;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _prepareRound();
  }

  void _prepareRound() {
    if (_index >= widget.sentences.length) return;
    final correct = widget.sentences[_index];
    final pool = widget.sentences.where((s) => s.id != correct.id).toList()..shuffle(_rand);
    final wrongOptions = pool.take(min(3, pool.length)).toList();
    _choices = [correct, ...wrongOptions]..shuffle(_rand);
    _selectedId = null;
    _answered = false;
  }

  Future<void> _select(Sentence choice) async {
    if (_answered) return;
    final correct = widget.sentences[_index];
    final gamification = context.read<GamificationService>();
    setState(() {
      _selectedId = choice.id;
      _answered = true;
    });
    if (choice.id == correct.id) {
      await gamification.awardForCorrectAnswer();
    } else {
      await gamification.awardForWrongAnswer();
    }
  }

  void _next() {
    setState(() {
      _index += 1;
      _prepareRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tts = context.read<TtsService>();
    final done = _index >= widget.sentences.length;
    final correct = done ? null : widget.sentences[_index];

    return Scaffold(
      appBar: AppBar(title: const Text('Listening')),
      body: done
          ? const Center(child: Text('🎉 Done with this set!'))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(value: _index / widget.sentences.length),
                  const SizedBox(height: 30),
                  Center(
                    child: IconButton(
                      iconSize: 72,
                      icon: const Icon(Icons.volume_up_rounded, color: AppTheme.neonCyan),
                      onPressed: () => tts.speak(correct!.text),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(child: Text('Tap to listen, then choose what you heard')),
                  const SizedBox(height: 24),
                  ..._choices.map((c) {
                    final isSelected = c.id == _selectedId;
                    final isCorrect = c.id == correct!.id;
                    Color? color;
                    if (_answered) {
                      if (isCorrect) color = Colors.greenAccent;
                      else if (isSelected) color = Colors.redAccent;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: color ?? AppTheme.neonPurple),
                        ),
                        onPressed: () => _select(c),
                        child: Text(c.text, textAlign: TextAlign.center),
                      ),
                    );
                  }),
                  if (_answered)
                    ElevatedButton(onPressed: _next, child: const Text('Next')),
                ],
              ),
            ),
    );
  }
}
