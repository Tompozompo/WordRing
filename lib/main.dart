import 'package:flutter/material.dart';
import 'package:rotatingtest/pages/PuzzleListPage.dart';

import 'pages/MainMenu.dart';

void main() async {
  runApp(
        MyApp()
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rings',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MainMenu(),
        '/list': (context) => PuzzleListPage(),
      },
    );
  }
}

