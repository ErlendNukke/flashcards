import 'dart:math';

import 'package:flashcards/models/flash_card.dart';
import 'package:flashcards/services/study_preferences.dart';
import 'package:flashcards/utils/study_shuffle.dart';
import 'package:flashcards/widgets/flip_card.dart';
import 'package:flutter/material.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({
    super.key,
    required this.title,
    required this.cards,
    this.shuffleRandom,
    StudyPreferences? preferences,
  }) : _preferences = preferences;

  final String title;
  final List<FlashCard> cards;
  final Random? shuffleRandom;
  final StudyPreferences? _preferences;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  late final List<FlashCard> _original;
  late List<FlashCard> _session;
  late int _index;
  late PageController _pageController;
  bool _shuffleEnabled = false;
  final Map<int, int> _visitToken = {};
  late final StudyPreferences _preferences;

  Random get _random => widget.shuffleRandom ?? Random();

  @override
  void initState() {
    super.initState();
    _preferences = widget._preferences ?? StudyPreferences();
    _original = List.of(widget.cards);
    _session = List.of(_original);
    _index = 0;
    _pageController = PageController(initialPage: 0);
    _visitToken[0] = 0;
    _loadPreference();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPreference() async {
    final enabled = await _preferences.isShuffleEnabled();
    if (!mounted) return;
    if (enabled) {
      _applySession(shuffledCopy(_original, _random), shuffleEnabled: true);
    } else {
      setState(() => _shuffleEnabled = false);
    }
  }

  void _applySession(List<FlashCard> session, {required bool shuffleEnabled}) {
    setState(() {
      _shuffleEnabled = shuffleEnabled;
      _session = session;
      _index = 0;
      _visitToken.clear();
      _visitToken[0] = 0;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  void _onPageChanged(int next) {
    if (next == _index) return;
    setState(() {
      _index = next;
      _visitToken[next] = (_visitToken[next] ?? 0) + 1;
    });
  }

  Future<void> _animateToPage(int page) async {
    if (page < 0 || page >= _session.length || page == _index) return;
    await _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _setShuffle(bool enabled) async {
    _applySession(
      enabled ? shuffledCopy(_original, _random) : List.of(_original),
      shuffleEnabled: enabled,
    );
    await _preferences.setShuffleEnabled(enabled);
  }

  void _reshuffle() {
    _applySession(shuffledCopy(_original, _random), shuffleEnabled: true);
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
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _session.length,
                itemBuilder: (context, i) {
                  final card = _session[i];
                  final token = _visitToken[i] ?? 0;
                  return FlipCard(
                    key: ValueKey('${card.id}_$token'),
                    frontLabel: 'Question',
                    frontText: card.question,
                    backLabel: 'Answer',
                    backText: card.answer,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _index > 0 ? () => _animateToPage(_index - 1) : null,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _index < _session.length - 1 ? () => _animateToPage(_index + 1) : null,
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
