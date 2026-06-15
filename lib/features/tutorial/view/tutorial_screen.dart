import 'package:flutter/material.dart';
import '../../game/widgets/uno_card_widget.dart';
import '../../game/models/game_models.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _tutorialSteps = [
    {
      "title": "Welcome to UNO!",
      "description": "The goal is to get rid of all your cards. You can play a card if it matches the color or the number of the top card on the discard pile.",
      "ui": _BasicMatchingUI(),
    },
    {
      "title": "Action Cards",
      "description": "Special cards change the flow of the game! Skip forces the next player to lose their turn. Reverse changes the direction of play. +2 forces the next player to draw 2 cards and skip.",
      "ui": _ActionCardsUI(),
    },
    {
      "title": "Wild Cards",
      "description": "Wild cards can be played on ANY card. They allow you to change the current color. The +4 Wild card also forces the next player to draw 4 cards!",
      "ui": _WildCardsUI(),
    },
    {
      "title": "First & Last Cards",
      "description": "House Rule: The very first card you play, and the very last card you play, MUST be a standard 0-9 number card. You cannot win on an Action or Wild card!",
      "ui": _FirstLastCardUI(),
    },
    {
      "title": "Stacking +2s and +4s",
      "description": "House Rule: If someone plays a +2 on you, you can play another +2 to pass the penalty! It stacks infinitely as long as players keep dropping +2s. The same works for +4s, but you cannot mix +2s and +4s.",
      "ui": _StackingRuleUI(),
    },
    {
      "title": "No Valid Moves?",
      "description": "If you don't have a matching card, you must draw one from the deck. If the drawn card is playable, you can play it immediately. If not, your turn automatically passes.",
      "ui": _NoMovesUI(),
    },
    {
      "title": "Call UNO!",
      "description": "When you play your second-to-last card, you MUST click 'Call UNO'. If you forget, and an opponent clicks it before you do, they will CATCH you and you'll draw a 2-card penalty!",
      "ui": _CallUnoUI(),
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      appBar: AppBar(
        title: const Text("How to Play", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _tutorialSteps.length,
                itemBuilder: (context, index) {
                  final step = _tutorialSteps[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          step["title"],
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          step["description"],
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: step["ui"],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _tutorialSteps.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? Colors.white : Colors.white38,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage > 0)
                TextButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text("Back", style: TextStyle(color: Colors.white70, fontSize: 18)),
                )
              else
                const SizedBox(width: 60),
              
              if (_currentPage < _tutorialSteps.length - 1)
                ElevatedButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green[800],
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text("Next", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                )
              else
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text("Finish", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          if (_currentPage == _tutorialSteps.length - 1) ...[
            const SizedBox(height: 16),
            const Center(
              child: Text(
                "You can replay this tutorial anytime from the Settings page.",
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class _BasicMatchingUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Text("Discard Pile", style: TextStyle(color: Colors.white, fontSize: 16)),
        SizedBox(
          height: 120,
          child: UnoCardWidget(card: UnoCard(color: CardColor.red, value: CardValue.five)),
        ),
        const Icon(Icons.arrow_downward, color: Colors.white54, size: 32),
        const Text("Your Hand (Playable Cards)", style: TextStyle(color: Colors.white, fontSize: 16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 100, child: UnoCardWidget(card: UnoCard(color: CardColor.red, value: CardValue.nine))),
            const SizedBox(width: 10),
            SizedBox(height: 100, child: UnoCardWidget(card: UnoCard(color: CardColor.blue, value: CardValue.five))),
          ],
        )
      ],
    );
  }
}

class _ActionCardsUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 120, child: UnoCardWidget(card: UnoCard(color: CardColor.yellow, value: CardValue.skip))),
          const SizedBox(width: 10),
          SizedBox(height: 120, child: UnoCardWidget(card: UnoCard(color: CardColor.green, value: CardValue.reverse))),
          const SizedBox(width: 10),
          SizedBox(height: 120, child: UnoCardWidget(card: UnoCard(color: CardColor.blue, value: CardValue.drawTwo))),
        ],
      ),
    );
  }
}

class _WildCardsUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 150, child: UnoCardWidget(card: UnoCard(color: CardColor.wild, value: CardValue.wild))),
          const SizedBox(width: 20),
          SizedBox(height: 150, child: UnoCardWidget(card: UnoCard(color: CardColor.wild, value: CardValue.wildDrawFour))),
        ],
      ),
    );
  }
}

class _FirstLastCardUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.greenAccent, size: 40),
            const SizedBox(width: 16),
            SizedBox(height: 100, child: UnoCardWidget(card: UnoCard(color: CardColor.red, value: CardValue.seven))),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel, color: Colors.redAccent, size: 40),
            const SizedBox(width: 16),
            SizedBox(height: 100, child: UnoCardWidget(card: UnoCard(color: CardColor.blue, value: CardValue.skip))),
          ],
        ),
      ],
    );
  }
}

class _NoMovesUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Center(
                child: Text("UNO", style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 20),
            const Icon(Icons.arrow_forward, color: Colors.white),
            const SizedBox(width: 20),
            SizedBox(height: 120, child: UnoCardWidget(card: UnoCard(color: CardColor.green, value: CardValue.three))),
          ],
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text("Skip Turn", style: TextStyle(color: Colors.white)),
        )
      ],
    );
  }
}

class _StackingRuleUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Pass the penalty!", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 16,
          children: [
            Column(
              children: [
                const Text("They play +2", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                SizedBox(height: 100, child: UnoCardWidget(card: UnoCard(color: CardColor.blue, value: CardValue.drawTwo))),
              ],
            ),
            const Icon(Icons.add, color: Colors.white, size: 32),
            Column(
              children: [
                const Text("You play +2", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                SizedBox(height: 100, child: UnoCardWidget(card: UnoCard(color: CardColor.red, value: CardValue.drawTwo))),
              ],
            ),
            const Icon(Icons.add, color: Colors.white, size: 32),
            Column(
              children: [
                const Text("Next plays +2", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                SizedBox(height: 100, child: UnoCardWidget(card: UnoCard(color: CardColor.green, value: CardValue.drawTwo))),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text("...and so on! Final player draws 6!", style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      ],
    );
  }
}

class _CallUnoUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          child: const Text("Call UNO", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 40),
        const Text("Or catch an opponent:", style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text("Player 2", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(width: 20),
            SizedBox(height: 60, child: UnoCardWidget(card: UnoCard(color: CardColor.blue, value: CardValue.zero))),
          ],
        ),
      ],
    );
  }
}
