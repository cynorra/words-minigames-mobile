class WordGuessDictionary {
  static const List<String> trWords = [
    'KALEM', 'KİTAP', 'GÜNEŞ', 'DENİZ', 'ORMAN', 'BULUT', 'KAHVE', 'ŞEHİR',
    'MÜZİK', 'FUTBO', 'GİTAR', 'ROBOT', 'ÇİÇEK', 'MASAL', 'RADYO', 'SEVGİ',
    'YILKI', 'BARIŞ', 'ZAMAN', 'GÖLGE', 'BAHAR', 'NEHİR', 'DOĞRU', 'CÜMLE'
  ];

  static const List<String> enWords = [
    'APPLE', 'BRAIN', 'CLOUD', 'DREAM', 'EARTH', 'FLAME', 'GHOST', 'HEART',
    'LIGHT', 'MUSIC', 'OCEAN', 'PLANT', 'RIVER', 'SPACE', 'TIGER', 'WATER',
    'YOUTH', 'STORM', 'TRAIN', 'SMILE', 'MAGIC', 'FOCUS', 'POWER', 'SMART'
  ];
}

enum LetterState { empty, initial, absent, present, correct }
