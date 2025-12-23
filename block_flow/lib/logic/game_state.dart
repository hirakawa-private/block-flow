import 'dart:math';

import 'block_shapes.dart';

class MoveSnapshot {
  final List<int> board; // 64
  final int score;
  final List<String> handIds; // 3
  const MoveSnapshot(this.board, this.score, this.handIds);
}

class GameState {
  static const int size = 8;
  final Random _rng;

  List<int> board = List.filled(size * size, 0); // 0 empty, 1 filled
  int score = 0;

  // hand: 3 blocks
  List<BlockShape> hand = const [];

  // undo (one-step, one-use)
  MoveSnapshot? _snapshot;
  bool undoUsed = false;

  GameState({Random? rng}) : _rng = rng ?? Random();

  void newGame() {
    board = List.filled(size * size, 0);
    score = 0;
    undoUsed = false;
    _snapshot = null;
    _refillHand();
  }

  void _refillHand() {
    hand = List.generate(3, (_) => kShapes[_rng.nextInt(kShapes.length)]);
  }

  bool canPlace(BlockShape shape, int top, int left) {
    for (int r = 0; r < shape.h; r++) {
      for (int c = 0; c < shape.w; c++) {
        if (shape.cells[r][c] == 0) continue;
        final rr = top + r;
        final cc = left + c;
        if (rr < 0 || rr >= size || cc < 0 || cc >= size) return false;
        if (board[rr * size + cc] == 1) return false;
      }
    }
    return true;
  }

  bool anyPlacementExists(BlockShape shape) {
    for (int r = 0; r <= size - shape.h; r++) {
      for (int c = 0; c <= size - shape.w; c++) {
        if (canPlace(shape, r, c)) return true;
      }
    }
    return false;
  }

  bool isGameOver() {
    if (hand.isEmpty) return true;
    return hand.every((b) => !anyPlacementExists(b));
  }

  bool placeFromHand(int handIndex, int top, int left) {
    if (handIndex < 0 || handIndex >= hand.length) return false;
    final shape = hand[handIndex];
    if (!canPlace(shape, top, left)) return false;

    // snapshot for 1-step undo
    _snapshot = MoveSnapshot(
      List.from(board),
      score,
      hand.map((e) => e.id).toList(),
    );

    // place
    for (int r = 0; r < shape.h; r++) {
      for (int c = 0; c < shape.w; c++) {
        if (shape.cells[r][c] == 0) continue;
        board[(top + r) * size + (left + c)] = 1;
      }
    }

    // score for placement
    score += shape.filledCount;

    // clear lines
    final cleared = _clearFullLines();
    score += cleared * size;

    // replace used block (MVP)
    hand = List.of(hand);
    hand[handIndex] = kShapes[_rng.nextInt(kShapes.length)];

    return true;
  }

  int _clearFullLines() {
    final rowsToClear = <int>[];
    final colsToClear = <int>[];

    // rows
    for (int r = 0; r < size; r++) {
      bool full = true;
      for (int c = 0; c < size; c++) {
        if (board[r * size + c] == 0) {
          full = false;
          break;
        }
      }
      if (full) rowsToClear.add(r);
    }

    // cols
    for (int c = 0; c < size; c++) {
      bool full = true;
      for (int r = 0; r < size; r++) {
        if (board[r * size + c] == 0) {
          full = false;
          break;
        }
      }
      if (full) colsToClear.add(c);
    }

    // clear
    for (final r in rowsToClear) {
      for (int c = 0; c < size; c++) {
        board[r * size + c] = 0;
      }
    }
    for (final c in colsToClear) {
      for (int r = 0; r < size; r++) {
        board[r * size + c] = 0;
      }
    }

    return rowsToClear.length + colsToClear.length;
  }

  bool canUndo() => !undoUsed && _snapshot != null;

  bool undo() {
    if (!canUndo()) return false;
    final s = _snapshot!;
    board = List.from(s.board);
    score = s.score;

    final map = {for (final b in kShapes) b.id: b};
    hand = s.handIds.map((id) => map[id] ?? kShapes.first).toList();

    undoUsed = true;
    _snapshot = null;
    return true;
  }
}
