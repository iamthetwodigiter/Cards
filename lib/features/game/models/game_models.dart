enum CardColor { red, blue, green, yellow, wild }

enum CardValue {
  zero, one, two, three, four, five, six, seven, eight, nine,
  skip, reverse, drawTwo, wild, wildDrawFour
}

extension CardColorExt on CardColor {
  String get stringValue {
    switch (this) {
      case CardColor.red: return "red";
      case CardColor.blue: return "blue";
      case CardColor.green: return "green";
      case CardColor.yellow: return "yellow";
      case CardColor.wild: return "wild";
    }
  }

  static CardColor fromString(String val) {
    return CardColor.values.firstWhere((e) => e.stringValue == val);
  }
}

extension CardValueExt on CardValue {
  String get stringValue {
    switch (this) {
      case CardValue.zero: return "0";
      case CardValue.one: return "1";
      case CardValue.two: return "2";
      case CardValue.three: return "3";
      case CardValue.four: return "4";
      case CardValue.five: return "5";
      case CardValue.six: return "6";
      case CardValue.seven: return "7";
      case CardValue.eight: return "8";
      case CardValue.nine: return "9";
      case CardValue.skip: return "skip";
      case CardValue.reverse: return "reverse";
      case CardValue.drawTwo: return "+2";
      case CardValue.wild: return "wild";
      case CardValue.wildDrawFour: return "+4";
    }
  }

  static CardValue fromString(String val) {
    return CardValue.values.firstWhere((e) => e.stringValue == val);
  }
}

class UnoCard {
  final CardColor color;
  final CardValue value;

  UnoCard({required this.color, required this.value});

  factory UnoCard.fromJson(Map<String, dynamic> json) {
    return UnoCard(
      color: CardColorExt.fromString(json['color']),
      value: CardValueExt.fromString(json['value']),
    );
  }

  Map<String, dynamic> toJson() => {
    'color': color.stringValue,
    'value': value.stringValue,
  };
}

class Player {
  final String id;
  final String name;
  final String avatar;
  final List<UnoCard> hand;
  final int handCount;
  final bool isConnected;
  final bool isWinner;
  final int? placement;
  final bool unoCalled;
  final int score;

  Player({
    required this.id,
    required this.name,
    this.avatar = "",
    this.hand = const [],
    this.handCount = 0,
    this.isConnected = true,
    this.isWinner = false,
    this.placement,
    this.unoCalled = false,
    this.score = 0,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'] ?? "",
      hand: (json['hand'] as List?)?.map((e) => UnoCard.fromJson(e as Map<String, dynamic>)).toList().cast<UnoCard>() ?? [],
      handCount: json['hand_count'] ?? (json['hand'] as List?)?.length ?? 0,
      isConnected: json['is_connected'] ?? true,
      isWinner: json['is_winner'] ?? false,
      placement: json['placement'],
      unoCalled: json['uno_called'] ?? false,
      score: json['score'] ?? 0,
    );
  }
}

enum GameStatus { waiting, playing, finished }

extension GameStatusExt on GameStatus {
  static GameStatus fromString(String val) {
    return GameStatus.values.firstWhere((e) => e.name == val, orElse: () => GameStatus.waiting);
  }
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

  GameState({
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
    return GameState(
      roomId: json['room_id'],
      status: GameStatusExt.fromString(json['status'] ?? 'waiting'),
      players: (json['players'] as List?)?.map((e) => Player.fromJson(e as Map<String, dynamic>)).toList().cast<Player>() ?? [],
      currentTurnIndex: json['current_turn_index'] ?? 0,
      direction: json['direction'] ?? 1,
      discardPile: (json['discard_pile'] as List?)?.map((e) => UnoCard.fromJson(e as Map<String, dynamic>)).toList().cast<UnoCard>() ?? [],
      deckCount: json['deck_count'] ?? (json['deck'] as List?)?.length ?? 0,
      currentColor: json['current_color'] != null ? CardColorExt.fromString(json['current_color']) : null,
      pendingPenalty: json['pending_penalty'] ?? 0,
      lastCardPlayedBy: json['last_card_played_by'],
      stackingEnabled: json['stacking_enabled'] ?? true,
      initialCards: json['initial_cards'] ?? 7,
      hasDrawn: json['has_drawn'] ?? false,
    );
  }
}

class GameEvent {
  final String event;
  final Map<String, dynamic> data;

  GameEvent(this.event, this.data);

  factory GameEvent.fromJson(Map<String, dynamic> json) {
    return GameEvent(json['event'] ?? 'unknown', json);
  }
}
