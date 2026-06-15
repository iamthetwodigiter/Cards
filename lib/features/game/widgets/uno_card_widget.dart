import 'package:flutter/material.dart';
import '../models/game_models.dart';
import 'dart:math' as math;

class UnoCardWidget extends StatelessWidget {
  final UnoCard card;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const UnoCardWidget({
    super.key,
    required this.card,
    this.width = 60,
    this.height = 90,
    this.onTap,
  });

  Color _getCardColor() {
    switch (card.color) {
      case CardColor.red:
        return const Color(0xFFE53935);
      case CardColor.blue:
        return const Color(0xFF1E88E5);
      case CardColor.green:
        return const Color(0xFF43A047);
      case CardColor.yellow:
        return const Color(0xFFFFB300);
      case CardColor.wild:
        return const Color(0xFF212121);
    }
  }

  String _getDisplayString() {
    switch (card.value) {
      case CardValue.zero: return "0";
      case CardValue.one: return "1";
      case CardValue.two: return "2";
      case CardValue.three: return "3";
      case CardValue.four: return "4";
      case CardValue.five: return "5";
      case CardValue.six: return "6";
      case CardValue.seven: return "7";
      case CardValue.eight: return "8";
      case CardValue.nine: return "9";
      case CardValue.skip: return "⊘";
      case CardValue.reverse: return "⇄";
      case CardValue.drawTwo: return "+2";
      case CardValue.wild: return "";
      case CardValue.wildDrawFour: return "+4";
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getCardColor();
    final displayStr = _getDisplayString();
    
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return Container(
              margin: EdgeInsets.all(w * 0.05),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(w * 0.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: w * 0.05,
                    offset: Offset(w * 0.02, w * 0.02),
                  )
                ]
              ),
              child: Padding(
                padding: EdgeInsets.all(w * 0.05),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(w * 0.08),
                  ),
                  child: Stack(
                    children: [
                      if (displayStr.isNotEmpty) Positioned(
                        top: w * 0.04,
                        left: w * 0.06,
                        child: Text(
                          displayStr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: displayStr.length > 1 ? w * 0.18 : w * 0.22,
                            fontWeight: FontWeight.bold,
                            shadows: const [Shadow(color: Colors.black54, offset: Offset(1, 1))]
                          ),
                        ),
                      ),
                      if (displayStr.isNotEmpty) Positioned(
                        bottom: w * 0.04,
                        right: w * 0.06,
                        child: Transform.rotate(
                          angle: math.pi,
                          child: Text(
                            displayStr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: displayStr.length > 1 ? w * 0.18 : w * 0.22,
                              fontWeight: FontWeight.bold,
                              shadows: const [Shadow(color: Colors.black54, offset: Offset(1, 1))]
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Transform.rotate(
                          angle: -math.pi / 6,
                          child: Container(
                            width: w * 0.75,
                            height: w * 0.55,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.elliptical(w * 0.75, w * 0.55)),
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: w * 0.02, offset: const Offset(1, 1))
                              ]
                            ),
                            child: Center(
                              child: card.color == CardColor.wild
                                ? _buildWildInner(w)
                                : Text(
                                    displayStr,
                                    style: TextStyle(
                                      color: bgColor,
                                      fontSize: displayStr.length > 1 ? w * 0.32 : w * 0.4,
                                      fontWeight: FontWeight.w900,
                                      shadows: const [Shadow(color: Colors.black26, offset: Offset(1, 1))]
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWildInner(double w) {
    if (card.value == CardValue.wildDrawFour) {
      return Text("+4", style: TextStyle(fontSize: w*0.32, fontWeight: FontWeight.w900, color: Colors.black));
    }
    return Transform.rotate(
      angle: math.pi / 6,
      child: SizedBox(
        width: w * 0.5,
        height: w * 0.5,
        child: GridView.count(
          crossAxisCount: 2,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Container(color: const Color(0xFFE53935), margin: const EdgeInsets.all(1)),
            Container(color: const Color(0xFF1E88E5), margin: const EdgeInsets.all(1)),
            Container(color: const Color(0xFFFFB300), margin: const EdgeInsets.all(1)),
            Container(color: const Color(0xFF43A047), margin: const EdgeInsets.all(1)),
          ],
        ),
      ),
    );
  }
}

class HiddenCardWidget extends StatelessWidget {
  final double width;
  final double height;

  const HiddenCardWidget({super.key, this.width = 80, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          return Container(
            margin: EdgeInsets.all(w * 0.05),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(w * 0.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: w * 0.05,
                  offset: Offset(w * 0.02, w * 0.02),
                )
              ]
            ),
            child: Padding(
              padding: EdgeInsets.all(w * 0.05),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF212121),
                  borderRadius: BorderRadius.circular(w * 0.08),
                ),
                child: Center(
                  child: Transform.rotate(
                    angle: -math.pi / 6,
                    child: Container(
                      width: w * 0.75,
                      height: w * 0.55,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.all(Radius.elliptical(w * 0.75, w * 0.55)),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: w * 0.02, offset: const Offset(1, 1))
                        ]
                      ),
                      child: Center(
                        child: Text(
                          "UNO",
                          style: TextStyle(
                            color: const Color(0xFFFFB300),
                            fontSize: w * 0.25,
                            fontWeight: FontWeight.w900,
                            shadows: const [Shadow(color: Colors.black54, offset: Offset(1, 1))]
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
