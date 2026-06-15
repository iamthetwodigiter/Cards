import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

const String kServerHost = "iamthetwodigiter-cardsbackend.hf.space";
const bool kIsSecure = true;

String get baseUrl {
  const scheme = kIsSecure ? "https" : "http";
  return "$scheme://$kServerHost/api";
}

@riverpod
Dio apiClient(ApiClientRef ref) {
  final options = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  );
  return Dio(options);
}
