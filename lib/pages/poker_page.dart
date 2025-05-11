import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_date/widgets/menu_widget.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:poker_solver/poker_solver.dart';
import 'package:movie_date/utils/convert_card.dart';

class PokerPage extends ConsumerStatefulWidget {
  
  static Route<void> route({String mRoomId = ''}) {
    return MaterialPageRoute(
      builder: (context) => PokerPage(),
    );
  }

  const PokerPage({Key? key}) : super(key: key);

  @override
  _PokerPageState createState() => _PokerPageState();
}

class _PokerPageState extends ConsumerState<PokerPage> {
   List<PlayingCard> deck = [];
  List<PlayingCard> player1 = [];
  List<PlayingCard> player2 = [];
  List<PlayingCard> community = [];
  List<PlayingCard> burnPile = [];
  bool showBacks = true;
  String? player1Hand = '';
  String? player2Hand = '';
  String result = '';
  String? selectedBetMultiplier;
  List<String> availableMultipliers = ['3x', '4x'];
  int checkRound = 0;
  bool gameEnded = false;

  @override
  void initState() {
    super.initState();
    _dealHands();
  }

  void _dealHands() {
    // build & shuffle
    deck = List.from(standardFiftyFourCardDeck())
      ..removeWhere(
          (c) => c.value == CardValue.joker_1 || c.value == CardValue.joker_2)
      ..shuffle(Random());

    // deal hole cards
    player1 = [deck.removeAt(0), deck.removeAt(0)];
    player2 = [deck.removeAt(0), deck.removeAt(0)];

    // flop
    burnPile.add(deck.removeAt(0));
    community.addAll([deck.removeAt(0), deck.removeAt(0), deck.removeAt(0)]);
    // turn
    burnPile.add(deck.removeAt(0));
    community.add(deck.removeAt(0));
    // river
    burnPile.add(deck.removeAt(0));
    community.add(deck.removeAt(0));

    setState(() {});
  }

  void _evaluateHands() {
    final comm = community.map(CardConverter.convertToPokerCard).toList();
    final h1 = Hand.solveHand(
        [...player1.map(CardConverter.convertToPokerCard), ...comm]);
    final h2 = Hand.solveHand(
        [...player2.map(CardConverter.convertToPokerCard), ...comm]);
    final winners = Hand.winners([h1, h2]);

    setState(() {
      showBacks = false;
      // store each player's best hand name
      player1Hand = h1.descr;
      player2Hand = h2.descr;

      if (winners.length == 2) {
        result = 'Tie: ${h1.name}';
      } else if (winners[0] == h1) {
        result = 'Player 1 wins with ${h1.descr}';
      } else {
        result = 'Player 2 wins with ${h2.descr}';
      }
    });
  }

  void _handleBet() {
    setState(() {
      gameEnded = true;
      showBacks = false; // Show all cards face up
    });
    _evaluateHands();
  }

  void _handleCheck() {
    setState(() {
      checkRound++;
      if (checkRound == 1) {
        // Show first 3 community cards and update dropdown to 2x
        // for (int i = 0; i < 3; i++) {
        //   community[i] = community[i];
        // }
        availableMultipliers = ['2x'];
        selectedBetMultiplier = '2x';
      } else if (checkRound == 2) {
        // Show remaining 2 community cards and update dropdown to 1x
        // for (int i = 3; i < 5; i++) {
        //   community[i] = community[i];
        // }
        availableMultipliers = ['1x'];
        selectedBetMultiplier = '1x';
      } else if (checkRound == 3) {
        // Fold was clicked
        gameEnded = true;
        showBacks = false; // Show all cards face up
      }
    });
  }

  void _resetGame() {
    setState(() {
      // Reset all state variables
      showBacks = true;
      player1Hand = '';
      player2Hand = '';
      result = '';
      selectedBetMultiplier = '3x';
      availableMultipliers = ['3x', '4x'];
      checkRound = 0;
      gameEnded = false;

      // Clear and redeal cards
      community.clear();
      burnPile.clear();
      _dealHands();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Texas Hold\'em POC'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hole cards & best hand
            Text(
              'Player 1: $player1Hand',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: player1
                  .map((c) => SizedBox(
                        width: 160,
                        height: 160 * (89.0 / 64.0),
                        child: PlayingCardView(card: c, showBack: false),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Text(
              'Player 2: $player2Hand',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: player2
                  .map((c) => SizedBox(
                        width: 160,
                        height: 160 * (89.0 / 64.0),
                        child: PlayingCardView(card: c, showBack: showBacks),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            // Community cards
            const Text('Community Cards:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: community.asMap().entries.map((entry) {
                final index = entry.key;
                final card = entry.value;
                if (gameEnded) {
                  return SizedBox(
                    width: 160,
                    height: 160 * (89.0 / 64.0),
                    child: PlayingCardView(
                      card: card,
                      showBack: false,
                    ),
                  );
                } else {
                  return SizedBox(
                    width: 160,
                    height: 160 * (89.0 / 64.0),
                    child: PlayingCardView(
                      card: card,
                      showBack: index < 3 ? checkRound < 1 : checkRound < 2,
                    ),
                  );
                }
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Add these buttons before the Evaluate button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed:
                      gameEnded ? null : (checkRound < 3 ? _handleCheck : null),
                  child: Text(checkRound < 2 ? 'Check' : 'Fold'),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: selectedBetMultiplier ?? availableMultipliers.first,
                  items: availableMultipliers
                      .map((multiplier) => DropdownMenuItem(
                            value: multiplier,
                            child: Text(multiplier),
                          ))
                      .toList(),
                  onChanged: gameEnded
                      ? null
                      : (value) {
                          setState(() {
                            selectedBetMultiplier = value;
                          });
                        },
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: gameEnded ? null : _handleBet,
                  child: const Text('Bet'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _evaluateHands,
              child: const Text('Evaluate Hands'),
            ),
            if (result.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(result, style: const TextStyle(fontSize: 16)),
            ],
            if (gameEnded) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _resetGame,
                child: const Text('Deal Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
}
