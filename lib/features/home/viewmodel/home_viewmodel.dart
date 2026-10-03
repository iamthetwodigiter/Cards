import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';

part 'home_viewmodel.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  Future<void> build() async {
    return;
  }

  Future<String> createRoom(String playerName, {int initialCards = 7}) async {
    final dio = ref.read(apiClientProvider);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('playerName', playerName);

    try {
      final response = await dio.post(
        '/room',
        data: {'initial_cards': initialCards},
      );
      return response.data['room_id'];
    } catch (e) {
      if (e is DioException) {
        final uri = e.requestOptions.uri;
        if (e.type == DioExceptionType.connectionError) {
          throw Exception(
            'Cannot reach UNO server at $uri. Check the server URL, HTTPS access, and device network.',
          );
        }
      }
      throw Exception('Failed to create room: $e');
    }
  }

  Future<void> savePlayerName(String playerName) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('playerName', playerName);
  }

  String? getSavedPlayerName() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getString('playerName');
  }
}
