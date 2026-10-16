import 'package:flashcards/models/flash_card.dart';
import 'package:flashcards/models/folder.dart';
import 'package:flashcards/screens/card_form_screen.dart';
import 'package:flashcards/screens/study_screen.dart';
import 'package:flashcards/services/card_service.dart';
import 'package:flashcards/services/folder_service.dart';
import 'package:flashcards/utils/app_scroll.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardListScreen extends StatefulWidget {
  const CardListScreen({
    super.key,
    required this.title,
    this.folderId,
    this.unfiledOnly = false,
    this.onChanged,
  });

  final String title;
  final String? folderId;
  final bool unfiledOnly;
  final VoidCallback? onChanged;

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  List<FlashCard>? _cards;
  List<StudyFolder> _folders = [];
  String? _error;
  bool _loading = true;
  bool _selectionMode = false;
  final Set<String> _selected = {};

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
      final cardService = context.read<CardService>();
      final folderService = context.read<FolderService>();
      final cards = await cardService.listCards(
        folderId: widget.unfiledOnly ? null : widget.folderId,
        unfiledOnly: widget.unfiledOnly,
      );
      final library = await folderService.fetchLibrary();
      if (!mounted) return;
      setState(() {
        _cards = cards;
        _folders = library.folders;
        _loading = false;
        _selected.removeWhere((id) => cards.every((c) => c.id != id));
        if (_selected.isEmpty) _selectionMode = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _notifyChanged() {
    widget.onChanged?.call();
  }

  void _enterSelection([String? firstId]) {
    setState(() {
      _selectionMode = true;
      if (firstId != null) _selected.add(firstId);
    });
  }

  void _exitSelection() {
    setState(() {
      _selectionMode = false;
      _selected.clear();
    });
  }

  void _toggleSelected(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
        if (_selected.isEmpty) _selectionMode = false;
      } else {
        _selected.add(id);
      }
    });
  }

  void _selectAll() {
    final cards = _cards ?? [];
    setState(() {
      _selectionMode = true;
      _selected
        ..clear()
        ..addAll(cards.map((c) => c.id));
    });
  }

  Future<void> _openCreate() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CardFormScreen(
          initialFolderId: widget.unfiledOnly ? null : widget.folderId,
          folders: _folders,
        ),
      ),
    );
    if (created == true) {
      await _load();
      _notifyChanged();
    }
  }

  Future<void> _openEdit(FlashCard card) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CardFormScreen(existing: card, folders: _folders),
      ),
    );
    if (saved == true) {
      await _load();
      _notifyChanged();
    }
  }

  Future<void> _bulkDelete() async {
    final count = _selected.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete selected cards?'),
        content: Text('Remove $count card(s)? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await context.read<CardService>().bulkDelete(_selected.toList());
      _exitSelection();
      await _load();
      _notifyChanged();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _bulkMove() async {
    final target = await showDialog<String?>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Move to folder'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ''),
            child: const Text('Unfiled'),
          ),
          ..._folders.map(
            (f) => SimpleDialogOption(
              onPressed: () => Navigator.pop(context, f.id),
              child: Text(f.name),
            ),
          ),
        ],
      ),
    );
    if (target == null || !mounted) return;
    final folderId = target.isEmpty ? null : target;
    try {
      await context.read<CardService>().bulkMove(ids: _selected.toList(), folderId: folderId);
      _exitSelection();
      await _load();
      _notifyChanged();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _startStudy() {
    final cards = _cards;
    if (cards == null || cards.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StudyScreen(title: widget.title, cards: List.of(cards)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectionMode
            ? Text('${ _selected.length} selected')
            : Text(widget.title),
        actions: [
          if (!_selectionMode && (_cards?.isNotEmpty ?? false))
            TextButton(onPressed: () => _enterSelection(), child: const Text('Select')),
          if (_selectionMode) ...[
            TextButton(onPressed: _selectAll, child: const Text('All')),
            TextButton(onPressed: _exitSelection, child: const Text('Cancel')),
          ],
          IconButton(tooltip: 'Refresh', onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: _selectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: _openCreate,
              icon: const Icon(Icons.add),
              label: const Text('New card'),
            ),
      bottomNavigationBar: _selectionMode
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selected.isEmpty ? null : _bulkMove,
                        icon: const Icon(Icons.drive_file_move_outline),
                        label: const Text('Move'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _selected.isEmpty ? null : _bulkDelete,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
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
    final cards = _cards ?? [];
    if (cards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.style_outlined, size: 56, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text('No cards here', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('Add a flashcard to this folder.', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (!_selectionMode)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: _startStudy,
                icon: const Icon(Icons.school_outlined),
                label: Text('Study (${cards.length})'),
              ),
            ),
          ),
        Expanded(
          child: ListView.separated(
            physics: appScrollPhysics,
            padding: EdgeInsets.fromLTRB(16, 16, 16, _selectionMode ? 16 : 96),
            itemCount: cards.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final card = cards[index];
              final selected = _selected.contains(card.id);
              return RepaintBoundary(
                child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    width: selected ? 2 : 1,
                  ),
                ),
                tileColor: Theme.of(context).colorScheme.surface,
                leading: _selectionMode
                    ? Checkbox(
                        value: selected,
                        onChanged: (_) => _toggleSelected(card.id),
                      )
                    : null,
                title: Text(card.question, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(card.answer, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () {
                  if (_selectionMode) {
                    _toggleSelected(card.id);
                  } else {
                    _openEdit(card);
                  }
                },
                onLongPress: () {
                  if (!_selectionMode) _enterSelection(card.id);
                },
                trailing: _selectionMode
                    ? null
                    : PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') _openEdit(card);
                          if (value == 'select') _enterSelection(card.id);
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'select', child: Text('Select')),
                        ],
                      ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
