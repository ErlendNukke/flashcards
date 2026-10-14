import 'dart:math' show pi;

import 'package:flutter/material.dart';

class FlipCard extends StatefulWidget {
  const FlipCard({
    super.key,
    required this.frontLabel,
    required this.frontText,
    required this.backLabel,
    required this.backText,
    this.onFlip,
  });

  final String frontLabel;
  final String frontText;
  final String backLabel;
  final String backText;
  final ValueChanged<bool>? onFlip;

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_controller.isAnimating) return;
    if (_showFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _showFront = !_showFront);
    widget.onFlip?.call(_showFront);
  }

  void resetToFront() {
    _controller.reset();
    if (!_showFront) {
      setState(() => _showFront = true);
      widget.onFlip?.call(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);
          final showingFront = angle < pi / 2;
          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: showingFront
                ? _CardFace(
                    label: widget.frontLabel,
                    text: widget.frontText,
                    key: const ValueKey('front'),
                  )
                : Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _CardFace(
                      label: widget.backLabel,
                      text: widget.backText,
                      key: const ValueKey('back'),
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({super.key, required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 280),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(height: 1.35),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to flip',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
