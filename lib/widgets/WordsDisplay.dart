import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/RingPuzzleModel.dart';

class WordsDisplay extends StatelessWidget {
  final RingPuzzleModel model;

  WordsDisplay(this.model);

  List<Widget> _getWords(List<String> foundWords) {
    var words = new List<Widget>();
    List allWords = model.words.toList()..sort((a, b) {
      if (a.length == b.length) {
        return a.toString().compareTo(b.toString());
      } else {
        return a.length.compareTo(b.length);
      }
    });
    allWords.forEach((word) {
      words.add(Word(model, word, foundWords.contains(word)));
    });
    return words;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        debugPrint("constraints.maxHeight ${constraints.maxHeight}");
        debugPrint("constraints.maxWidth ${constraints.maxWidth}");
        return StreamBuilder<List<String>>(
          stream: model.foundWordsStream,
          builder: (context, snapshot) {
            var foundWords = !snapshot.hasData ? new List<String>() : snapshot.data;
            return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _getWords(foundWords)
            );
          }
        );
      }
    );
  }
}

class Word extends StatelessWidget {
  final RingPuzzleModel model;
  final String word;
  final bool hidden;

  Word(this.model, this.word, this.hidden);

  List<Widget> _getLetters() {
    List<Widget> letters = new List<Widget>();
    for (int i = 0; i < word.length; i++) {
      var l = word[i];
      letters.add(Letter(model, l, hidden));
    }
    return letters;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _getLetters()
    );
  }
}

class Letter extends StatelessWidget {
  final RingPuzzleModel model;
  final String letter;
  final bool hidden;

  Letter(this.model, this.letter, this.hidden);

  @override
  Widget build(BuildContext context) {
    if (hidden) {
      return Padding(
        padding: EdgeInsets.all(1),
        child: Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
              border: Border.all(
                  width: 1
              )
          ),
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: Stack(
              children: <Widget>[
                // Stroked text as border.
                Text(
                  letter,
                  style: TextStyle(
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 1
                      ..color = Colors.black,
                  ),
                ),
                // Solid text as fill.
                Text(
                  letter,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
              border: Border.all(
                  width: 1
              )
          )
      );
    }
  }
}