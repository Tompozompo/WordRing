import 'package:english_words/english_words.dart';

class WordManager {
  static int minSize = 3;

  static Set<String> findWords(List<String> words) {
    Set<String> result = new Set<String>();
    if (words.isEmpty) return result;
    int center = (words.first.length / 2).floor();
    for (int size = minSize; size <= words.first.length; size++) {
      int start = center >= size ? center - size + 1 : 0;
      int end = center >= size ? center : words.first.length - size;
      for (int i = 0; i < words.length; i++) {
        var word = words[i];
        for (int j = start; j <= end; j++) {
          var s = word.substring(j, j + size).toLowerCase();
          if (all.contains(s) && !result.contains(s)) {
            result.add(s);
          }
        }
      }
    }
    return result;
  }
}