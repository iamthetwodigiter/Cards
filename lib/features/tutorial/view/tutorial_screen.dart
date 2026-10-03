import 'package:flutter/material.dart';
import '../../game/models/game_models.dart';
import '../../game/widgets/uno_card_widget.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _steps = <_TutorialData>[
    _TutorialData(
      'Match color or number',
      'Play a card that matches the active color or the number/action on the discard pile. Wild cards are always playable.',
      'COLOR OR VALUE',
      'A blue 5 can be played on a red 5 because the value matches.',
      _MatchDemo(),
    ),
    _TutorialData(
      'Use action cards',
      'Skip blocks the next player, Reverse changes direction, and Draw Two adds two cards to the penalty.',
      'ACTION CARDS',
      'Match an action card by its symbol or color.',
      _ActionDemo(),
    ),
    _TutorialData(
      'Wild means choose',
      'A Wild card can be played at any time. Choose the next color immediately after playing it.',
      'WILD CARDS',
      'Wild Draw Four also adds four cards when the game rules allow it.',
      _WildDemo(),
    ),
    _TutorialData(
      'Draw when you cannot play',
      'If your hand has no legal card, draw one. If the new card cannot be used, pass the turn.',
      'DRAW & PASS',
      'Keep your hand moving. The deck is your second chance.',
      _DrawDemo(),
    ),
    _TutorialData(
      'Call UNO at one card',
      'When you are down to one card, call UNO. Another player can catch an uncalled UNO.',
      'ONE CARD LEFT',
      'Tap UNO as soon as your hand reaches one card.',
      _UnoDemo(),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == _steps.length - 1) {
      Navigator.of(context).pop();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final last = _page == _steps.length - 1;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('How to play'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_page + 1}/${_steps.length}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _steps.length,
                onPageChanged: (value) => setState(() => _page = value),
                itemBuilder: (context, index) =>
                    _TutorialPage(data: _steps[index]),
              ),
            ),
            _TutorialControls(
              page: _page,
              total: _steps.length,
              label: last ? 'Done' : 'Next',
              icon: last ? Icons.check_rounded : Icons.arrow_forward_rounded,
              onPressed: _next,
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialData {
  final String title;
  final String description;
  final String eyebrow;
  final String takeaway;
  final Widget demo;

  const _TutorialData(
    this.title,
    this.description,
    this.eyebrow,
    this.takeaway,
    this.demo,
  );
}

class _TutorialPage extends StatelessWidget {
  final _TutorialData data;
  const _TutorialPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 650;
        final stageHeight = compact
            ? 250.0
            : (constraints.maxHeight * .38).clamp(300.0, 500.0).toDouble();

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, compact ? 12 : 20, 20, 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                children: [
                  Text(
                    data.eyebrow,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Text(
                      data.description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: stageHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned(
                          top: -70,
                          right: -50,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: scheme.primary.withValues(alpha: .08),
                            ),
                          ),
                        ),
                        Center(child: data.demo),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Remember',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: scheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                data.takeaway,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: scheme.onPrimaryContainer,
                                      height: 1.35,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TutorialControls extends StatelessWidget {
  final int page;
  final int total;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _TutorialControls({
    required this.page,
    required this.total,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: Text(
                  '${page + 1}/$total',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    minHeight: 7,
                    value: (page + 1) / total,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              FilledButton.icon(
                onPressed: onPressed,
                icon: Icon(icon),
                label: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchDemo extends StatelessWidget {
  const _MatchDemo();
  @override
  Widget build(BuildContext context) => const _CardPair(
    left: UnoCard(color: CardColor.red, value: CardValue.five),
    right: UnoCard(color: CardColor.blue, value: CardValue.five),
    caption: 'same number',
  );
}

class _ActionDemo extends StatelessWidget {
  const _ActionDemo();
  @override
  Widget build(BuildContext context) => const SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DemoCard(
          card: UnoCard(color: CardColor.yellow, value: CardValue.skip),
          label: 'SKIP',
        ),
        SizedBox(width: 14),
        _DemoCard(
          card: UnoCard(color: CardColor.green, value: CardValue.reverse),
          label: 'REVERSE',
        ),
        SizedBox(width: 14),
        _DemoCard(
          card: UnoCard(color: CardColor.blue, value: CardValue.drawTwo),
          label: 'DRAW 2',
        ),
      ],
    ),
  );
}

class _WildDemo extends StatelessWidget {
  const _WildDemo();
  @override
  Widget build(BuildContext context) => const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _DemoCard(
        card: UnoCard(color: CardColor.wild, value: CardValue.wild),
        label: 'WILD',
      ),
      SizedBox(width: 22),
      Icon(Icons.arrow_forward_rounded, size: 34),
      SizedBox(width: 22),
      _ColorChoicePreview(),
    ],
  );
}

class _DrawDemo extends StatelessWidget {
  const _DrawDemo();
  @override
  Widget build(BuildContext context) => const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      HiddenCardWidget(width: 110, height: 165),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 22),
        child: Icon(Icons.arrow_forward_rounded, size: 34),
      ),
      _DemoCard(
        card: UnoCard(color: CardColor.green, value: CardValue.eight),
        label: 'DRAWN',
      ),
    ],
  );
}

class _UnoDemo extends StatelessWidget {
  const _UnoDemo();
  @override
  Widget build(BuildContext context) => const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _DemoCard(
        card: UnoCard(color: CardColor.red, value: CardValue.seven),
        label: 'ONE LEFT',
      ),
      SizedBox(width: 22),
      Icon(Icons.campaign_rounded, size: 38),
      SizedBox(width: 10),
      Text('UNO!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
    ],
  );
}

class _CardPair extends StatelessWidget {
  final UnoCard left;
  final UnoCard right;
  final String caption;
  const _CardPair({
    required this.left,
    required this.right,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DemoCard(card: left, label: 'ACTIVE'),
          const SizedBox(width: 18),
          const Icon(Icons.arrow_forward_rounded, size: 36),
          const SizedBox(width: 18),
          _DemoCard(card: right, label: 'PLAYABLE'),
        ],
      ),
      const SizedBox(height: 10),
      Text(
        caption,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    ],
  );
}

class _DemoCard extends StatelessWidget {
  final UnoCard card;
  final String label;
  const _DemoCard({required this.card, required this.label});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      UnoCardWidget(card: card, width: 90, height: 135),
      const SizedBox(height: 8),
      Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900),
      ),
    ],
  );
}

class _ColorChoicePreview extends StatelessWidget {
  const _ColorChoicePreview();
  @override
  Widget build(BuildContext context) => Container(
    width: 112,
    height: 112,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(22),
    ),
    child: GridView.count(
      crossAxisCount: 2,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 7,
      mainAxisSpacing: 7,
      children: const [
        _ColorDot(Color(0xFFED1C24)),
        _ColorDot(Color(0xFFF9C900)),
        _ColorDot(Color(0xFF16833B)),
        _ColorDot(Color(0xFF0877C9)),
      ],
    ),
  );
}

class _ColorDot extends StatelessWidget {
  final Color color;
  const _ColorDot(this.color);
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
  );
}
