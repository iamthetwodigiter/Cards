import 'dart:async';
import 'dart:math';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../game/view/game_screen.dart';
import '../../settings/view/settings_screen.dart';
import '../../tutorial/view/tutorial_screen.dart';
import '/core/widgets/local_avatar.dart';
import '../viewmodel/home_viewmodel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _nameController = TextEditingController();
  final _roomController = TextEditingController();
  StreamSubscription<Uri>? _linkSubscription;
  int _initialCards = 7;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _nameController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _nameController.text =
          prefs.getString('playerName') ??
          'Player_${Random().nextInt(9000) + 1000}';
    });
  }

  Future<void> _initDeepLinks() async {
    final links = AppLinks();
    try {
      final initial = await links.getInitialLink();
      if (initial != null) _handleDeepLink(initial);
    } catch (_) {}
    _linkSubscription = links.uriLinkStream.listen(_handleDeepLink);
  }

  void _handleDeepLink(Uri uri) {
    if (uri.pathSegments.length >= 2 && uri.pathSegments.first == 'join') {
      final room = uri.pathSegments[1];
      if (room.isNotEmpty && mounted) {
        setState(() => _roomController.text = room);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room code loaded from invite')),
        );
      }
    }
  }

  Future<String> _playerName() async {
    var name = _nameController.text.trim();
    if (name.isEmpty) {
      name = 'Player_${Random().nextInt(9000) + 1000}';
      _nameController.text = name;
    }
    await ref.read(homeViewModelProvider.notifier).savePlayerName(name);
    return name;
  }

  Future<void> _createRoom() async {
    setState(() => _loading = true);
    try {
      final name = await _playerName();
      final room = await ref
          .read(homeViewModelProvider.notifier)
          .createRoom(name, initialCards: _initialCards);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              GameScreen(roomId: room, playerName: name, avatar: name),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _joinRoom() async {
    final room = _roomController.text.trim().toUpperCase();
    if (room.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a room code first.')));
      return;
    }
    final name = await _playerName();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            GameScreen(roomId: room, playerName: name, avatar: name),
      ),
    );
  }

  Future<void> _settings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = _nameController.text.trim();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.asset('assets/logo.png'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'UNO',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              Text(
                                'Multiplayer table',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed: _settings,
                          tooltip: 'Settings',
                          icon: const Icon(Icons.settings_outlined),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      children: [
                        Text(
                          'Ready to play?',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.2,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a table with friends or enter a room code to jump straight in.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                        ),
                        const SizedBox(height: 22),
                        _IdentityCard(name: name, onEdit: _settings),
                        const SizedBox(height: 14),
                        _PlayCard(
                          initialCards: _initialCards,
                          loading: _loading,
                          roomController: _roomController,
                          onInitialCardsChanged: (value) =>
                              setState(() => _initialCards = value),
                          onCreate: _createRoom,
                          onJoin: _joinRoom,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: 220,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TutorialScreen(),
                              ),
                            ),
                            icon: const Icon(Icons.school_outlined),
                            label: const Text('How to play'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Blue table. Real UNO rules. Quick rounds.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final String name;
  final VoidCallback onEdit;
  const _IdentityCard({required this.name, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            LocalAvatar(seed: name, size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PLAYING AS',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    name.isEmpty ? 'Player' : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              onPressed: onEdit,
              tooltip: 'Edit name',
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayCard extends StatelessWidget {
  final int initialCards;
  final bool loading;
  final TextEditingController roomController;
  final ValueChanged<int> onInitialCardsChanged;
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  const _PlayCard({
    required this.initialCards,
    required this.loading,
    required this.roomController,
    required this.onInitialCardsChanged,
    required this.onCreate,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'PLAY A ROUND',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: initialCards,
              decoration: const InputDecoration(
                labelText: 'Starting hand',
                prefixIcon: Icon(Icons.style_outlined),
              ),
              items: [5, 7, 9, 11]
                  .map(
                    (v) => DropdownMenuItem(value: v, child: Text('$v cards')),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) onInitialCardsChanged(v);
              },
            ),
            const SizedBox(height: 14),
            Center(
              child: SizedBox(
                width: 320,
                child: FilledButton.icon(
                  onPressed: loading ? null : onCreate,
                  icon: loading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_rounded),
                  label: Text(loading ? 'Creating table…' : 'Create room'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Divider(color: scheme.outlineVariant)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'OR',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: scheme.outlineVariant)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: roomController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 8,
              decoration: const InputDecoration(
                labelText: 'Room code',
                prefixIcon: Icon(Icons.meeting_room_outlined),
                counterText: '',
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: SizedBox(
                width: 320,
                child: OutlinedButton.icon(
                  onPressed: onJoin,
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Join room'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
