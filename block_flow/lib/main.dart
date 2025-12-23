import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const GamePage(),
    );
  }
}

class BlockShape {
  final String id;
  final List<List<int>> cells; // 1 = filled, 0 = empty

  const BlockShape(this.id, this.cells);

  int get h => cells.length;
  int get w => cells.first.length;

  int get filledCount {
    int c = 0;
    for (final row in cells) {
      for (final v in row) {
        if (v == 1) c++;
      }
    }
    return c;
  }
}

// いくつかの形（シンプルなやつだけ）
const List<BlockShape> kShapes = [
  BlockShape("dot", [
    [1],
  ]),
  BlockShape("i2", [
    [1, 1],
  ]),
  BlockShape("i3", [
    [1, 1, 1],
  ]),
  BlockShape("o2", [
    [1, 1],
    [1, 1],
  ]),
  BlockShape("l3", [
    [1, 0],
    [1, 1],
  ]),
  BlockShape("t", [
    [1, 1, 1],
    [0, 1, 0],
  ]),
];

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static const int size = 8;
  final Random _rng = Random();

  // 0 = empty, 1 = filled
  List<List<int>> board =
      List.generate(size, (_) => List.filled(size, 0));

  // 手札3つ（nullは使い切った状態）
  List<BlockShape?> hand = [null, null, null];

  @override
  void initState() {
    super.initState();
    _refillHand();
  }

  void _refillHand() {
    setState(() {
      for (int i = 0; i < 3; i++) {
        hand[i] = kShapes[_rng.nextInt(kShapes.length)];
      }
    });
  }

  bool canPlace(BlockShape shape, int top, int left) {
    for (int r = 0; r < shape.h; r++) {
      for (int c = 0; c < shape.w; c++) {
        if (shape.cells[r][c] == 0) continue;
        final rr = top + r;
        final cc = left + c;
        if (rr < 0 || rr >= size || cc < 0 || cc >= size) return false;
        if (board[rr][cc] == 1) return false;
      }
    }
    return true;
  }

  void placeShape(int handIndex, int top, int left) {
    final shape = hand[handIndex];
    if (shape == null) return;
    if (!canPlace(shape, top, left)) return;

    setState(() {
      for (int r = 0; r < shape.h; r++) {
        for (int c = 0; c < shape.w; c++) {
          if (shape.cells[r][c] == 0) continue;
          board[top + r][left + c] = 1;
        }
      }

      _clearLines();

      // 使ったブロックは消す
      hand[handIndex] = null;

      // 全部使い切ったら補充
      if (hand.every((b) => b == null)) {
        _refillHand();
      }
    });
  }

  void _clearLines() {
    // 行
    for (int r = 0; r < size; r++) {
      if (board[r].every((v) => v == 1)) {
        board[r] = List.filled(size, 0);
      }
    }
    // 列
    for (int c = 0; c < size; c++) {
      bool full = true;
      for (int r = 0; r < size; r++) {
        if (board[r][c] == 0) {
          full = false;
          break;
        }
      }
      if (full) {
        for (int r = 0; r < size; r++) {
          board[r][c] = 0;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double cellSize = MediaQuery.of(context).size.width / 9;

    return Scaffold(
      backgroundColor: const Color(0xFF2B1E16),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'Block 8×8',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 12),

            // 盤面
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1410),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(size, (r) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(size, (c) {
                        return DragTarget<Map<String, int>>(
                          onWillAccept: (data) {
                            if (data == null) return false;
                            final idx = data['handIndex']!;
                            final shape = hand[idx];
                            if (shape == null) return false;
                            return canPlace(shape, r, c);
                          },
                          onAccept: (data) {
                            final idx = data['handIndex']!;
                            placeShape(idx, r, c);
                          },
                          builder: (_, __, isOver) {
                            final filled = board[r][c] == 1;
                            return Container(
                              width: cellSize,
                              height: cellSize,
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: filled
                                    ? const Color(0xFF6B8E23)
                                    : const Color(0xFF4A3628),
                                borderRadius: BorderRadius.circular(4),
                                border: isOver
                                    ? Border.all(
                                        color: Colors.white30, width: 2)
                                    : null,
                              ),
                            );
                          },
                        );
                      }),
                    );
                  }),
                ),
              ),
            ),

            const Spacer(),

            // 手札3つ
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final shape = hand[i];
                  if (shape == null) {
                    return Container(
                      width: cellSize * 3,
                      height: cellSize * 3,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                    );
                  }
                  return Draggable<Map<String, int>>(
                    data: {'handIndex': i},
                    feedback: shapeWidget(shape, cellSize, 0.8),
                    childWhenDragging:
                        Opacity(opacity: 0.3, child: shapeWidget(shape, cellSize, 1.0)),
                    child: shapeWidget(shape, cellSize, 1.0),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget shapeWidget(BlockShape shape, double cellSize, double scale) {
    final double w = shape.w * cellSize;
    final double h = shape.h * cellSize;
    return Container(
      width: w,
      height: h,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(shape.h, (r) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(shape.w, (c) {
              final filled = shape.cells[r][c] == 1;
              return Container(
                width: cellSize,
                height: cellSize,
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: filled
                      ? const Color(0xFF6B8E23)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: filled
                      ? const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ]
                      : null,
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}
