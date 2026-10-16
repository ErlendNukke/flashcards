import 'package:flashcards/screens/login_screen.dart';
import 'package:flashcards/screens/sign_up_screen.dart';
import 'package:flashcards/utils/app_scroll.dart';
import 'package:flutter/material.dart';

/// Brand indigo used for launcher icons and web theme.
const Color kFlashcardsIndigo = Color(0xFF3E26A9);

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 720;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: ColoredBox(
              color: theme.colorScheme.surface,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: isWide ? 320 : 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        kFlashcardsIndigo.withValues(alpha: 0.1),
                        theme.colorScheme.surface,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: appScrollPhysics,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: isWide ? 48 : 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RepaintBoundary(child: _HeroHeader(isWide: isWide)),
                      const SizedBox(height: 32),
                      Text(
                        'Write a question on one side and the answer on the other, '
                        'then study until it sticks.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          height: 1.45,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _featureTiles()
                              .map((w) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6),
                                      child: w,
                                    ),
                                  ))
                              .toList(),
                        )
                      else
                        ..._featureTiles().map(
                          (w) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: w,
                          ),
                        ),
                      SizedBox(height: isWide ? 40 : 32),
                      FilledButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SignUpScreen()),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: kFlashcardsIndigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Sign up'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kFlashcardsIndigo,
                          side: const BorderSide(color: kFlashcardsIndigo),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Log in'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _featureTiles() {
    return const [
      _FeatureTile(
        icon: Icons.folder_outlined,
        title: 'Folders',
        description: 'Group cards by subject and keep unfiled decks tidy.',
      ),
      _FeatureTile(
        icon: Icons.swipe,
        title: 'Flip & swipe',
        description: 'Tap to reveal answers, swipe between cards while you study.',
      ),
      _FeatureTile(
        icon: Icons.shuffle,
        title: 'Shuffle',
        description: 'Randomize order when you want a fresh run through the deck.',
      ),
    ];
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = isWide ? 96.0 : 80.0;
    final cachePx = (iconSize * MediaQuery.devicePixelRatioOf(context)).round();
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: kFlashcardsIndigo.withValues(alpha: 0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/icon/app_icon.png',
              width: iconSize,
              height: iconSize,
              fit: BoxFit.cover,
              cacheWidth: cachePx,
              cacheHeight: cachePx,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Flashcards',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: kFlashcardsIndigo,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RepaintBoundary(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: kFlashcardsIndigo, size: 28),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
