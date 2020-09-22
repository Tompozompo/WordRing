import 'dart:io';
import 'dart:typed_data';
import 'dart:async' show Future;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';

import '../models/RingPuzzleModel.dart';

class DatabasePuzzleFactory {
  Future<Database> getDatabase() async {
    debugPrint("database");
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "puzzles.db");
    debugPrint(path);
//    var exists = await databaseExists(path);
//    if (!exists) {
    debugPrint("Creating new copy from asset");
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}
    ByteData data = await rootBundle.load(join("assets", "puzzles.db"));
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
//    } else {
//      debugPrint("Opening existing database");
//    }
    return openDatabase(path, readOnly: true);
  }

  Future<List> getPuzzleList() async {
    var db = await getDatabase();
    String puzzleQuery = '''
    SELECT id, center, COUNT(puzzle) as words
    FROM puzzles 
    JOIN solutions 
    ON id = puzzle
    GROUP BY puzzle
    ''';
    var dbResult = (await db.rawQuery(puzzleQuery));

    return dbResult;
  }

  Future<RingPuzzleModel> getPuzzle(int id, AnimationController transformController, AnimationController centerController, Function endCallback) async {
    var db = await getDatabase();

    String puzzleQuery = '''
    SELECT *
    FROM puzzles p
    WHERE id = $id
    ''';
    var dbResult = (await db.rawQuery(puzzleQuery)).first;
    print(dbResult.toString());

    RingPuzzleModel m = new RingPuzzleModel(
        dbResult["ringCount"], dbResult["segmentCount"], dbResult["center"], transformController, centerController, (ringIndex, segmentIndex, id) => dbResult["letters"][id]
    );

    String wordsQuery = '''
    SELECT *
    FROM solutions 
    WHERE puzzle = ${dbResult['id']}
    ''';
    var dbWords = (await db.rawQuery(wordsQuery));
    dbWords.forEach((element) {
      debugPrint(element['word']);
      m.words.add(element['word']);
    });
    m.endCallbacks.clear();
    m.endCallbacks.add(endCallback);

    return m;
  }
}