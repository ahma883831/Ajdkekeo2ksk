import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/sentence.dart';
import '../../services/gamification_service.dart';
import '../../theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  final List<Sentence> sentences;
  const QuizScreen({super.key, required this.sentences});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
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

  void _next() => setState(() {
        _index += 1;
        _prepareRound();
      });

  @override
  Widget build(BuildContext context) {
    final done = _index >= widget.sentences.length;
    final correct = done ? null : widget.sentences[_index];

    return Scaffold(
      appBar: AppBar(title: const Text('Meaning Quiz')),
      body: done
          ? const Center(child: Text('🎉 Done with this set!'))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(value: _index / widget.sentences.length),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.glowCard(AppTheme.neonPurple),
                    child: Text(correct!.text,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium),
                  ),
                  const SizedBox(height: 10),
                  const Center(child: Text('Choose the correct meaning')),
                  const SizedBox(height: 24),
                  ..._choices.map((c) {
                    final isSelected = c.id == _selectedId;
                    final isCorrect = c.id == correct.id;
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
                        child: Text(c.meaning, textAlign: TextAlign.center),
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
