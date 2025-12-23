import 'package:flutter/material.dart';

import '../logic/game_state.dart';
import '../storage/prefs.dart';
import 'result_page.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final GameState state = GameState();
  int best = 0;

  @override
  void initState() {
    super.initState();
    state.newGame();
    Prefs.loadBest().then((v) {
      if (!mounted) return;
      setState(() => best = v);
    });
  }

  Future<void> _finishIfNeeded() async {
    if (!state.isGameOver()) return;
    if (state.score > best) {
      best = state.score;
      await Prefs.saveBest(best);
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultPage(score: state.score, best: best),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // NOTE: UI is intentionally minimal. Next step is full drag/drop grid.
    return Scaffold(
      appBar: AppBar(
        title: Text('Score ${state.score}   Best $best'),
        actions: [
          IconButton(
            onPressed: state.canUndo()
                ? () {
                    setState(() {
                      state.undo();
                    });
                  }
                : null,
            icon: const Icon(Icons.undo),
          ),
          IconButton(
            onPressed: () {
              setState(state.newGame);
            },
            icon: const Icon(Icons.restart_alt),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'MVP scaffold\nNext: implement drag/drop placement UI.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _BoardPreview(cells: state.board),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (i) {
                final b = state.hand[i];
                return ElevatedButton(
                  onPressed: () async {
                    // TEMP: place at first available spot for quick smoke test
                    bool placed = false;
                    for (int r = 0; r <= GameState.size - b.h && !placed; r++) {
                      for (int c = 0; c <= GameState.size - b.w && !placed; c++) {
                        if (state.canPlace(b, r, c)) {
                          setState(() {
                            state.placeFromHand(i, r, c);
                          });
                          placed = true;
                        }
                      }
                    }
                    await _finishIfNeeded();
                  },
                  child: Text(b.id),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoardPreview extends StatelessWidget {
  final List<int> cells;
  const _BoardPreview({required this.cells});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: GameState.size,
        ),
        itemCount: GameState.size * GameState.size,
        itemBuilder: (_, i) {
          final filled = cells[i] == 1;
          return Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white12),
              color: filled ? Colors.white24 : Colors.transparent,
            ),
          );
        },
      ),
    );
  }
}
