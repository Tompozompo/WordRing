import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/MainMenu.dart';
import 'models/ThemeModel.dart';
import 'models/TimerModel.dart';

void main() async {
  runApp(
    ChangeNotifierProvider<ThemeModel>(
      create: (context) => ThemeModel(),
      child: ChangeNotifierProvider<TimerModel>(
          create: (context) => TimerModel(),
          child: LoadingThemePage()
      ),
    ),
  );
}

class LoadingThemePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: Provider.of<ThemeModel>(context, listen: false).loadSettings(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        Widget child;
        if (!snapshot.hasData) {
          child = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  child: CircularProgressIndicator(),
                  width: 60,
                  height: 60,
                ),
              ]
          );
        } else if (snapshot.hasError) {
          child = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Error: ${snapshot.error}'),
                )
              ]
          );
        } else {
          child = MyApp();
        }
        return child;
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
        builder: (context, model, child) {
          return MaterialApp(
            title: 'Rings',
            theme: ThemeData(
              brightness: model.brightness,
              primarySwatch: model.primarySwatch,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: child,
          );
        },
      child: MainMenu(),
    );
  }
}

