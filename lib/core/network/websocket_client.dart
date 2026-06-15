import 'package:web_socket_channel/web_socket_channel.dart';
import 'api_client.dart';

String get wsBaseUrl {
  const scheme = kIsSecure ? "wss" : "ws";
  return "$scheme://$kServerHost/ws";
}

class WebSocketClient {
  WebSocketChannel? _channel;
  final String roomId;
  final String playerName;
  final String avatar;

  WebSocketClient({required this.roomId, required this.playerName, this.avatar = ""});

  Stream<dynamic> connect() {
    final uri = Uri(
      scheme: kIsSecure ? "wss" : "ws",
      host: kServerHost,
      pathSegments: ["ws", roomId, playerName],
      queryParameters: avatar.isNotEmpty ? {"avatar": avatar} : null,
    );
    _channel = WebSocketChannel.connect(uri);
    return _channel!.stream;
  }

  void send(String data) {
    _channel?.sink.add(data);
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
