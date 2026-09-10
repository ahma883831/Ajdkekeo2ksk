import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/sentence.dart';
import '../../services/tts_service.dart';
import '../../services/gamification_service.dart';
import '../../theme/app_theme.dart';

class DictationScreen extends StatefulWidget {
  final List<Sentence> sentences;
  const DictationScreen({super.key, required this.sentences});

  @override
  State<DictationScreen> createState() => _DictationScreenState();
}

class _DictationScreenState extends State<DictationScreen> {
  int _index = 0;
  final _controller = TextEditingController();
  bool _checked = false;
  bool _correct = false;

  Sentence? get _current =>
      _index < widget.sentences.length ? widget.sentences[_index] : null;

  String _normalize(String s) =>
      s.trim().toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');

  Future<void> _check() async {
    final s = _current!;
    final isCorrect = _normalize(_controller.text) == _normalize(s.text);
    final gamification = context.read<GamificationService>();
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

  void _next() {
    setState(() {
      _index += 1;
      _controller.clear();
      _checked = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tts = context.read<TtsService>();
    final s = _current;

    return Scaffold(
      appBar: AppBar(title: const Text('Dictation')),
      body: s == null
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
                      onPressed: () => tts.speak(s.text),
                    ),
                  ),
                  const Center(child: Text('Listen and type exactly what you hear')),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    enabled: !_checked,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Type the sentence...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_checked)
                    Text(
                      _correct ? '✅ Correct!' : '❌ Correct answer: ${s.text}',
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
