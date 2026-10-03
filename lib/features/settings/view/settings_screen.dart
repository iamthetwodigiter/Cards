import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/core/widgets/local_avatar.dart';
import '../../tutorial/view/tutorial_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _nameController.text = prefs.getString('playerName') ?? '';
      _loading = false;
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give yourself a player name first.')),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('playerName', name);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final name = _nameController.text.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'PROFILE',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          LocalAvatar(seed: name, size: 132),
                          const SizedBox(height: 12),
                          Text(
                            name.isEmpty ? 'Your player name' : name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 22),
                          TextField(
                            controller: _nameController,
                            maxLength: 18,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'Player name',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Your avatar is generated from the first letter of your name.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.school_outlined),
                          title: const Text('How to play'),
                          subtitle: const Text(
                            'Rules, actions, wild cards and UNO calls',
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TutorialScreen(),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        const ListTile(
                          leading: Icon(Icons.palette_outlined),
                          title: Text('Material 3 theme'),
                          subtitle: Text(
                            'Automatically follows the system light/dark appearance',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Save profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
