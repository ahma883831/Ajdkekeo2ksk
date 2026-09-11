import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repositories/sentence_repository.dart';
import '../repositories/folder_repository.dart';
import '../theme/app_theme.dart';
import 'folder_detail_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _createFolder() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Folder name, e.g. Idioms'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await context.read<FolderRepository>().create(name);
      setState(() {});
    }
  }

  Future<void> _deleteFolder(String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Folder?'),
        content: Text(
            'Delete "$name"? Sentences inside will move to Uncategorized, not be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      await context.read<FolderRepository>().delete(name);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final sentenceRepo = context.read<SentenceRepository>();
    final folderRepo = context.read<FolderRepository>();
    final folders = folderRepo.getAll();
    final totalCount = sentenceRepo.count;
    final uncategorizedCount = sentenceRepo.getByFolder('').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LinguaLines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
              setState(() {});
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createFolder,
        icon: const Icon(Icons.create_new_folder_rounded),
        label: const Text('Folder'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _FolderTile(
            icon: Icons.all_inbox_rounded,
            color: AppTheme.neonCyan,
            title: 'All Sentences',
            subtitle: '$totalCount sentence(s)',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FolderDetailScreen(folderFilter: null, title: 'All Sentences'),
                ),
              );
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          _FolderTile(
            icon: Icons.folder_open_rounded,
            color: AppTheme.textSecondary,
            title: 'Uncategorized',
            subtitle: '$uncategorizedCount sentence(s)',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FolderDetailScreen(folderFilter: '', title: 'Uncategorized'),
                ),
              );
              setState(() {});
            },
          ),
          const SizedBox(height: 20),
          if (folders.isNotEmpty) ...[
            Text('Your Folders', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 10),
          ],
          ...folders.map((f) {
            final count = sentenceRepo.getByFolder(f).length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FolderTile(
                icon: Icons.folder_rounded,
                color: AppTheme.neonPurple,
                title: f,
                subtitle: '$count sentence(s)',
                onLongPress: () => _deleteFolder(f),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FolderDetailScreen(folderFilter: f, title: f),
                    ),
                  );
                  setState(() {});
                },
              ),
            );
          }),
          if (folders.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'No folders yet.\nTap "+ Folder" to create one, e.g. "Idioms" or "Travel".',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FolderTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _FolderTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.glowCard(color),
        child: Row(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
