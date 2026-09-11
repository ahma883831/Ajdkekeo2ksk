import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sentence.dart';
import '../repositories/sentence_repository.dart';
import '../services/tts_service.dart';
import '../services/translation_service.dart';
import '../services/gamification_service.dart';

class AddEditSentenceScreen extends StatefulWidget {
  final Sentence? existing;
  final String initialFolder;
  const AddEditSentenceScreen({super.key, this.existing, this.initialFolder = ''});

  @override
  State<AddEditSentenceScreen> createState() => _AddEditSentenceScreenState();
}

class _AddEditSentenceScreenState extends State<AddEditSentenceScreen> {
  late final TextEditingController _textCtrl;
  late final TextEditingController _meaningCtrl;
  late final TextEditingController _folderCtrl;
  bool _translating = false;
  String? _translationStatus;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.existing?.text ?? '');
    _meaningCtrl = TextEditingController(text: widget.existing?.meaning ?? '');
    _folderCtrl = TextEditingController(text: widget.existing?.folder ?? widget.initialFolder);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _meaningCtrl.dispose();
    _folderCtrl.dispose();
    super.dispose();
  }

  Future<void> _autoTranslate() async {
    if (_textCtrl.text.trim().isEmpty) return;
    final translator = context.read<TranslationService>();
    setState(() {
      _translating = true;
      _translationStatus = null;
    });
    try {
      await translator.ensureModelsDownloaded(
        onProgress: (status) => setState(() => _translationStatus = status),
      );
      final result = await translator.translateToPersian(_textCtrl.text.trim());
      setState(() => _meaningCtrl.text = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ترجمه ناموفق بود. دوباره امتحان کن.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _translating = false;
          _translationStatus = null;
        });
      }
    }
  }

  Future<void> _save() async {
    if (_textCtrl.text.trim().isEmpty) return;
    final repo = context.read<SentenceRepository>();
    final gamification = context.read<GamificationService>();
    final translator = context.read<TranslationService>();

    // If the user left the meaning blank, translate automatically before saving.
    if (_meaningCtrl.text.trim().isEmpty) {
      setState(() {
        _translating = true;
        _translationStatus = 'در حال ترجمه خودکار...';
      });
      try {
        await translator.ensureModelsDownloaded(
          onProgress: (status) => setState(() => _translationStatus = status),
        );
        final result = await translator.translateToPersian(_textCtrl.text.trim());
        setState(() => _meaningCtrl.text = result);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ترجمه خودکار ناموفق بود. معنی رو دستی بنویس.')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _translating = false;
            _translationStatus = null;
          });
        }
      }
    }

    if (_meaningCtrl.text.trim().isEmpty) return; // still empty (translation failed)

    if (widget.existing != null) {
      widget.existing!
        ..text = _textCtrl.text.trim()
        ..meaning = _meaningCtrl.text.trim()
        ..folder = _folderCtrl.text.trim();
      await repo.update(widget.existing!);
    } else {
      await repo.add(
        text: _textCtrl.text.trim(),
        meaning: _meaningCtrl.text.trim(),
        folder: _folderCtrl.text.trim(),
      );
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
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _translating ? null : _autoTranslate,
                icon: _translating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.translate_rounded),
                label: Text(_translating
                    ? (_translationStatus ?? 'در حال ترجمه...')
                    : 'پیش‌نمایش ترجمه'),
              ),
            ),
            TextField(
              controller: _meaningCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Meaning / translation (خالی بذار تا خودکار پر بشه)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Builder(builder: (context) {
              final repo = context.read<SentenceRepository>();
              final folders = repo.getFolders();
              return Autocomplete<String>(
                optionsBuilder: (value) {
                  if (value.text.isEmpty) return folders;
                  return folders.where((f) => f.toLowerCase().contains(value.text.toLowerCase()));
                },
                initialValue: TextEditingValue(text: _folderCtrl.text),
                fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                  controller.text = _folderCtrl.text;
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Folder / Category (e.g. Idioms, Travel) — optional',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.folder_outlined),
                    ),
                    onChanged: (v) => _folderCtrl.text = v,
                  );
                },
                onSelected: (v) => setState(() => _folderCtrl.text = v),
              );
            }),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _translating ? null : _save,
              child: _translating
                  ? const Text('در حال ترجمه...')
                  : Text(isEditing ? 'Save Changes' : 'Add Sentence'),
            ),
          ],
        ),
      ),
    );
  }
}
