import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sentence.dart';
import '../repositories/sentence_repository.dart';
import '../services/tts_service.dart';
import '../services/gamification_service.dart';

class AddEditSentenceScreen extends StatefulWidget {
  final Sentence? existing;
  const AddEditSentenceScreen({super.key, this.existing});

  @override
  State<AddEditSentenceScreen> createState() => _AddEditSentenceScreenState();
}

class _AddEditSentenceScreenState extends State<AddEditSentenceScreen> {
  late final TextEditingController _textCtrl;
  late final TextEditingController _meaningCtrl;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.existing?.text ?? '');
    _meaningCtrl = TextEditingController(text: widget.existing?.meaning ?? '');
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _meaningCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_textCtrl.text.trim().isEmpty || _meaningCtrl.text.trim().isEmpty) return;
    final repo = context.read<SentenceRepository>();
    final gamification = context.read<GamificationService>();

    if (widget.existing != null) {
      widget.existing!
        ..text = _textCtrl.text.trim()
        ..meaning = _meaningCtrl.text.trim();
      await repo.update(widget.existing!);
    } else {
      await repo.add(text: _textCtrl.text.trim(), meaning: _meaningCtrl.text.trim());
      await gamification.onSentenceSaved(repo.count);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tts = context.read<TtsService>();
    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Sentence' : 'New Sentence')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'English sentence',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => tts.speak(_textCtrl.text),
                icon: const Icon(Icons.volume_up_rounded),
                label: const Text('Preview pronunciation'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _meaningCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Meaning / translation',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: Text(isEditing ? 'Save Changes' : 'Add Sentence'),
            ),
          ],
        ),
      ),
    );
  }
}
