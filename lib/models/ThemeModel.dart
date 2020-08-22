import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModel extends ChangeNotifier {
  final colors = {
    Colors.pink,
    Colors.red,
    Colors.deepOrange,
    Colors.orange,
    Colors.amber,
    Colors.yellow,
    Colors.lightGreen,
    Colors.green,
    Colors.teal,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.blueGrey,
    Colors.grey,
  };

  final List<MaterialColor> colorList = [Colors.purple, Colors.blue, Colors.green, Colors.amber, Colors.red, Colors.deepOrange, Colors.blueGrey];

/*
primaryColorBrightness = estimateBrightnessForColor(primarySwatch);

light:
  secondaryHeaderColor = primarySwatch[50];
  primaryColorLight = primarySwatch[100];
  backgroundColor = textSelectionColor = primarySwatch[200];
  textSelectionHandleColor = primarySwatch[300]
  accentColor = primarySwatch[500];
  primaryColor = primarySwatch[500];
  toggleableActiveColor = primarySwatch[600];
  primaryColorDark = primarySwatch[700];
  buttonColor = grey[300]

dark:
 buttonColor = primarySwatch[600];
*/

  MaterialColor primarySwatch;
  Brightness brightness;

  Color get boardColor1 {
    return brightness == Brightness.light ? primarySwatch[400] : desaturate(primarySwatch[400], 0.5);
  }

  Color get boardColor2 {
    return brightness == Brightness.light ? primarySwatch[200] : desaturate(primarySwatch[200], 0.5);
  }

  Color get selectedCellColor {
    return brightness == Brightness.light ? primarySwatch[500] : desaturate(primarySwatch[500], 0.8);
  }

  Color get borderColor {
    return brightness == Brightness.light ? primarySwatch[800] : primarySwatch[500];
  }

  Color get buttonColor {
    return brightness == Brightness.light ? primarySwatch[100] : desaturate(primarySwatch[100], 0.5);
  }

  Color get iconColor {
    return brightness == Brightness.light ? primarySwatch[500] : desaturate(primarySwatch[500], 1);
  }

  Color get disabled {
    return brightness == Brightness.light ? primarySwatch[100] : desaturate(primarySwatch[100], 0.5);
  }

  Color desaturate(Color c, double factor) {
    HSVColor hsvColor = HSVColor.fromColor(c);
    hsvColor = hsvColor.withValue(hsvColor.value*factor);
    return hsvColor.toColor();
  }

  void setPrimarySwatch(Color c) {
    primarySwatch = c;
    notifyListeners();
    save("primarySwatch", colorToString(primarySwatch));
  }

  void toggleBrightness() {
    debugPrint("$brightness");
    brightness = brightness == Brightness.light
        ? Brightness.dark
        : Brightness.light;
    debugPrint("$brightness");
    notifyListeners();
    save("brightness", brightness.toString());
  }

  save(String key, dynamic value) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    if (value is bool) {
      sharedPrefs.setBool(key, value);
    } else if (value is String) {
      sharedPrefs.setString(key, value);
    } else if (value is int) {
      sharedPrefs.setInt(key, value);
    } else if (value is double) {
      sharedPrefs.setDouble(key, value);
    } else if (value is List<String>) {
      sharedPrefs.setStringList(key, value);
    }
  }

  Future<int> loadSettings() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    primarySwatch = stringToColor(sharedPrefs.getString('primarySwatch') ?? "indigo");
    brightness = stringToBrightness(sharedPrefs.getString('brightness') ?? "Brightness.light");
    return 0;
  }

  String colorToString(Color color) {
    if(color == Colors.pink)
      return "pink";
    if(color == Colors.red)
      return "red";
    if(color == Colors.deepOrange)
      return "deepOrange";
    if(color == Colors.orange)
      return "orange";
    if(color == Colors.amber)
      return "amber";
    if(color == Colors.yellow)
      return "yellow";
    if(color == Colors.lightGreen)
      return "lightGreen";
    if(color == Colors.green)
      return "green";
    if(color == Colors.teal)
      return "teal";
    if(color == Colors.blue)
      return "blue";
    if(color == Colors.indigo)
      return "indigo";
    if(color == Colors.purple)
      return "purple";
    if(color == Colors.blueGrey)
      return "blueGrey";
    if(color == Colors.grey)
      return "grey";
    return "indigo";
  }

  Color stringToColor(String color) {
    switch(color) {
      case "pink":
        return Colors.pink;
      case "red":
        return Colors.red;
      case "deepOrange":
        return Colors.deepOrange;
      case "orange":
        return Colors.orange;
      case "amber":
        return Colors.amber;
      case "yellow":
        return Colors.yellow;
      case "lightGreen":
        return Colors.lightGreen;
      case "green":
        return Colors.green;
      case "teal":
        return Colors.teal;
      case "blue":
        return Colors.blue;
      case "indigo":
        return Colors.indigo;
      case "purple":
        return Colors.purple;
      case "blueGrey":
        return Colors.blueGrey;
      case "grey":
        return Colors.grey;
      default:
        return Colors.indigo;
    }
  }

  Brightness stringToBrightness(String brightness) {
    switch(brightness) {
      case "Brightness.light":
        return Brightness.light;
      case "Brightness.dark":
        return Brightness.dark;
      default:
        return Brightness.light;
    }
  }
}