import 'package:google_mlkit_translation/google_mlkit_translation.dart';

/// Uses Google ML Kit's on-device translation to auto-fill the Persian
/// meaning of an English sentence. The language models are downloaded once
/// (requires internet the first time only) and cached on-device — every
/// translation after that runs fully offline, with no server calls.
class TranslationService {
  final OnDeviceTranslatorModelManager _modelManager =
      OnDeviceTranslatorModelManager();
  OnDeviceTranslator? _translator;

  Future<bool> get modelsReady async {
    final en = await _modelManager.isModelDownloaded(TranslateLanguage.english.bcpCode);
    final fa = await _modelManager.isModelDownloaded(TranslateLanguage.persian.bcpCode);
    return en && fa;
  }

  /// Downloads the English + Persian models if not already on-device.
  /// [onProgress] is called with a short status string for UI feedback.
  Future<void> ensureModelsDownloaded({void Function(String status)? onProgress}) async {
    final enDownloaded = await _modelManager.isModelDownloaded(TranslateLanguage.english.bcpCode);
    if (!enDownloaded) {
      onProgress?.call('در حال دانلود مدل انگلیسی...');
      await _modelManager.downloadModel(TranslateLanguage.english.bcpCode);
    }
    final faDownloaded = await _modelManager.isModelDownloaded(TranslateLanguage.persian.bcpCode);
    if (!faDownloaded) {
      onProgress?.call('در حال دانلود مدل فارسی...');
      await _modelManager.downloadModel(TranslateLanguage.persian.bcpCode);
    }
  }

  Future<String> translateToPersian(String text) async {
    await ensureModelsDownloaded();
    _translator ??= OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.persian,
    );
    return _translator!.translateText(text);
  }

  void dispose() {
    _translator?.close();
  }
}
