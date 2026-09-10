# LinguaLines

Save English sentences with their meaning, hear offline pronunciation, and
practice them through six gamified exercise modes.

## Features
- Save sentences + meaning, fully offline local storage (Hive)
- Offline text-to-speech pronunciation (device's built-in TTS engine — no internet needed)
- Practice modules: Flashcards (spaced repetition), Listening, Meaning Quiz,
  Dictation, Fill the Blank, Speaking (record & compare)
- Gamification: XP, Levels, Daily Streaks, Coins, Achievements
- Optional looping background music (auto-ducks during TTS/recording playback)
- Dark neon UI theme

## Getting the app onto GitHub
1. Create a new empty repository on GitHub (e.g. `lingualines`).
2. From this project folder:
   ```bash
   git init
   git add .
   git commit -m "Initial LinguaLines project"
   git branch -M main
   git remote add origin https://github.com/<your-username>/<your-repo>.git
   git push -u origin main
   ```
3. Push triggers `.github/workflows/build-apk.yml` automatically. Check the
   **Actions** tab on GitHub — when the run finishes, download the built APK
   from the workflow's **Artifacts** section.

## Background music
This repo does **not** include a music file (to avoid any copyright issues).
Add your own royalty-free/looping track as:
```
assets/audio/background_loop.mp3
```
If the file is missing, the app runs fine — background music is simply silent
until you add one.

## Building locally (optional)
If you have the Flutter SDK installed:
```bash
flutter create --platforms=android .   # only needed once, generates android/
flutter pub get
flutter run                             # or: flutter build apk --release
```

## Project structure
```
lib/
  models/        Sentence & UserProgress (Hive models, hand-written adapters)
  repositories/   SentenceRepository (CRUD)
  services/       TtsService, BackgroundMusicService, GamificationService
  theme/          AppTheme (dark/neon)
  screens/        HomeScreen, AddEditSentenceScreen, SentenceDetailScreen,
                  PracticeHubScreen, StatsScreen
  screens/practice/  FlashcardScreen, ListeningScreen, QuizScreen,
                      DictationScreen, FillBlankScreen, SpeakingScreen
```

## Notes / next steps
- Android microphone permission (`RECORD_AUDIO`) is required for the Speaking
  module — since `android/` is generated at CI build time, add this
  permission to `android/app/src/main/AndroidManifest.xml` if you build
  locally and the mic doesn't work: 
  `<uses-permission android:name="android.permission.RECORD_AUDIO"/>`
- This is a solid, working foundation covering the full feature set you
  asked for. Feel free to keep extending it (themes shop with coins,
  categories/tags filtering, iOS build job, etc.).
