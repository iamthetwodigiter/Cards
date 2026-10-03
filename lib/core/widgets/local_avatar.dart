import 'package:flutter/material.dart';

class LocalAvatar extends StatelessWidget {
  final String seed;
  final double size;

  const LocalAvatar({super.key, required this.seed, this.size = 48});

  static const _palettes = <List<Color>>[
    [Color(0xFF42A5F5), Color(0xFF1565C0)],
    [Color(0xFF64B5F6), Color(0xFF0D47A1)],
    [Color(0xFF2196F3), Color(0xFF283593)],
    [Color(0xFF90CAF9), Color(0xFF1976D2)],
    [Color(0xFF5C6BC0), Color(0xFF1A237E)],
    [Color(0xFF26A69A), Color(0xFF006064)],
  ];

  int _hash(String value) {
    var hash = 0;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }

  @override
  Widget build(BuildContext context) {
    final value = seed.trim().isEmpty ? 'player' : seed.trim();
    final hash = _hash(value);
    final palette = _palettes[hash % _palettes.length];
    final initials = value.substring(0, 1).toUpperCase();

    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.first.withValues(alpha: .28),
            blurRadius: size * .22,
            offset: Offset(0, size * .08),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? 'U' : initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * .32,
          fontWeight: FontWeight.w900,
          letterSpacing: -.5,
        ),
      ),
    );

    final isUrl = value.startsWith('https://') || value.startsWith('http://');
    if (!isUrl) return fallback;

    return ClipOval(
      child: Image.network(
        value,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return fallback;
        },
      ),
    );
  }
}
