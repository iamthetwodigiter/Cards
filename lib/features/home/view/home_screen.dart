import 'package:cards/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tutorial/view/tutorial_screen.dart';
import '../../game/view/game_screen.dart';
import '../viewmodel/home_viewmodel.dart';
import '../../settings/view/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _nameController = TextEditingController();
  final _roomController = TextEditingController();
  bool _isLoading = false;
  int _initialCards = 7;
  String _avatarSeed = "Felix";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final name = ref
          .read(homeViewModelProvider.notifier)
          .getSavedPlayerName();
      if (name != null) {
        _nameController.text = name;
      }
      _loadAvatar();
    });
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _avatarSeed = prefs.getString('avatar_seed') ?? "Felix";
      final savedName = prefs.getString('player_name');
      if (savedName != null && savedName.isNotEmpty) {
        _nameController.text = savedName;
      }
    });
  }

  void _createRoom() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ToastUtils.showCustomToast(context, "Please enter your name!", color: Colors.red.shade700);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final roomId = await ref
          .read(homeViewModelProvider.notifier)
          .createRoom(name, initialCards: _initialCards);
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GameScreen(
              roomId: roomId,
              playerName: name,
              avatar: _avatarSeed,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _joinRoom() async {
    final name = _nameController.text.trim();
    final roomId = _roomController.text.trim();
    if (name.isEmpty) {
      ToastUtils.showCustomToast(context, "Please enter your name!", color: Colors.red.shade700);
      return;
    }
    if (roomId.isEmpty) {
      ToastUtils.showCustomToast(context, "Please enter a Room ID!", color: Colors.red.shade700);
      return;
    }

    await ref.read(homeViewModelProvider.notifier).savePlayerName(name);
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              GameScreen(roomId: roomId, playerName: name, avatar: _avatarSeed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.red.shade900, Colors.red.shade500],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.all(32),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "UNO",
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFE53935),
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: "Player Name",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int>(
                              initialValue: _initialCards,
                              decoration: const InputDecoration(
                                labelText: "Starting Cards",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.style),
                              ),
                              items: [5, 7, 9, 11].map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text("$value Cards"),
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                if (newValue != null) {
                                  setState(() => _initialCards = newValue);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            if (_isLoading) const CircularProgressIndicator(),
                            if (!_isLoading)
                              ElevatedButton(
                                onPressed: _createRoom,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                  backgroundColor: const Color(0xFF1E88E5),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "Create Room",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            const Row(
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Text(
                                    "OR",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _roomController,
                              decoration: const InputDecoration(
                                labelText: "Room ID to Join",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.meeting_room),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _joinRoom,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                backgroundColor: const Color(0xFF43A047),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Join Room",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const TutorialScreen()),
                                );
                              },
                              icon: const Icon(Icons.school, color: Colors.blueAccent),
                              label: const Text("How to Play", style: TextStyle(color: Colors.blueAccent, fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                    _loadAvatar();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
