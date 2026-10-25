class WordItem {
  final String word;
  final String clue;
  final String category;

  const WordItem({
    required this.word,
    required this.clue,
    required this.category,
  });
}

class WordScrambleModel {
  static const List<WordItem> wordsTr = [
    WordItem(word: 'KEDİ', clue: 'Mırıldayan sevimli evcil dost', category: 'Hayvanlar'),
    WordItem(word: 'KÖPEK', clue: 'Sadık dört ayaklı dost', category: 'Hayvanlar'),
    WordItem(word: 'KİTAP', clue: 'Sayfalarında bilgi ve hayal taşır', category: 'Eğitim'),
    WordItem(word: 'ELMA', clue: 'Kırmızı veya yeşil vitamin deposu meyve', category: 'Yiyecek'),
    WordItem(word: 'GÜNEŞ', clue: 'Dünyamızı ısıtan ve aydınlatan yıldız', category: 'Doğa'),
    WordItem(word: 'YILDIZ', clue: 'Gece gökyüzünde parıldayan gökcismi', category: 'Uzay'),
    WordItem(word: 'DENİZ', clue: 'Tuzlu mavi sular', category: 'Doğa'),
    WordItem(word: 'ORMAN', clue: 'Ağaçların bir arada olduğu yeşil alan', category: 'Doğa'),
    WordItem(word: 'BULUT', clue: 'Gökyüzündeki beyaz su buharı kümesi', category: 'Hava Durumu'),
    WordItem(word: 'KALEM', clue: 'Yazı yazmaya ve çizmeye yarar', category: 'Eğitim'),
    WordItem(word: 'KAHVE', clue: 'Sabahları uyanmak için içilen sıcak içecek', category: 'İçecek'),
    WordItem(word: 'ŞEHİR', clue: 'Kalabalık binalar ve yollar bütünü', category: 'Genel'),
    WordItem(word: 'MÜZİK', clue: 'Ruhun gıdası kabul edilen sesler sanatı', category: 'Sanat'),
    WordItem(word: 'FUTBOL', clue: '11 kişiyle oynanan meşin yuvarlak oyunu', category: 'Spor'),
    WordItem(word: 'GİTAR', clue: 'Tellerine dokunularak çalınan çalgı', category: 'Müzik'),
    WordItem(word: 'ROBOT', clue: 'Programlanabilir mekanik sistem', category: 'Teknoloji'),
    WordItem(word: 'YAZILIM', clue: 'Bilgisayarların çalışmasını sağlayan kodlar', category: 'Teknoloji'),
    WordItem(word: 'GEZEGEN', clue: 'Güneş çevresinde dolanan gökcismi', category: 'Uzay'),
    WordItem(word: 'TELEFON', clue: 'İletişim kurmaya yarayan akıllı cihaz', category: 'Teknoloji'),
    WordItem(word: 'PİYANO', clue: 'Siyah ve beyaz tuşları olan büyük çalgı', category: 'Müzik'),
  ];

  static const List<WordItem> wordsEn = [
    WordItem(word: 'CAT', clue: 'A furry purring pet', category: 'Animals'),
    WordItem(word: 'DOG', clue: 'Man\'s best loyal friend', category: 'Animals'),
    WordItem(word: 'BOOK', clue: 'Filled with pages, knowledge and stories', category: 'Education'),
    WordItem(word: 'APPLE', clue: 'Crisp red or green sweet fruit', category: 'Food'),
    WordItem(word: 'SUN', clue: 'The star giving warmth and light to Earth', category: 'Nature'),
    WordItem(word: 'STAR', clue: 'Luminous celestial body twinkling at night', category: 'Space'),
    WordItem(word: 'OCEAN', clue: 'Vast body of salt water', category: 'Nature'),
    WordItem(word: 'FOREST', clue: 'Large area covered chiefly with trees', category: 'Nature'),
    WordItem(word: 'CLOUD', clue: 'White visible mass of condensed water vapor', category: 'Weather'),
    WordItem(word: 'PENCIL', clue: 'Instrument used for writing or drawing', category: 'Education'),
    WordItem(word: 'COFFEE', clue: 'Popular brewed warm morning drink', category: 'Drinks'),
    WordItem(word: 'MUSIC', clue: 'Art form of organized sound and harmony', category: 'Art'),
    WordItem(word: 'SOCCER', clue: 'World\'s most popular sport played with a ball', category: 'Sports'),
    WordItem(word: 'GUITAR', clue: 'Stringed musical instrument', category: 'Music'),
    WordItem(word: 'ROBOT', clue: 'Automated programmable mechanical machine', category: 'Technology'),
    WordItem(word: 'PLANET', clue: 'Celestial body orbiting a star', category: 'Space'),
    WordItem(word: 'SUMMER', clue: 'Warmest season of the year', category: 'Seasons'),
    WordItem(word: 'WINTER', clue: 'Cold season often with snow', category: 'Seasons'),
    WordItem(word: 'PHONE', clue: 'Handheld electronic communication device', category: 'Technology'),
    WordItem(word: 'CASTLE', clue: 'Large fortified building from medieval times', category: 'History'),
  ];
}
