import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:device_info_plus/device_info_plus.dart';
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

  void _connect(String avatar) async {
    String deviceInfo = "Unknown";
    try {
      if (!kIsWeb) {
        final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          final info = await deviceInfoPlugin.androidInfo;
          deviceInfo = "${info.brand} ${info.model}";
        } else if (Platform.isIOS) {
          final info = await deviceInfoPlugin.iosInfo;
          deviceInfo = "${info.name} ${info.systemName}";
        } else if (Platform.isWindows) {
          final info = await deviceInfoPlugin.windowsInfo;
          deviceInfo = "Windows ${info.computerName}";
        } else if (Platform.isMacOS) {
          final info = await deviceInfoPlugin.macOsInfo;
          deviceInfo = "MacOS ${info.computerName}";
        }
      }
    } catch (_) {}

    _client = WebSocketClient(roomId: roomId, playerName: playerName, avatar: avatar, deviceInfo: deviceInfo);
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
