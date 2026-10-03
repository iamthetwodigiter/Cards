enum CardColor { red, blue, green, yellow, wild }

enum CardValue {
  zero,
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  skip,
  reverse,
  drawTwo,
  wild,
  wildDrawFour,
}

extension CardColorExt on CardColor {
  String get stringValue => switch (this) {
    CardColor.red => 'red',
    CardColor.blue => 'blue',
    CardColor.green => 'green',
    CardColor.yellow => 'yellow',
    CardColor.wild => 'wild',
  };

  static CardColor fromString(String? value) => CardColor.values.firstWhere(
    (e) => e.stringValue == value?.toLowerCase(),
    orElse: () => CardColor.wild,
  );
}

extension CardValueExt on CardValue {
  String get stringValue => switch (this) {
    CardValue.zero => '0',
    CardValue.one => '1',
    CardValue.two => '2',
    CardValue.three => '3',
    CardValue.four => '4',
    CardValue.five => '5',
    CardValue.six => '6',
    CardValue.seven => '7',
    CardValue.eight => '8',
    CardValue.nine => '9',
    CardValue.skip => 'skip',
    CardValue.reverse => 'reverse',
    CardValue.drawTwo => '+2',
    CardValue.wild => 'wild',
    CardValue.wildDrawFour => '+4',
  };

  static CardValue fromString(String? value) => CardValue.values.firstWhere(
    (e) => e.stringValue == value,
    orElse: () => CardValue.wild,
  );

  bool get isAction => index > CardValue.nine.index;
}

class UnoCard {
  final CardColor color;
  final CardValue value;

  const UnoCard({required this.color, required this.value});

  factory UnoCard.fromJson(Map<String, dynamic> json) => UnoCard(
    color: CardColorExt.fromString(json['color']?.toString()),
    value: CardValueExt.fromString(json['value']?.toString()),
  );

  Map<String, dynamic> toJson() => {
    'color': color.stringValue,
    'value': value.stringValue,
  };
}

class Player {
  final String id;
  final String deviceId;
  final String name;
  final String avatar;
  final List<UnoCard> hand;
  final int handCount;
  final bool isConnected;
  final bool isWinner;
  final int? placement;
  final bool unoCalled;
  final int score;

  const Player({
    required this.id,
    this.deviceId = '',
    required this.name,
    this.avatar = '',
    this.hand = const [],
    this.handCount = 0,
    this.isConnected = true,
    this.isWinner = false,
    this.placement,
    this.unoCalled = false,
    this.score = 0,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    final rawHand = json['hand'];
    final hand = rawHand is List
        ? rawHand
              .whereType<Map>()
              .map((e) => UnoCard.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false)
        : const <UnoCard>[];
    return Player(
      id: json['id']?.toString() ?? '',
      deviceId: json['device_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Player',
      avatar: json['avatar']?.toString() ?? '',
      hand: hand,
      handCount: (json['hand_count'] as num?)?.toInt() ?? hand.length,
      isConnected: json['is_connected'] as bool? ?? true,
      isWinner: json['is_winner'] as bool? ?? false,
      placement: (json['placement'] as num?)?.toInt(),
      unoCalled: json['uno_called'] as bool? ?? false,
      score: (json['score'] as num?)?.toInt() ?? 0,
    );
  }
}

enum GameStatus { waiting, playing, finished }

extension GameStatusExt on GameStatus {
  static GameStatus fromString(String? value) => GameStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => GameStatus.waiting,
  );
}

class GameState {
  final String roomId;
  final GameStatus status;
  final List<Player> players;
  final int currentTurnIndex;
  final int direction;
  final List<UnoCard> discardPile;
  final int deckCount;
  final CardColor? currentColor;
  final int pendingPenalty;
  final String? lastCardPlayedBy;
  final bool stackingEnabled;
  final int initialCards;
  final bool hasDrawn;

  const GameState({
    required this.roomId,
    this.status = GameStatus.waiting,
    this.players = const [],
    this.currentTurnIndex = 0,
    this.direction = 1,
    this.discardPile = const [],
    this.deckCount = 0,
    this.currentColor,
    this.pendingPenalty = 0,
    this.lastCardPlayedBy,
    this.stackingEnabled = true,
    this.initialCards = 7,
    this.hasDrawn = false,
  });

  factory GameState.fromJson(Map<String, dynamic> json) {
    final rawPlayers = json['players'];
    final rawDiscard = json['discard_pile'];
    final rawDeck = json['deck'];
    final players = rawPlayers is List
        ? rawPlayers
              .whereType<Map>()
              .map((e) => Player.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false)
        : const <Player>[];
    final discard = rawDiscard is List
        ? rawDiscard
              .whereType<Map>()
              .map((e) => UnoCard.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false)
        : const <UnoCard>[];
    return GameState(
      roomId: json['room_id']?.toString() ?? '',
      status: GameStatusExt.fromString(json['status']?.toString()),
      players: players,
      currentTurnIndex: (json['current_turn_index'] as num?)?.toInt() ?? 0,
      direction: (json['direction'] as num?)?.toInt() ?? 1,
      discardPile: discard,
      deckCount:
          (json['deck_count'] as num?)?.toInt() ??
          (rawDeck is List ? rawDeck.length : 0),
      currentColor: json['current_color'] == null
          ? null
          : CardColorExt.fromString(json['current_color']?.toString()),
      pendingPenalty: (json['pending_penalty'] as num?)?.toInt() ?? 0,
      lastCardPlayedBy: json['last_card_played_by']?.toString(),
      stackingEnabled: json['stacking_enabled'] as bool? ?? true,
      initialCards: (json['initial_cards'] as num?)?.toInt() ?? 7,
      hasDrawn: json['has_drawn'] as bool? ?? false,
    );
  }
}

class GameEvent {
  final String event;
  final Map<String, dynamic> data;
  const GameEvent(this.event, this.data);
  factory GameEvent.fromJson(Map<String, dynamic> json) =>
      GameEvent(json['event']?.toString() ?? 'unknown', json);
}
