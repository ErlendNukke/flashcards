import 'package:flashcards/models/flash_card.dart';
import 'package:flashcards/widgets/flip_card.dart';
import 'package:flutter/material.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key, required this.cards});

  final List<FlashCard> cards;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = 0;
  }

  FlashCard get _current => widget.cards[_index];

  void _goTo(int next) {
    if (next < 0 || next >= widget.cards.length) return;
    setState(() => _index = next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Study · ${_index + 1} / ${widget.cards.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                    onPressed: _index < widget.cards.length - 1 ? () => _goTo(_index + 1) : null,
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
