import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/websocket_client.dart';
import '../models/game_models.dart';

part 'game_viewmodel.g.dart';

@riverpod
class GameViewModel extends _$GameViewModel {
  WebSocketClient? _client;
  final _eventController = StreamController<GameEvent>.broadcast();

  Stream<GameEvent> get eventStream => _eventController.stream;

  @override
  GameState? build(String roomId, String playerName, {String avatar = ""}) {
    _connect(avatar);
    ref.onDispose(() {
      _client?.disconnect();
    });
    return null;
  }

  void _connect(String avatar) {
    _client = WebSocketClient(roomId: roomId, playerName: playerName, avatar: avatar);
    _client!.connect().listen((data) {
      try {
        final message = jsonDecode(data);
        if (message['type'] == 'state_update') {
          state = GameState.fromJson(message['state'] as Map<String, dynamic>);
        } else if (message['type'] == 'game_event') {
          _eventController.add(GameEvent.fromJson(message['event'] as Map<String, dynamic>));
        } else if (message['type'] == 'error') {
          debugPrint('Error: ${message['message']}');
        }
      } catch (e, st) {
        debugPrint('Error processing websocket message: $e\n$st');
      }
    }, onError: (error) {
      debugPrint('WebSocket Error: $error');
    }, onDone: () {
      debugPrint('WebSocket Disconnected');
    });
  }

  void startGame() {
    _client?.send(jsonEncode({"action": "start_game"}));
  }

  void playCard(int cardIndex, {CardColor? chosenColor, bool sayUno = false}) {
    final data = {
      "action": "play_card",
      "card_index": cardIndex,
      "say_uno": sayUno,
    };
    if (chosenColor != null) {
      data["chosen_color"] = chosenColor.stringValue;
    }
    _client?.send(jsonEncode(data));
  }

  void drawCard() {
    _client?.send(jsonEncode({"action": "draw_card"}));
  }

  void sayUno() {
    _client?.send(jsonEncode({"action": "say_uno"}));
  }

  void catchUno(String caughtId) {
    _client?.send(jsonEncode({"action": "catch_uno", "caught_id": caughtId}));
  }

  void passTurn() {
    _client?.send(jsonEncode({"action": "pass_turn"}));
  }
}
