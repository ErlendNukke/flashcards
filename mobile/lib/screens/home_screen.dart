import 'package:flashcards/models/folder.dart';
import 'package:flashcards/screens/card_list_screen.dart';
import 'package:flashcards/services/auth_service.dart';
import 'package:flashcards/services/folder_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LibrarySummary? _library;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final library = await context.read<FolderService>().fetchLibrary();
      if (!mounted) return;
      setState(() {
        _library = library;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _createFolder() async {
    final name = await _promptFolderName(context, title: 'New folder', initial: '');
    if (name == null || !mounted) return;
    try {
      await context.read<FolderService>().createFolder(name);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _renameFolder(StudyFolder folder) async {
    final name = await _promptFolderName(context, title: 'Rename folder', initial: folder.name);
    if (name == null || !mounted) return;
    try {
      await context.read<FolderService>().renameFolder(id: folder.id, name: name);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _deleteFolder(StudyFolder folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete folder?'),
        content: Text(
          'Delete "${folder.name}"? Its ${folder.cardCount} card(s) will move to Unfiled.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await context.read<FolderService>().deleteFolder(folder.id);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _openFolder(StudyFolder folder) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CardListScreen(
          title: folder.name,
          folderId: folder.id,
          onChanged: _load,
        ),
      ),
    ).then((_) => _load());
  }

  void _openUnfiled() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CardListScreen(
          title: 'Unfiled',
          unfiledOnly: true,
          onChanged: _load,
        ),
      ),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        actions: [
          IconButton(tooltip: 'Refresh', onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh)),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await context.read<AuthService>().logout();
              }
            },
            itemBuilder: (context) {
              final username = context.read<AuthService>().user?.username ?? '';
              return [
                PopupMenuItem(enabled: false, child: Text(username, style: const TextStyle(fontWeight: FontWeight.w600))),
                const PopupMenuItem(value: 'logout', child: Text('Log out')),
              ];
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createFolder,
        icon: const Icon(Icons.add),
        label: const Text('New folder'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: const Text('Try again')),
            ],
          ),
        ),
      );
    }
    final library = _library!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        _FolderTile(
          icon: Icons.inbox_outlined,
          title: 'Unfiled',
          subtitle: '${library.unfiledCount} card(s)',
          onTap: _openUnfiled,
        ),
        const SizedBox(height: 8),
        if (library.folders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(
              'Create a folder to organize your cards (e.g. Biology, Chemistry).',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ...library.folders.map(
          (folder) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _FolderTile(
              icon: Icons.folder_outlined,
              title: folder.name,
              subtitle: '${folder.cardCount} card(s)',
              onTap: () => _openFolder(folder),
              onRename: () => _renameFolder(folder),
              onDelete: () => _deleteFolder(folder),
            ),
          ),
        ),
      ],
    );
  }
}

class _FolderTile extends StatelessWidget {
  const _FolderTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onRename,
    this.onDelete,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      tileColor: Theme.of(context).colorScheme.surface,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      onTap: onTap,
      trailing: onRename != null
          ? PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'rename') onRename!();
                if (value == 'delete') onDelete!();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'rename', child: Text('Rename')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            )
          : null,
    );
  }
}

Future<String?> _promptFolderName(
  BuildContext context, {
  required String title,
  required String initial,
}) async {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(hintText: 'Folder name'),
        maxLength: 120,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(context, name);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
