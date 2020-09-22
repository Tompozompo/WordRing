import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../models/RingPuzzleModel.dart';
import 'BorderedLetter.dart';

class WordsDisplay extends StatefulWidget {
  final RingPuzzleModel model;

  WordsDisplay(this.model);

  @override
  _WordsDisplayState createState() => _WordsDisplayState();
}

class _WordsDisplayState extends State<WordsDisplay> with TickerProviderStateMixin {
  Animation<double> _glowRadius;
  Animation<Color> _glowColor;
  AnimationController _glowRadiusController;
  AnimationController _glowColorController;

  @override
  void initState() {
    super.initState();
    _glowRadiusController = new AnimationController(
        duration: new Duration(seconds: 5),
        vsync: this
    );
    _glowColorController = new AnimationController(
        duration: new Duration(minutes: 1),
        vsync: this
    );

    _glowRadius = Tween<double>(begin: 0, end: 10).animate(_glowRadiusController);
    _glowRadiusController.repeat(reverse: true);
    _glowColor = ColorTween(begin: Colors.yellow, end: Colors.deepOrange)
        .animate(_glowColorController);
    _glowColorController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowRadiusController.dispose();
    _glowColorController.dispose();
    super.dispose();
  }

  _getCols(int columns, double height, double width) {
    int maxRow = (widget.model.words.length / columns).ceil();
    double h = height / maxRow;
    double columnW = width / columns;
    int maxLength = widget.model.words.map((e) => e.length).reduce(math.max);
    double w = columnW / maxLength;
    double min = math.min(h, w);
    var cols = new List<Widget>();
    for (int i = 0; i < widget.model.words.length; i += maxRow) {
      cols.add(
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _getWords(i, maxRow, min, min),
          )
      );
    }
    return cols;
  }

  List<Widget> _getWords(int start, int length, double height, double width) {
    var words = new List<Widget>();
    var allWords = widget.model.words.toList()
      ..sort((a, b) {
        if (a.length == b.length) {
          return a.toString().compareTo(b.toString());
        } else {
          return a.length.compareTo(b.length);
        }
      });
    for (int i = start; i < math.min(start + length, widget.model.words.length); i++) {
      words.add(Word(widget.model.foundWordsStream, allWords, i, height, width));
    }
    return words;
  }

  int _getColumnNumber() {
    if (widget.model.words.length < 5) {
      return 1;
    } else if (widget.model.words.length < 13) {
      return 2;
    } else if (widget.model.words.length < 22) {
      return 3;
    } else {
      return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          debugPrint("constraints.maxHeight ${constraints.maxHeight}");
          debugPrint("constraints.maxWidth ${constraints.maxWidth}");
          int columns = _getColumnNumber();
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _getCols(columns, constraints.maxHeight, constraints.maxWidth)
          );
        }
    );
  }

  /*
    @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          debugPrint("constraints.maxHeight ${constraints.maxHeight}");
          debugPrint("constraints.maxWidth ${constraints.maxWidth}");
          int columns = _getColumnNumber();
          return AnimatedBuilder(
              animation: _glowColorController,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _getCols(columns, constraints.maxHeight, constraints.maxWidth)
              ),
              builder: (context, child) {
                return Container(
                    height: constraints.maxHeight,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: _glowColor.value,
                            blurRadius: constraints.maxHeight / 2,
                            spreadRadius: -constraints.maxHeight / 4 + _glowRadius.value
                        ),
                      ],
                    ),
                    child: child
                );
              }
          );
        }
    );
  }
   */
}

class Word extends StatelessWidget {
  final Stream foundWordsStream;
  final List<String> allWords;
  final int id;
  final double height;
  final double width;

  Word(this.foundWordsStream, this.allWords, this.id, this.height, this.width);

  List<Widget> _getLetters() {
    List<Widget> letters = new List<Widget>();
    var word = allWords[id];
    for (int i = 0; i < word.length; i++) {
      letters.add(Letter(foundWordsStream, allWords, word, i, height, width));
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
  final Stream foundWordsStream;
  final List<String> allWords;
  final String word;
  final int index;
  final double height;
  final double width;

  Letter(this.foundWordsStream, this.allWords, this.word, this.index, this.height, this.width);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(1),
      child: StreamBuilder<List<String>>(
        stream: foundWordsStream,
        builder: (context, snapshot) {
          var foundWords = !snapshot.hasData ? new List<String>() : snapshot.data;
          bool hidden = !foundWords.contains(word);
          double duration = 0.2;
          double i = index * (1 - duration) / word.length;
          return AnimatedSwitcher(
            switchInCurve: Interval(
                i,
                i + duration,
                curve: Curves.easeIn),
            switchOutCurve: Interval(
                1 - duration - i,
                1 - i,
                curve: Curves.easeOut),
            transitionBuilder: (child, animation) => ScaleTransition(child: child, scale: animation),
            duration: const Duration(milliseconds: 500),
            child: Container(
              key: ValueKey(hidden),
              height: height - 2,
              width: width - 2,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      width: 1
                  ),
                  color: Colors.white.withOpacity(0.3),
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(1, 1),
                        color: Colors.black54,
                        spreadRadius: 1,
                        blurRadius: 1
                    )
                  ]
              ),
              child: hidden ? Container()
                  : FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  child: BorderedLetter(
                      word[index].toUpperCase()
                  )
              )
            ),
          );
        }
      ),
    );
  }
}