import 'package:cards/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/game_viewmodel.dart';
import '../models/game_models.dart';
import '../widgets/uno_card_widget.dart';
import 'package:dice_bear/dice_bear.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';

import 'package:flutter/services.dart';

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
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    Future.microtask(() {
      final notifier = ref.read(
        gameViewModelProvider(
          widget.roomId,
          widget.playerName,
          avatar: widget.avatar,
        ).notifier,
      );
      _eventSubscription = notifier.eventStream.listen(_handleGameEvent);
    });
  }

  void _handleGameEvent(GameEvent event) {
    if (!mounted) return;
    String title = "";
    String subtitle = "";
    IconData? iconData;
    Color? iconColor;

    if (event.event == 'uno_called') {
      title = "UNO!";
      subtitle = "${event.data['player_name']} called UNO!";
      iconData = Icons.notifications_active;
      iconColor = Colors.orange;
    } else if (event.event == 'uno_missed') {
      title = "Caught!";
      subtitle =
          "${event.data['catcher_name']} caught ${event.data['player_name']} missing UNO!";
      iconData = Icons.mood_bad;
      iconColor = Colors.red;
    } else if (event.event == 'player_won') {
      title = "Winner!";
      subtitle =
          "${event.data['player_name']} won the round! (+${event.data['score']} pts)";
      iconData = Icons.emoji_events;
      iconColor = Colors.yellow;
    } else if (event.event == 'game_over') {
      title = "Game Over";
      subtitle = "${event.data['loser_name']} lost the game!";
      iconData = Icons.sentiment_very_dissatisfied;
      iconColor = Colors.blueGrey;
    } else if (event.event == 'emoji_reaction') {
      final emoji = event.data['emoji'];
      final pName = event.data['player_name'];
      ToastUtils.showCustomToast(
        context,
        "$pName $emoji",
        color: Colors.blue.shade800,
      );
    } else if (event.event == 'shuffle_completed') {
      ToastUtils.showCustomToast(
        context,
        "Deck shuffled!",
        color: Colors.green.shade800,
      );
    }

    if (title.isNotEmpty) {
      _showAnimationOverlay(title, subtitle, iconData, iconColor);
    }
  }

  void _showAnimationOverlay(
    String title,
    String subtitle,
    IconData? iconData,
    Color? iconColor,
  ) {
    bool isDialogOpen = true;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "event",
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(32),
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white24,
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (iconData != null)
                      SizedBox(
                        height: 150,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.5, end: 1.2),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutBack,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Icon(
                                iconData,
                                size: 100,
                                color: iconColor,
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      isDialogOpen = false;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && isDialogOpen) {
        Navigator.pop(context);
      }
    });
  }

  void _showEmojiPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: 300,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: EmojiPicker(
            onEmojiSelected: (category, emoji) {
              ref
                  .read(
                    gameViewModelProvider(
                      widget.roomId,
                      widget.playerName,
                      avatar: widget.avatar,
                    ).notifier,
                  )
                  .sendEmoji(emoji.emoji);
              Navigator.of(ctx).pop();
            },
            config: const Config(
              bottomActionBarConfig: BottomActionBarConfig(showSearchViewButton: false),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(
      gameViewModelProvider(
        widget.roomId,
        widget.playerName,
        avatar: widget.avatar,
      ),
    );

    if (gameState == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Connecting to Room ${widget.roomId}")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (gameState.status == GameStatus.waiting) {
      return _buildWaitingRoom(context, ref, gameState);
    }

    return _buildGameRoom(context, ref, gameState);
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Leave Game?"),
        content: const Text("Are you sure you want to leave this room?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  bool _canPlay(UnoCard card, GameState state, int handLength) {
    if (handLength == 1 && card.value.index > CardValue.nine.index) {
      return false;
    }
    if (handLength == state.initialCards &&
        card.value.index > CardValue.nine.index) {
      return false;
    }
    if (state.pendingPenalty > 0) {
      if (!state.stackingEnabled) return false;
      if (state.discardPile.isEmpty) return false;
      final topCard = state.discardPile.last;
      if (topCard.value == CardValue.drawTwo &&
          card.value == CardValue.drawTwo) {
        return true;
      }
      if (topCard.value == CardValue.wildDrawFour &&
          card.value == CardValue.wildDrawFour) {
        return true;
      }
      return false;
    }
    if (card.color == CardColor.wild) return true;
    if (card.color == state.currentColor) return true;
    if (state.discardPile.isNotEmpty &&
        card.value == state.discardPile.last.value) {
      return true;
    }
    return false;
  }

  Widget _buildWaitingRoom(
    BuildContext context,
    WidgetRef ref,
    GameState state,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Room: ${widget.roomId}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: "Close Room",
            onPressed: () {
              ref
                  .read(
                    gameViewModelProvider(
                      widget.roomId,
                      widget.playerName,
                      avatar: widget.avatar,
                    ).notifier,
                  )
                  .closeRoom();
              Navigator.of(context).pop();
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: "Leave",
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Waiting for players...",
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Players joined: ${state.players.length}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  ...state.players.map(
                    (p) => Text(
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.copy),
                        label: const Text("Copy ID"),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: widget.roomId));
                          ToastUtils.showCustomToast(context, "Room ID copied!");
                        },
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text("Share Link"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          final link = "https://thetwodigiter.app/join/${widget.roomId}";
                          Share.share("Let's play UNO! Join my room using code: ${widget.roomId} or click this link to join directly: $link");
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  if (state.players.length >= 2 && state.players.isNotEmpty && state.players.first.name == widget.playerName)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => ref
                          .read(
                            gameViewModelProvider(
                              widget.roomId,
                              widget.playerName,
                              avatar: widget.avatar,
                            ).notifier,
                          )
                          .startGame(),
                      child: const Text("Start Game"),
                    )
                  else if (state.players.length >= 2)
                    const Text(
                      "Waiting for the host to start...",
                      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white70),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameRoom(BuildContext context, WidgetRef ref, GameState state) {
    final myIndex = state.players.indexWhere(
      (p) => p.name == widget.playerName,
    );
    if (myIndex == -1) {
      return const Scaffold(
        body: Center(child: Text("Player not found in state.")),
      );
    }
    final me = state.players[myIndex];
    final isMyTurn = state.currentTurnIndex == myIndex;
    final opponents = state.players
        .where((p) => p.name != widget.playerName)
        .toList();

    Widget buildColorIndicator(CardColor color) {
      Color bgColor;
      switch (color) {
        case CardColor.red:
          bgColor = Colors.red;
          break;
        case CardColor.blue:
          bgColor = Colors.blue;
          break;
        case CardColor.green:
          bgColor = Colors.green;
          break;
        case CardColor.yellow:
          bgColor = Colors.yellow;
          break;
        default:
          bgColor = Colors.black;
      }
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await _showExitDialog(context);
        if (shouldLeave == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.green[800],
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Expanded(
                      flex: 9,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: opponents.length,
                        itemBuilder: (context, index) {
                          final opp = opponents[index];
                          final isOppTurn =
                              state.currentTurnIndex ==
                              state.players.indexOf(opp);
                          return Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isOppTurn
                                  ? Colors.yellow.withValues(alpha: 0.5)
                                  : Colors.black26,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      shape: BoxShape.circle,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Opacity(
                                      opacity: opp.isConnected ? 1.0 : 0.3,
                                      child: opp.avatar.isNotEmpty
                                          ? DiceBearBuilder(
                                              sprite: DiceBearStyle.toonHead,
                                              seed: opp.avatar,
                                            ).build().toImage()
                                          : const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${opp.name}${opp.isConnected ? '' : ' (Offline)'}\n(${opp.score} pts)",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const HiddenCardWidget(
                                        width: 50,
                                        height: 75,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "x${opp.handCount}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (opp.unoCalled)
                                    const Text(
                                      "UNO!",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            child: const Icon(
                              Icons.info,
                              color: Colors.white,
                              size: 25,
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Game Info"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Room ID: ${widget.roomId}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(Icons.copy, size: 20),
                                            tooltip: "Copy Room ID",
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(text: widget.roomId));
                                              ToastUtils.showCustomToast(context, "Room ID copied to clipboard!");
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.share, size: 18),
                                        label: const Text("Share Link"),
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size.fromHeight(36),
                                        ),
                                        onPressed: () {
                                          final link = "https://thetwodigiter.app/join/${widget.roomId}";
                                          Share.share("Let's play UNO! Join my room using code: ${widget.roomId} or click this link to join directly: $link");
                                        },
                                      ),
                                      const Divider(height: 24),
                                      Text(
                                        "Direction: ${state.direction == 1 ? 'Clockwise' : 'Counter-Clockwise'}",
                                      ),
                                      Text(
                                        "Stacking Enabled: ${state.stackingEnabled ? 'Yes' : 'No'}",
                                      ),
                                      if (state.pendingPenalty > 0)
                                        Text(
                                          "Pending Draw Penalty: +${state.pendingPenalty} cards",
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text("Close"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          InkWell(
                            child: const Icon(
                              Icons.exit_to_app,
                              color: Colors.white,
                              size: 25,
                            ),
                            onTap: () async {
                              final shouldLeave = await _showExitDialog(
                                context,
                              );
                              if (shouldLeave == true && context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                          if (state.status == GameStatus.finished)
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(
                                      gameViewModelProvider(
                                        widget.roomId,
                                        widget.playerName,
                                        avatar: widget.avatar,
                                      ).notifier,
                                    )
                                    .restartGame();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Next Round"),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 4,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isMyTurn && state.hasDrawn)
                        ElevatedButton(
                          onPressed: () => ref
                              .read(
                                gameViewModelProvider(
                                  widget.roomId,
                                  widget.playerName,
                                  avatar: widget.avatar,
                                ).notifier,
                              )
                              .passTurn(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                          child: const Text(
                            "Skip Turn",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () {
                            if (isMyTurn) {
                              ref
                                  .read(
                                    gameViewModelProvider(
                                      widget.roomId,
                                      widget.playerName,
                                      avatar: widget.avatar,
                                    ).notifier,
                                  )
                                  .drawCard();
                            }
                          },
                          child: Stack(
                            children: [
                              const HiddenCardWidget(width: 80, height: 120),
                              if (state.deckCount > 0)
                                Positioned.fill(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      "${state.deckCount}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(
                          Icons.shuffle,
                          color: Colors.white,
                          size: 30,
                        ),
                        tooltip: "Shuffle Deck",
                        onPressed: () {
                          ref
                              .read(
                                gameViewModelProvider(
                                  widget.roomId,
                                  widget.playerName,
                                  avatar: widget.avatar,
                                ).notifier,
                              )
                              .proposeShuffle();
                        },
                      ),
                      const SizedBox(width: 20),
                      if (state.discardPile.isNotEmpty)
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          transitionBuilder: (child, animation) {
                            return RotationTransition(
                              turns: Tween(
                                begin: 0.0,
                                end: 0.05,
                              ).animate(animation),
                              child: ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Stack(
                            key: ValueKey(state.discardPile.length),
                            clipBehavior: Clip.none,
                            children: [
                              FittedBox(
                                fit: BoxFit.contain,
                                child: UnoCardWidget(
                                  card: state.discardPile.last,
                                  height: 120,
                                  width: 80,
                                ),
                              ),
                              if (state.currentColor != null)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: buildColorIndicator(
                                    state.currentColor!,
                                  ),
                                ),
                            ],
                          ),
                        )
                      else
                        Container(
                          width: 50,
                          height: 130,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white54, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              Expanded(
                flex: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isMyTurn
                        ? Colors.yellow.withValues(alpha: 0.3)
                        : Colors.transparent,
                    border: Border(
                      top: BorderSide(
                        color: isMyTurn ? Colors.yellow : Colors.transparent,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  shape: BoxShape.circle,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: me.avatar.isNotEmpty
                                    ? DiceBearBuilder(
                                        sprite: DiceBearStyle.toonHead,
                                        seed: me.avatar,
                                      ).build().toImage()
                                    : const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${me.name} (${me.score} pts)",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (isMyTurn && state.pendingPenalty > 0)
                            Text(
                              "Click the deck to take ${state.pendingPenalty} cards!",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (me.unoCalled)
                            const Text(
                              "UNO!",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          Row(
                            spacing: 10,
                            children: [
                              InkWell(
                                child: const Icon(
                                  Icons.emoji_emotions,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                onTap: () {
                                  _showEmojiPicker(context, ref);
                                },
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final catchable = state.players
                                      .where(
                                        (p) =>
                                            p.id != me.id &&
                                            p.handCount == 1 &&
                                            !p.unoCalled,
                                      )
                                      .toList();
                                  if (catchable.isNotEmpty) {
                                    ref
                                        .read(
                                          gameViewModelProvider(
                                            widget.roomId,
                                            widget.playerName,
                                            avatar: widget.avatar,
                                          ).notifier,
                                        )
                                        .catchUno(catchable.first.id);
                                  } else {
                                    ref
                                        .read(
                                          gameViewModelProvider(
                                            widget.roomId,
                                            widget.playerName,
                                            avatar: widget.avatar,
                                          ).notifier,
                                        )
                                        .sayUno();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text(
                                  "Call UNO",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          if (isMyTurn && state.hasDrawn) ...[
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(
                                      gameViewModelProvider(
                                        widget.roomId,
                                        widget.playerName,
                                        avatar: widget.avatar,
                                      ).notifier,
                                    )
                                    .passTurn();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              child: const Text(
                                "Skip Turn",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(me.hand.length, (index) {
                            final card = me.hand[index];
                            final playable = _canPlay(
                              card,
                              state,
                              me.hand.length,
                            );
                            return Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  if (!isMyTurn) return;
                                  if (!playable) {
                                    ToastUtils.showCustomToast(
                                      context,
                                      "You cannot play this card right now.",
                                    );
                                    return;
                                  }
                                  if (card.color == CardColor.wild) {
                                    _showColorPicker(context, ref, index);
                                  } else {
                                    ref
                                        .read(
                                          gameViewModelProvider(
                                            widget.roomId,
                                            widget.playerName,
                                            avatar: widget.avatar,
                                          ).notifier,
                                        )
                                        .playCard(index);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 1.0,
                                  ),
                                  child: Opacity(
                                    opacity: playable || !isMyTurn ? 1.0 : 0.5,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: UnoCardWidget(
                                        card: card,
                                        height: 150,
                                        width: 100,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, WidgetRef ref, int cardIndex) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Choose Color"),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _colorBtn(
                ctx,
                ref,
                cardIndex,
                CardColor.red,
                const Color(0xFFE53935),
              ),
              _colorBtn(
                ctx,
                ref,
                cardIndex,
                CardColor.blue,
                const Color(0xFF1E88E5),
              ),
              _colorBtn(
                ctx,
                ref,
                cardIndex,
                CardColor.green,
                const Color(0xFF43A047),
              ),
              _colorBtn(
                ctx,
                ref,
                cardIndex,
                CardColor.yellow,
                const Color(0xFFFFB300),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _colorBtn(
    BuildContext ctx,
    WidgetRef ref,
    int index,
    CardColor color,
    Color displayColor,
  ) {
    return GestureDetector(
      onTap: () {
        ref
            .read(
              gameViewModelProvider(
                widget.roomId,
                widget.playerName,
                avatar: widget.avatar,
              ).notifier,
            )
            .playCard(index, chosenColor: color);
        Navigator.of(ctx).pop();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: displayColor,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 2,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
    );
  }
}
