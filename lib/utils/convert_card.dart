import 'package:playing_cards/playing_cards.dart'; // For PlayingCard, CardValue, Suit
import 'package:poker_solver/poker_solver.dart'; // For Card (from poker_solver)

class CardConverter {
  static Card convertToPokerCard(PlayingCard card) {
    const valueMap = {
      CardValue.two: '2',
      CardValue.three: '3',
      CardValue.four: '4',
      CardValue.five: '5',
      CardValue.six: '6',
      CardValue.seven: '7',
      CardValue.eight: '8',
      CardValue.nine: '9',
      CardValue.ten: 'T',
      CardValue.jack: 'J',
      CardValue.queen: 'Q',
      CardValue.king: 'K',
      CardValue.ace: 'A',
    };
    const suitMap = {
      Suit.clubs: 'c',
      Suit.diamonds: 'd',
      Suit.hearts: 'h',
      Suit.spades: 's',
    };
    final code = valueMap[card.value]! + suitMap[card.suit]!;
    return Card(code);
  }
}

// PlayingCard convertToPlayingCard(Card card) {
//   const valueMap = {
//     '2': CardValue.two,
//     '3': CardValue.three,
//     '4': CardValue.four,
//     '5': CardValue.five,
//     '6': CardValue.six,
//     '7': CardValue.seven,
//     '8': CardValue.eight,
//     '9': CardValue.nine,
//     'T': CardValue.ten,
//     'J': CardValue.jack,
//     'Q': CardValue.queen,
//     'K': CardValue.king,
//     'A': CardValue.ace,
//   };
//   const suitMap = {
//     'c': Suit.clubs,
//     'd': Suit.diamonds,
//     'h': Suit.hearts,
//     's': Suit.spades,
//   };
//   return PlayingCard(suit: suitMap[card.suit]!, value: valueMap[card.value]!);
// }
