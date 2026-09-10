import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/sentence.dart';
import '../../services/tts_service.dart';
import '../../services/gamification_service.dart';
import '../../theme/app_theme.dart';

class FillBlankScreen extends StatefulWidget {
  final List<Sentence> sentences;
  const FillBlankScreen({super.key, required this.sentences});

  @override
  State<FillBlankScreen> createState() => _FillBlankScreenState();
}

class _FillBlankScreenState extends State<FillBlankScreen> {
  final _rand = Random();
  int _index = 0;
  final _controller = TextEditingController();
  bool _checked = false;
  bool _correct = false;
  late List<String> _words;
  late int _blankPos;
  late String _missingWord;

  // Only sentences with at least 2 words can be used for this module.
  List<Sentence> get _usable =>
      widget.sentences.where((s) => s.text.trim().split(RegExp(r'\s+')).length >= 2).toList();

  @override
  void initState() {
    super.initState();
    _prepareRound();
  }

  void _prepareRound() {
    final usable = _usable;
    if (_index >= usable.length) return;
    final s = usable[_index];
    _words = s.text.trim().split(RegExp(r'\s+'));
    _blankPos = _rand.nextInt(_words.length);
    _missingWord = _words[_blankPos].replaceAll(RegExp(r'[^\w]'), '');
    _controller.clear();
    _checked = false;
  }

  Future<void> _check() async {
    final gamification = context.read<GamificationService>();
    final isCorrect =
        _controller.text.trim().toLowerCase() == _missingWord.toLowerCase();
    setState(() {
      _checked = true;
      _correct = isCorrect;
    });
    if (isCorrect) {
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usable = _usable;
    final done = _index >= usable.length;

    if (usable.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Fill the Blank')),
        body: const Center(child: Text('Add a few longer sentences to unlock this mode.')),
      );
    }

    final s = done ? null : usable[_index];
    final tts = context.read<TtsService>();

    final display = done
        ? ''
        : List.generate(_words.length, (i) => i == _blankPos ? '_____' : _words[i]).join(' ');

    return Scaffold(
      appBar: AppBar(title: const Text('Fill the Blank')),
      body: done
          ? const Center(child: Text('🎉 Done with this set!'))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(value: _index / usable.length),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.glowCard(AppTheme.neonCyan),
                    child: Text(display,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: () => tts.speak(s!.text),
                      icon: const Icon(Icons.volume_up_rounded),
                      label: const Text('Hear full sentence'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    enabled: !_checked,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Missing word...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_checked)
                    Text(
                      _correct ? '✅ Correct!' : '❌ Correct word: $_missingWord',
                      style: TextStyle(
                        color: _correct ? Colors.greenAccent : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _checked ? _next : _check,
                    child: Text(_checked ? 'Next' : 'Check'),
                  ),
                ],
              ),
            ),
    );
  }
}
