import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/sentence.dart';
import 'models/user_progress.dart';
import 'repositories/sentence_repository.dart';
import 'repositories/folder_repository.dart';
import 'services/tts_service.dart';
import 'services/background_music_service.dart';
import 'services/gamification_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(SentenceAdapter());
  Hive.registerAdapter(UserProgressAdapter());
  await Hive.openBox<Sentence>(SentenceRepository.boxName);
  await Hive.openBox<UserProgress>(GamificationService.boxName);
  await Hive.openBox<String>(FolderRepository.boxName);

  final backgroundMusic = BackgroundMusicService();
  await backgroundMusic.init();

  runApp(LinguaLinesApp(backgroundMusic: backgroundMusic));
}

class LinguaLinesApp extends StatelessWidget {
  final BackgroundMusicService backgroundMusic;
  const LinguaLinesApp({super.key, required this.backgroundMusic});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SentenceRepository>(create: (_) => SentenceRepository()),
        Provider<FolderRepository>(create: (_) => FolderRepository()),
        Provider<TtsService>(create: (_) => TtsService()),
        ChangeNotifierProvider<BackgroundMusicService>.value(value: backgroundMusic),
        ChangeNotifierProvider<GamificationService>(
          create: (_) => GamificationService(),
        ),
      ],
      child: MaterialApp(
        title: 'LinguaLines',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const HomeScreen(),
      ),
    );
  }
}
