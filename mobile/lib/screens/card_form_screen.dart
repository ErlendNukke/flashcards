import 'package:flashcards/models/flash_card.dart';
import 'package:flashcards/services/card_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardFormScreen extends StatefulWidget {
  const CardFormScreen({super.key, this.existing});

  final FlashCard? existing;

  bool get isEdit => existing != null;

  @override
  State<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends State<CardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _question;
  late final TextEditingController _answer;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _question = TextEditingController(text: widget.existing?.question ?? '');
    _answer = TextEditingController(text: widget.existing?.answer ?? '');
  }

  @override
  void dispose() {
    _question.dispose();
    _answer.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final service = context.read<CardService>();
      if (widget.isEdit) {
        await service.updateCard(
          id: widget.existing!.id,
          question: _question.text.trim(),
          answer: _answer.text.trim(),
        );
      } else {
        await service.createCard(
          question: _question.text.trim(),
          answer: _answer.text.trim(),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit card' : 'New card'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Front (question)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _question,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'What do you want to remember?'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Question is required' : null,
            ),
            const SizedBox(height: 20),
            Text(
              'Back (answer)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _answer,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'The answer or explanation'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Answer is required' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.isEdit ? 'Save changes' : 'Create card'),
            ),
          ],
        ),
      ),
    );
  }
}
