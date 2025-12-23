import "dart:math";

import 'package:flutter_test/flutter_test.dart';

import 'package:block_flow/logic/game_state.dart';
import 'package:block_flow/logic/block_shapes.dart';

void main() {
  test('newGame creates empty board and 3 blocks', () {
    final s = GameState(rng: _fixedRng());
    s.newGame();
    expect(s.board.length, 64);
    expect(s.board.where((e) => e == 1).length, 0);
    expect(s.hand.length, 3);
  });

  test('canPlace respects bounds and collisions', () {
    final s = GameState(rng: _fixedRng());
    s.newGame();
    final shape = const BlockShape('i2', [[1, 1]]);
    expect(s.canPlace(shape, 0, 0), isTrue);
    expect(s.canPlace(shape, 0, 7), isFalse); // out of bounds (w=2)

    // collision
    s.board[0] = 1;
    expect(s.canPlace(shape, 0, 0), isFalse);
  });

  test('placeFromHand fills cells, scores, and can undo once', () {
    final s = GameState(rng: _fixedRng());
    s.newGame();

    // Force hand to known shape
    s.hand = [const BlockShape('dot', [[1]]), ...s.hand.skip(1)];

    final ok = s.placeFromHand(0, 0, 0);
    expect(ok, isTrue);
    expect(s.board[0], 1);
    expect(s.score >= 1, isTrue);

    expect(s.canUndo(), isTrue);
    final u = s.undo();
    expect(u, isTrue);
    expect(s.board[0], 0);
    expect(s.canUndo(), isFalse); // only once
  });

  test('clears full row', () {
    final s = GameState(rng: _fixedRng());
    s.newGame();

    // prepare row 0 with 7 filled, then place dot
    for (int c = 0; c < 7; c++) {
      s.board[0 * 8 + c] = 1;
    }
    s.hand = [const BlockShape('dot', [[1]]), ...s.hand.skip(1)];

    final ok = s.placeFromHand(0, 0, 7);
    expect(ok, isTrue);

    // row should be cleared
    expect(s.board.sublist(0, 8).every((e) => e == 0), isTrue);
  });
}

// Deterministic RNG for tests
class _fixedRng implements Random {
  int _i = 0;
  @override
  int nextInt(int max) {
    _i = (_i + 1) % max;
    return _i;
  }

  // Unused members in these tests
  @override
  bool nextBool() => nextInt(2) == 0;
  @override
  double nextDouble() => nextInt(1000) / 1000.0;
  @override
  double nextExponential() => 0;
}
