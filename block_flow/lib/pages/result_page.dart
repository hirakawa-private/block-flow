import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final int score;
  final int best;
  const ResultPage({super.key, required this.score, required this.best});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('RESULT', style: TextStyle(fontSize: 28)),
            const SizedBox(height: 12),
            Text('Score: $score', style: const TextStyle(fontSize: 20)),
            Text('Best:  $best', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
