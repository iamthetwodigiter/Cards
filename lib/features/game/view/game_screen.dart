import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../models/game_models.dart';
import '../viewmodel/game_viewmodel.dart';
import '../widgets/uno_card_widget.dart';
import '../../../core/widgets/local_avatar.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String playerName;
  final String avatar;

  const GameScreen({
    super.key,
    required this.roomId,
    required this.playerName,
    required this.avatar,
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  StreamSubscription<GameEvent>? _events;
  bool _showingEvent = false;
  bool? _landscapeLocked;

  GameViewModel get _vm => ref.read(
    gameViewModelProvider(
      widget.roomId,
      widget.playerName,
      avatar: widget.avatar,
    ).notifier,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _events = _vm.eventStream.listen(_handleEvent);
    });
  }

  @override
  void dispose() {
    _events?.cancel();
    super.dispose();
  }

  void _handleEvent(GameEvent event) {
    if (!mounted) return;
    final player = event.data['player_name']?.toString();
    switch (event.event) {
      case 'uno_called':
        _showEvent(
          'UNO!',
          '${player ?? 'A player'} called UNO.',
          Icons.campaign_rounded,
        );
        break;
      case 'uno_missed':
        _showEvent(
          'CAUGHT!',
          '${event.data['catcher_name'] ?? 'A player'} caught ${player ?? 'a player'}.',
          Icons.gavel_rounded,
        );
        break;
      case 'player_won':
        _showEvent(
          'ROUND WIN!',
          '${player ?? 'A player'} finished first · +${event.data['score'] ?? 0} pts',
          Icons.emoji_events_rounded,
        );
        break;
      case 'game_over':
        _showEvent(
          'GAME OVER',
          '${event.data['loser_name'] ?? 'A player'} lost the game.',
          Icons.flag_rounded,
        );
        break;
      case 'emoji_reaction':
        _showSnack('${player ?? 'Player'} ${event.data['emoji'] ?? ''}');
        break;
      case 'shuffle_completed':
        _showSnack('Deck reshuffled');
        break;
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1400),
        ),
      );
  }

  void _showEvent(String title, String subtitle, IconData icon) {
    if (_showingEvent) return;
    _showingEvent = true;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .72),
      builder: (dialogContext) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() => _showingEvent = false);
    Future.delayed(const Duration(milliseconds: 1700), () {
      if (mounted && _showingEvent && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  void _setOrientation(bool landscape) {
    if (_landscapeLocked == landscape) return;
    _landscapeLocked = landscape;
    SystemChrome.setPreferredOrientations(
      landscape
          ? const [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]
          : const [
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      gameViewModelProvider(
        widget.roomId,
        widget.playerName,
        avatar: widget.avatar,
      ),
    );
    if (state == null) return const _ConnectingView();
    if (state.status == GameStatus.waiting) {
      _setOrientation(false);
      return _waitingRoom(state: state);
    }
    _setOrientation(true);
    return _gameTable(state: state);
  }

  Widget _waitingRoom({required GameState state}) {
    final scheme = Theme.of(context).colorScheme;
    final isHost =
        state.players.isNotEmpty &&
        state.players.first.name == widget.playerName;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton.filledTonal(
          onPressed: _leave,
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Leave room',
        ),
        actionsPadding: const EdgeInsets.only(right: 15),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${state.players.length} / 10',
              style: TextStyle(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Waiting room',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Room ${widget.roomId}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.qr_code_2_rounded,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Share this code',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: scheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.roomId,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.5,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: _copyRoom,
                        icon: const Icon(Icons.copy_rounded),
                        tooltip: 'Copy',
                      ),
                      const SizedBox(width: 4),
                      IconButton.filledTonal(
                        onPressed: _shareRoom,
                        icon: const Icon(Icons.share_rounded),
                        tooltip: 'Share',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Players',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const Spacer(),
                          Text(
                            state.players.isEmpty
                                ? 'Waiting…'
                                : '${state.players.length} joined',
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (state.players.isEmpty)
                        const SizedBox(
                          height: 42,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: state.players.map(_playerChip).toList(),
                        ),
                    ],
                  ),
                ),
              ),
              // const SizedBox(height: 12),
              const Spacer(),
              if (isHost && state.players.length >= 2)
                SizedBox(
                  width: 320,
                  child: FilledButton.icon(
                    onPressed: _vm.startGame,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start game'),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.hourglass_top_rounded, color: scheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.players.length < 2
                              ? 'Share the code and wait for another player.'
                              : 'Waiting for the host to start the game.',
                          style: TextStyle(color: scheme.onSurfaceVariant),
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
  }

  Widget _playerChip(Player p) {
    final scheme = Theme.of(context).colorScheme;
    final mine = p.name == widget.playerName;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: mine ? scheme.primaryContainer : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: mine ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Avatar(seed: p.name, size: 26),
          const SizedBox(width: 7),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              p.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (mine)
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                'YOU',
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _gameTable({required GameState state}) {
    final myIndex = state.players.indexWhere(
      (p) => p.name == widget.playerName,
    );
    if (myIndex < 0) return const _ConnectingView(label: 'Rejoining table…');
    final me = state.players[myIndex];
    final opponents = state.players
        .where((p) => p.name != widget.playerName)
        .toList();
    final isMyTurn = state.currentTurnIndex == myIndex;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && await _showExitDialog()) _leave();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF071A2E),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.15,
              colors: [Color(0xFF0D5AA7), Color(0xFF071A2E)],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    _topBar(
                      state: state,
                      opponents: opponents,
                      isMyTurn: isMyTurn,
                    ),
                    Expanded(
                      child: _board(state: state, isMyTurn: isMyTurn),
                    ),
                    _handPanel(
                      state: state,
                      me: me,
                      isMyTurn: isMyTurn,
                      availableHeight: constraints.maxHeight * .30,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar({
    required GameState state,
    required List<Player> opponents,
    required bool isMyTurn,
  }) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
    child: Row(
      children: [
        IconButton.filledTonal(
          onPressed: _leave,
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Leave',
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: opponents
                  .map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _OpponentPill(
                        player: p,
                        active:
                            state.players.indexOf(p) == state.currentTurnIndex,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        _TurnPill(active: isMyTurn),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: _openInfo,
          icon: const Icon(Icons.info_outline_rounded),
          tooltip: 'Game info',
        ),
      ],
    ),
  );

  Widget _board({required GameState state, required bool isMyTurn}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight = constraints.maxHeight.clamp(92.0, 148.0).toDouble();
        final cardWidth = cardHeight * 2 / 3;
        if (state.status == GameStatus.finished) {
          final winners = state.players.where((p) => p.isWinner);
          final winner = winners.isEmpty ? null : winners.first;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 42,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        winner == null
                            ? 'Round complete'
                            : '${winner.name} wins!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: _vm.restartGame,
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('Next round'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _deckButton(
                  state: state,
                  enabled: isMyTurn,
                  width: cardWidth,
                  height: cardHeight,
                ),
                const SizedBox(width: 18),
                if (state.discardPile.isNotEmpty)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: UnoCardWidget(
                      key: ValueKey(state.discardPile.length),
                      card: state.discardPile.last,
                      width: cardWidth,
                      height: cardHeight,
                    ),
                  )
                else
                  SizedBox(width: cardWidth, height: cardHeight),
                if (state.currentColor != null) ...[
                  const SizedBox(width: 12),
                  _ColorBadge(color: state.currentColor!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _deckButton({
    required GameState state,
    required bool enabled,
    required double width,
    required double height,
  }) => GestureDetector(
    onTap: enabled
        ? () {
            HapticFeedback.lightImpact();
            _vm.drawCard();
          }
        : null,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        HiddenCardWidget(width: width, height: height),
        Positioned(
          right: -10,
          bottom: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              '${state.deckCount}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _handPanel({
    required GameState state,
    required Player me,
    required bool isMyTurn,
    required double availableHeight,
  }) {
    final canDraw = isMyTurn && state.pendingPenalty == 0;
    final canCall = me.handCount == 1 && !me.unoCalled;
    final panelHeight = availableHeight.clamp(150.0, 220.0).toDouble();
    return Container(
      height: panelHeight,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .22),
        border: Border(
          top: BorderSide(
            color: isMyTurn ? const Color(0xFF8AB4F8) : Colors.white10,
            width: isMyTurn ? 2 : 1,
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 34,
            child: Row(
              children: [
                _Avatar(seed: me.name, size: 28),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    '${me.name} · ${me.score} pts',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isMyTurn) const _TurnPill(active: true, compact: true),
                const SizedBox(width: 5),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: _showEmojiPicker,
                        icon: const Icon(
                          Icons.emoji_emotions_outlined,
                          size: 19,
                        ),
                        tooltip: 'Emoji',
                      ),
                      if (state.players.any(
                        (p) =>
                            p.name != widget.playerName &&
                            p.handCount == 1 &&
                            !p.unoCalled,
                      ))
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: FilledButton.tonalIcon(
                            onPressed: () {
                              final target = state.players.firstWhere(
                                (p) =>
                                    p.name != widget.playerName &&
                                    p.handCount == 1 &&
                                    !p.unoCalled,
                              );
                              _vm.catchUno(target.id);
                            },
                            icon: const Icon(Icons.gavel_rounded, size: 18),
                            label: const Text('Catch'),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: FilledButton.tonalIcon(
                          onPressed: canCall ? _vm.sayUno : null,
                          icon: const Icon(Icons.campaign_outlined, size: 18),
                          label: const Text('UNO'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: state.hasDrawn && isMyTurn
                            ? FilledButton.tonal(
                                onPressed: _vm.passTurn,
                                child: const Text('Pass'),
                              )
                            : FilledButton.tonalIcon(
                                onPressed: canDraw ? _vm.drawCard : null,
                                icon: const Icon(
                                  Icons.style_outlined,
                                  size: 18,
                                ),
                                label: const Text('Draw'),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              itemCount: me.hand.length,
              separatorBuilder: (_, __) => const SizedBox(width: 5),
              itemBuilder: (context, index) {
                final card = me.hand[index];
                final playable = _canPlay(card, state);
                return AnimatedOpacity(
                  opacity: isMyTurn && !playable ? .42 : 1,
                  duration: const Duration(milliseconds: 160),
                  child: UnoCardWidget(
                    card: card,
                    width: 64,
                    height: 96,
                    enabled: isMyTurn && playable,
                    onTap: isMyTurn && playable
                        ? () => _playCard(card, index)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _canPlay(UnoCard card, GameState state) {
    if (state.pendingPenalty > 0) {
      if (!state.stackingEnabled || state.discardPile.isEmpty) return false;
      final top = state.discardPile.last.value;
      return (top == CardValue.drawTwo && card.value == CardValue.drawTwo) ||
          (top == CardValue.wildDrawFour &&
              card.value == CardValue.wildDrawFour);
    }
    if (card.color == CardColor.wild) return true;
    if (card.color == state.currentColor) return true;
    return state.discardPile.isNotEmpty &&
        card.value == state.discardPile.last.value;
  }

  void _playCard(UnoCard card, int index) {
    HapticFeedback.selectionClick();
    if (card.color == CardColor.wild) {
      _showColorPicker(index);
    } else {
      _vm.playCard(index);
    }
  }

  Future<void> _showColorPicker(int index) async {
    final color = await showModalBottomSheet<CardColor>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose the next color',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ColorChoice(
                    color: CardColor.red,
                    onTap: () => Navigator.pop(ctx, CardColor.red),
                  ),
                  _ColorChoice(
                    color: CardColor.blue,
                    onTap: () => Navigator.pop(ctx, CardColor.blue),
                  ),
                  _ColorChoice(
                    color: CardColor.green,
                    onTap: () => Navigator.pop(ctx, CardColor.green),
                  ),
                  _ColorChoice(
                    color: CardColor.yellow,
                    onTap: () => Navigator.pop(ctx, CardColor.yellow),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (color != null) _vm.playCard(index, chosenColor: color);
  }

  void _showEmojiPicker() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SizedBox(
        height: 330,
        child: EmojiPicker(
          onEmojiSelected: (_, emoji) {
            _vm.sendEmoji(emoji.emoji);
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  void _openInfo() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Table ${widget.roomId}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              _InfoLine('Direction', stateDirection(ref)),
              _InfoLine(
                'Stacking',
                ref
                            .read(
                              gameViewModelProvider(
                                widget.roomId,
                                widget.playerName,
                                avatar: widget.avatar,
                              ),
                            )
                            ?.stackingEnabled ==
                        true
                    ? 'On'
                    : 'Off',
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _copyRoom();
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy room code'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _shareRoom();
                },
                icon: const Icon(Icons.share),
                label: const Text('Share room'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String stateDirection(WidgetRef ref) {
    final s = ref.read(
      gameViewModelProvider(
        widget.roomId,
        widget.playerName,
        avatar: widget.avatar,
      ),
    );
    return s?.direction == 1 ? 'Clockwise' : 'Counter-clockwise';
  }

  Future<bool> _showExitDialog() async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Leave game?'),
          content: const Text(
            'You can rejoin this room later with the same room code.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Stay'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Leave'),
            ),
          ],
        ),
      ) ??
      false;

  void _leave() {
    if (mounted) Navigator.of(context).pop();
  }

  void _copyRoom() {
    Clipboard.setData(ClipboardData(text: widget.roomId));
    _showSnack('Room code copied');
  }

  void _shareRoom() {
    Share.share(
      'Let’s play UNO! Room code: ${widget.roomId}\nhttps://thetwodigiter.app/join/${widget.roomId}',
    );
  }
}

class _ConnectingView extends StatelessWidget {
  final String label;
  const _ConnectingView({this.label = 'Connecting to the table…'});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(label),
        ],
      ),
    ),
  );
}

class _OpponentPill extends StatelessWidget {
  final Player player;
  final bool active;
  const _OpponentPill({required this.player, required this.active});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: active
            ? scheme.primaryContainer.withValues(alpha: .92)
            : Colors.white.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active ? scheme.primary : Colors.white.withValues(alpha: .10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Avatar(seed: player.name, size: 25),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110),
            child: Text(
              player.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${player.handCount}',
            style: const TextStyle(color: Colors.white60),
          ),
          if (player.unoCalled)
            const Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text(
                'UNO',
                style: TextStyle(
                  color: Color(0xFF9FC3FF),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TurnPill extends StatelessWidget {
  final bool active;
  final bool compact;
  const _TurnPill({required this.active, this.compact = false});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 11, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? scheme.primaryContainer
            : Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        active ? 'YOUR TURN' : 'TABLE',
        style: TextStyle(
          color: active ? scheme.onPrimaryContainer : Colors.white70,
          fontSize: compact ? 9 : 10,
          fontWeight: FontWeight.w900,
          letterSpacing: .7,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String seed;
  final double size;
  const _Avatar({required this.seed, required this.size});
  @override
  Widget build(BuildContext context) => LocalAvatar(seed: seed, size: size);
}

class _ColorBadge extends StatelessWidget {
  final CardColor color;
  const _ColorBadge({required this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: 18,
    height: 18,
    decoration: BoxDecoration(
      color: _color(color),
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
    ),
  );
}

class _ColorChoice extends StatelessWidget {
  final CardColor color;
  final VoidCallback onTap;
  const _ColorChoice({required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(32),
    child: Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: _color(color),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black26)],
      ),
    ),
  );
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;
  const _InfoLine(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const Spacer(),
        Text(value.trim()),
      ],
    ),
  );
}

Color _color(CardColor color) => switch (color) {
  CardColor.red => const Color(0xFFED1C24),
  CardColor.blue => const Color(0xFF0877C9),
  CardColor.green => const Color(0xFF16833B),
  CardColor.yellow => const Color(0xFFF9C900),
  CardColor.wild => const Color(0xFF17191D),
};
