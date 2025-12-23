import 'package:flutter/material.dart';

import 'pages/title_page.dart';

void main() {
  runApp(const BlockFlowApp());
}

class BlockFlowApp extends StatelessWidget {
  const BlockFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const TitlePage(),
    );
  }
}
