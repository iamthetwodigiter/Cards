import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/network/websocket_client.dart';
import '../models/game_models.dart';

part 'game_viewmodel.g.dart';

@riverpod
class GameViewModel extends _$GameViewModel {
  WebSocketClient? _client;
  final _eventController = StreamController<GameEvent>.broadcast();
  bool _disposed = false;

  Stream<GameEvent> get eventStream => _eventController.stream;

  @override
  GameState? build(String roomId, String playerName, {String avatar = ""}) {
    _connect(avatar);
    ref.onDispose(() {
      _disposed = true;
      _client?.disconnect();
      _eventController.close();
    });
    return null;
  }

  Future<String> _getStableDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'uno_device_id';
    final existing = prefs.getString(key);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = 'dev_${const Uuid().v4()}';
    await prefs.setString(key, id);
    return id;
  }

  Future<void> _connect(String avatar) async {
    final deviceId = await _getStableDeviceId();
    if (_disposed) return;

    _client = WebSocketClient(
      roomId: roomId,
      playerName: playerName,
      avatar: avatar,
      deviceId: deviceId,
      deviceInfo: !kIsWeb ? Platform.operatingSystem : 'web',
    );
    _client!.connect().listen(
      (data) {
        try {
          final message = jsonDecode(data);
          if (_disposed) return;
          if (message['type'] == 'state_update') {
            state = GameState.fromJson(
              message['state'] as Map<String, dynamic>,
            );
          } else if (message['type'] == 'game_event') {
            _eventController.add(
              GameEvent.fromJson(message['event'] as Map<String, dynamic>),
            );
          } else if (message['type'] == 'error') {
            debugPrint('Error: ${message['message']}');
          }
        } catch (e, st) {
          debugPrint('Error processing websocket message: $e\n$st');
        }
      },
      onError: (error) {
        debugPrint('WebSocket Error: $error');
      },
      onDone: () {
        debugPrint('WebSocket Disconnected');
      },
    );
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

  void sendEmoji(String emoji) {
    _client?.send(jsonEncode({"action": "send_emoji", "emoji": emoji}));
  }

  void proposeShuffle() {
    _client?.send(jsonEncode({"action": "propose_shuffle"}));
  }

  void voteShuffle(bool vote) {
    _client?.send(jsonEncode({"action": "vote_shuffle", "vote": vote}));
  }

  void restartGame() {
    _client?.send(jsonEncode({"action": "restart_game"}));
  }

  void closeRoom() {
    _client?.send(jsonEncode({"action": "close_room"}));
  }
}
