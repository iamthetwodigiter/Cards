import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/game_models.dart';

class UnoCardWidget extends StatelessWidget {
  final UnoCard card;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final bool enabled;
  final bool selected;

  const UnoCardWidget({
    super.key,
    required this.card,
    this.width = 72,
    this.height = 108,
    this.onTap,
    this.enabled = true,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = RepaintBoundary(
      child: CustomPaint(
        size: Size(width, height),
        painter: _UnoCardPainter(
          card: card,
          selected: selected,
          enabled: enabled,
        ),
      ),
    );

    return SizedBox(
      width: width,
      height: height,
      child: onTap == null
          ? child
          : InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: enabled ? onTap : null,
              child: child,
            ),
    );
  }
}

class HiddenCardWidget extends StatelessWidget {
  final double width;
  final double height;

  const HiddenCardWidget({super.key, this.width = 72, this.height = 108});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: const RepaintBoundary(
        child: CustomPaint(painter: _UnoBackPainter()),
      ),
    );
  }
}

class _UnoCardPainter extends CustomPainter {
  final UnoCard card;
  final bool selected;
  final bool enabled;

  const _UnoCardPainter({
    required this.card,
    required this.selected,
    required this.enabled,
  });

  Color get baseColor => switch (card.color) {
    CardColor.red => const Color(0xFFED1C24),
    CardColor.blue => const Color(0xFF0877C9),
    CardColor.green => const Color(0xFF16833B),
    CardColor.yellow => const Color(0xFFF9C900),
    CardColor.wild => const Color(0xFF17191D),
  };

  String get label => switch (card.value) {
    CardValue.zero => '0',
    CardValue.one => '1',
    CardValue.two => '2',
    CardValue.three => '3',
    CardValue.four => '4',
    CardValue.five => '5',
    CardValue.six => '6',
    CardValue.seven => '7',
    CardValue.eight => '8',
    CardValue.nine => '9',
    CardValue.skip => '⊘',
    CardValue.reverse => '↔',
    CardValue.drawTwo => '+2',
    CardValue.wild => 'WILD',
    CardValue.wildDrawFour => '+4',
  };

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 100;
    final sy = size.height / 150;
    final scale = math.min(sx, sy);
    final r = 11 * scale;
    final outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(r),
    );

    canvas.drawShadow(
      Path()..addRRect(outer),
      Colors.black.withValues(alpha: .30),
      7 * scale,
      true,
    );
    canvas.drawRRect(outer, Paint()..color = Colors.white);

    final inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        3.5 * scale,
        3.5 * scale,
        size.width - 7 * scale,
        size.height - 7 * scale,
      ),
      Radius.circular(8.5 * scale),
    );
    canvas.drawRRect(inner, Paint()..color = baseColor);

    if (card.color == CardColor.wild) {
      _paintWild(canvas, size, scale);
    } else {
      _paintOval(canvas, size, scale);
    }

    final cornerSize =
        card.value == CardValue.skip ||
            card.value == CardValue.reverse ||
            card.value == CardValue.drawTwo ||
            card.value == CardValue.wild ||
            card.value == CardValue.wildDrawFour
        ? 13.0
        : 18.0;
    _paintCorner(
      canvas,
      label,
      Rect.fromLTWH(6 * scale, 6 * scale, 22 * scale, 30 * scale),
      cornerSize * scale,
      false,
    );
    _paintCorner(
      canvas,
      label,
      Rect.fromLTWH(
        size.width - 28 * scale,
        size.height - 36 * scale,
        22 * scale,
        30 * scale,
      ),
      cornerSize * scale,
      true,
    );

    if (selected) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            1.5 * scale,
            1.5 * scale,
            size.width - 3 * scale,
            size.height - 3 * scale,
          ),
          Radius.circular(10 * scale),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * scale
          ..color = Colors.white,
      );
    }
    if (!enabled) {
      canvas.drawRRect(
        inner,
        Paint()..color = Colors.black.withValues(alpha: .32),
      );
    }
  }

  void _paintOval(Canvas canvas, Size size, double scale) {
    final oval = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * .80,
      height: size.height * .54,
    );
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-math.pi / 8);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.drawOval(oval, Paint()..color = Colors.white);
    if (label.isNotEmpty) {
      final maxWidth = oval.width * .72;
      final maxHeight = oval.height * .55;
      var fontSize = label.length <= 2
          ? 44.0
          : label.length <= 4
          ? 25.0
          : 16.0;
      TextPainter tp = _fitText(
        label,
        baseColor,
        fontSize * scale,
        maxWidth,
        maxHeight,
      );
      tp.paint(
        canvas,
        Offset(size.width / 2 - tp.width / 2, size.height / 2 - tp.height / 2),
      );
    }
    canvas.restore();
  }

  void _paintWild(Canvas canvas, Size size, double scale) {
    final oval = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * .82,
      height: size.height * .55,
    );
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-math.pi / 8);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.clipPath(Path()..addOval(oval));
    final colors = [
      const Color(0xFFED1C24),
      const Color(0xFFF9C900),
      const Color(0xFF16833B),
      const Color(0xFF0877C9),
    ];
    final w = oval.width / 2;
    final h = oval.height / 2;
    for (var row = 0; row < 2; row++) {
      for (var col = 0; col < 2; col++) {
        canvas.drawRect(
          Rect.fromLTWH(oval.left + col * w, oval.top + row * h, w + 1, h + 1),
          Paint()..color = colors[row * 2 + col],
        );
      }
    }
    canvas.restore();

    if (card.value == CardValue.wild || card.value == CardValue.wildDrawFour) {
      final tp = TextPainter(
        text: TextSpan(
          text: card.value == CardValue.wildDrawFour ? '+4' : 'WILD',
          style: TextStyle(
            color: Colors.white,
            fontSize: card.value == CardValue.wildDrawFour
                ? 30 * scale
                : 22 * scale,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(size.width / 2 - tp.width / 2, size.height / 2 - tp.height / 2),
      );
    }
  }

  TextPainter _fitText(
    String text,
    Color color,
    double fontSize,
    double maxWidth,
    double maxHeight,
  ) {
    var size = fontSize;
    TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    while (size >= 7) {
      tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: size,
            fontWeight: FontWeight.w900,
            height: .88,
            letterSpacing: text.length > 3 ? -.7 : 0,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: null,
      )..layout(maxWidth: maxWidth);
      if (!tp.didExceedMaxLines &&
          tp.width <= maxWidth &&
          tp.height <= maxHeight) {
        return tp;
      }
      size -= .8;
    }
    return tp;
  }

  void _paintCorner(
    Canvas canvas,
    String text,
    Rect bounds,
    double fontSize,
    bool rotate,
  ) {
    final tp = _fitText(
      text,
      Colors.white,
      fontSize,
      bounds.width,
      bounds.height,
    );
    canvas.save();
    final center = bounds.center;
    canvas.translate(center.dx, center.dy);
    if (rotate) canvas.rotate(math.pi);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _UnoCardPainter oldDelegate) =>
      oldDelegate.card.color != card.color ||
      oldDelegate.card.value != card.value ||
      oldDelegate.selected != selected ||
      oldDelegate.enabled != enabled;
}

class _UnoBackPainter extends CustomPainter {
  const _UnoBackPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 100;
    final outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(12 * s),
    );
    canvas.drawShadow(
      Path()..addRRect(outer),
      Colors.black.withValues(alpha: .30),
      7 * s,
      true,
    );
    canvas.drawRRect(outer, Paint()..color = Colors.white);
    final inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(4 * s, 4 * s, size.width - 8 * s, size.height - 8 * s),
      Radius.circular(9 * s),
    );
    canvas.drawRRect(inner, Paint()..color = const Color(0xFF15171B));
    final oval = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * .82,
      height: size.height * .55,
    );
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-math.pi / 8);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.drawOval(oval, Paint()..color = const Color(0xFFED1C24));
    final tp = TextPainter(
      text: TextSpan(
        text: 'UNO',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24 * s,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(size.width / 2 - tp.width / 2, size.height / 2 - tp.height / 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _UnoBackPainter oldDelegate) => false;
}
