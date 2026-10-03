import 'package:web_socket_channel/web_socket_channel.dart';
import 'api_client.dart';

class WebSocketClient {
  WebSocketChannel? _channel;
  final String roomId;
  final String playerName;
  final String avatar;
  final String deviceInfo;
  final String deviceId;

  WebSocketClient({
    required this.roomId,
    required this.playerName,
    required this.deviceId,
    this.avatar = '',
    this.deviceInfo = '',
  });

  Stream<dynamic> connect() {
    final origin = serverOrigin;
    final queryParams = <String, String>{
      'device_id': deviceId,
      if (avatar.isNotEmpty) 'avatar': avatar,
      if (deviceInfo.isNotEmpty) 'device_info': deviceInfo,
    };

    final uri = origin.replace(
      scheme: origin.scheme == 'https' ? 'wss' : 'ws',
      path: '/ws/$roomId/$playerName',
      queryParameters: queryParams,
    );

    _channel = WebSocketChannel.connect(uri);
    return _channel!.stream;
  }

  void send(String data) => _channel?.sink.add(data);

  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
  }
}
