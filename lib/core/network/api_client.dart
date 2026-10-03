import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

const String kConfiguredBaseUrl =
    'https://iamthetwodigiter-cardsbackend.hf.space';

String get baseUrl {
  final value = kConfiguredBaseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
  return value.endsWith('/api') ? value : '$value/api';
}

Uri get serverOrigin {
  final uri = Uri.parse(kConfiguredBaseUrl.trim());
  return uri.replace(path: '', query: null, fragment: null);
}

@riverpod
Dio apiClient(ApiClientRef ref) {
  final options = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 12),
    sendTimeout: const Duration(seconds: 12),
    headers: const {'Accept': 'application/json'},
  );
  return Dio(options);
}
