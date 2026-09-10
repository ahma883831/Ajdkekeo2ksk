import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repositories/sentence_repository.dart';
import '../services/gamification_service.dart';
import '../services/background_music_service.dart';
import '../theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  static const Map<String, String> _achievementLabels = {
    '10_sentences': '📚 Saved 10 sentences',
    '50_sentences': '📖 Saved 50 sentences',
    '7_day_streak': '🔥 7-day streak',
    '30_day_streak': '🏆 30-day streak',
  };

  @override
  Widget build(BuildContext context) {
    final gamification = context.watch<GamificationService>();
    final progress = gamification.progress;
    final repo = context.read<SentenceRepository>();
    final music = context.watch<BackgroundMusicService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Progress')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppTheme.glowCard(AppTheme.neonPurple),
            child: Column(
              children: [
                Text('Level ${progress.level}', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress.xp / progress.xpForNextLevel,
                  backgroundColor: AppTheme.background,
                  color: AppTheme.neonCyan,
                ),
                const SizedBox(height: 6),
                Text('${progress.xp} / ${progress.xpForNextLevel} XP'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '${progress.streakCount} days',
                  color: AppTheme.neonPink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.monetization_on,
                  label: 'Coins',
                  value: '${progress.coins}',
                  color: AppTheme.neonCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StatCard(
            icon: Icons.menu_book_rounded,
            label: 'Sentences saved',
            value: '${repo.count}',
            color: AppTheme.neonPurple,
          ),
          const SizedBox(height: 24),
          Text('Achievements', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          if (progress.achievements.isEmpty)
            const Text('No achievements yet — keep practicing!')
          else
            ...progress.achievements.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_achievementLabels[a] ?? a),
              ),
            ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Background music'),
            value: music.enabled,
            onChanged: (v) => music.toggle(v),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glowCard(color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
