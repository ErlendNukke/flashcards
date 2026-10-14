import 'dart:math';

import 'package:flashcards/models/flash_card.dart';
import 'package:flashcards/services/study_preferences.dart';
import 'package:flashcards/utils/study_shuffle.dart';
import 'package:flashcards/widgets/flip_card.dart';
import 'package:flutter/material.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key, required this.title, required this.cards});

  final String title;
  final List<FlashCard> cards;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  late final List<FlashCard> _original;
  late List<FlashCard> _session;
  late int _index;
  bool _shuffleEnabled = false;
  final _preferences = StudyPreferences();

  @override
  void initState() {
    super.initState();
    _original = List.of(widget.cards);
    _session = List.of(_original);
    _index = 0;
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final enabled = await _preferences.isShuffleEnabled();
    if (!mounted) return;
    setState(() {
      _shuffleEnabled = enabled;
      if (enabled) {
        _session = shuffledCopy(_original, Random());
        _index = 0;
      }
    });
  }

  FlashCard get _current => _session[_index];

  void _goTo(int next) {
    if (next < 0 || next >= _session.length) return;
    setState(() => _index = next);
  }

  Future<void> _setShuffle(bool enabled) async {
    final currentId = _session[_index].id;
    setState(() {
      _shuffleEnabled = enabled;
      _session = enabled ? shuffledCopy(_original, Random()) : List.of(_original);
      final newIndex = _session.indexWhere((c) => c.id == currentId);
      _index = newIndex >= 0 ? newIndex : 0;
    });
    await _preferences.setShuffleEnabled(enabled);
  }

  void _reshuffle() {
    final currentId = _session[_index].id;
    setState(() {
      _session = shuffledCopy(_original, Random());
      final newIndex = _session.indexWhere((c) => c.id == currentId);
      _index = newIndex >= 0 ? newIndex : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Study · ${widget.title}'),
        actions: [
          if (_shuffleEnabled)
            IconButton(
              tooltip: 'Reshuffle',
              onPressed: _reshuffle,
              icon: const Icon(Icons.shuffle),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                FilterChip(
                  label: const Text('Shuffle'),
                  selected: _shuffleEnabled,
                  onSelected: _setShuffle,
                  avatar: Icon(
                    _shuffleEnabled ? Icons.shuffle : Icons.shuffle_outlined,
                    size: 18,
                  ),
                ),
                const Spacer(),
                Text('${_index + 1} / ${_session.length}'),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FlipCard(
                key: ValueKey(_current.id),
                frontLabel: 'Question',
                frontText: _current.question,
                backLabel: 'Answer',
                backText: _current.answer,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _index > 0 ? () => _goTo(_index - 1) : null,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _index < _session.length - 1 ? () => _goTo(_index + 1) : null,
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
