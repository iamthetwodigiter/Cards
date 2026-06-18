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
  final String deviceInfo;

  WebSocketClient({required this.roomId, required this.playerName, this.avatar = "", this.deviceInfo = ""});

  Stream<dynamic> connect() {
    final Map<String, String> queryParams = {};
    if (avatar.isNotEmpty) queryParams["avatar"] = avatar;
    if (deviceInfo.isNotEmpty) queryParams["device_info"] = deviceInfo;

    final uri = Uri(
      scheme: kIsSecure ? "wss" : "ws",
      host: kServerHost,
      pathSegments: ["ws", roomId, playerName],
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
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
