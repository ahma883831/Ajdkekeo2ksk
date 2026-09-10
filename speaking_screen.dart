import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/sentence.dart';
import '../../services/tts_service.dart';
import '../../services/gamification_service.dart';
import '../../theme/app_theme.dart';

class SpeakingScreen extends StatefulWidget {
  final List<Sentence> sentences;
  const SpeakingScreen({super.key, required this.sentences});

  @override
  State<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends State<SpeakingScreen> {
  int _index = 0;
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  bool _isRecording = false;
  String? _recordingPath;

  Sentence? get _current =>
      _index < widget.sentences.length ? widget.sentences[_index] : null;

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() {
        _isRecording = false;
        _recordingPath = path;
      });
    } else {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/lingualines_take_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _recorder.start(const RecordConfig(), path: path);
        setState(() => _isRecording = true);
      }
    }
  }

  Future<void> _playRecording() async {
    if (_recordingPath == null) return;
    await _player.setFilePath(_recordingPath!);
    await _player.play();
  }

  Future<void> _markPracticed() async {
    final gamification = context.read<GamificationService>();
    await gamification.awardForCorrectAnswer(xp: 8, coins: 1);
    setState(() {
      _index += 1;
      _recordingPath = null;
    });
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tts = context.read<TtsService>();
    final s = _current;

    return Scaffold(
      appBar: AppBar(title: const Text('Speaking')),
      body: s == null
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
                    decoration: AppTheme.glowCard(AppTheme.neonPink),
                    child: Column(
                      children: [
                        Text(s.text,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () => tts.speak(s.text),
                          icon: const Icon(Icons.volume_up_rounded),
                          label: const Text('Hear reference pronunciation'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: GestureDetector(
                      onTap: _toggleRecording,
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor:
                            _isRecording ? Colors.redAccent : AppTheme.neonPurple,
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(_isRecording
                        ? 'Recording... tap to stop'
                        : 'Tap to record yourself'),
                  ),
                  if (_recordingPath != null && !_isRecording) ...[
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: _playRecording,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Play my recording'),
                    ),
                  ],
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _recordingPath != null ? _markPracticed : null,
                    child: const Text('Done — Next Sentence'),
                  ),
                ],
              ),
            ),
    );
  }
}
