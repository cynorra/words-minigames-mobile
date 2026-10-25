import 'dart:math';
import '../constants/app_constants.dart';

class GameUtils {
  static final Random _random = Random();

  /// Rastgele bir sayı üretir (minNumber-maxNumber arası)
  static int generateRandomNumber() {
    return _random.nextInt(
          AppConstants.maxNumber - AppConstants.minNumber + 1,
        ) +
        AppConstants.minNumber;
  }

  /// Sayının belirtilen pozisyona yerleştirilip yerleştirilemeyeceğini kontrol eder
  static bool canPlaceNumber(List<int?> slots, int number, int position) {
    if (slots[position] != null) return false;

    // Sol tarafı kontrol et
    for (int i = position - 1; i >= 0; i--) {
      if (slots[i] != null) {
        if (slots[i]! >= number) return false;
        break;
      }
    }

    // Sağ tarafı kontrol et
    for (int i = position + 1; i < slots.length; i++) {
      if (slots[i] != null) {
        if (slots[i]! <= number) return false;
        break;
      }
    }

    return true;
  }

  /// Sayının herhangi bir yere yerleştirilip yerleştirilemeyeceğini kontrol eder
  static bool canPlaceNumberAnywhere(List<int?> slots, int number) {
    for (int i = 0; i < slots.length; i++) {
      if (canPlaceNumber(slots, number, i)) {
        return true;
      }
    }
    return false;
  }

  /// Geçerli pozisyonları döndürür
  static List<int> getValidPositions(List<int?> slots, int number) {
    List<int> validPositions = [];
    for (int i = 0; i < slots.length; i++) {
      if (canPlaceNumber(slots, number, i)) {
        validPositions.add(i);
      }
    }
    return validPositions;
  }

  /// Oyunun kazanılıp kazanılmadığını kontrol eder
  static bool isGameWon(List<int?> slots) {
    return slots.every((slot) => slot != null);
  }

  /// Puan hesaplar
  static int calculateScore(List<int?> slots) {
    return slots.where((slot) => slot != null).length;
  }

  /// Sıralamanın doğru olup olmadığını kontrol eder
  static bool isCorrectlySorted(List<int?> slots) {
    // Boş slotları filtrele
    final filledSlots =
        slots.where((slot) => slot != null).map((slot) => slot!).toList();

    // Eğer 1'den az sayı varsa sıralama doğru kabul et
    if (filledSlots.length <= 1) return true;

    // Sıralama kontrolü
    for (int i = 0; i < filledSlots.length - 1; i++) {
      if (filledSlots[i] >= filledSlots[i + 1]) {
        return false;
      }
    }

    return true;
  }

  /// Yerleştirilen sayının sıralamayı bozup bozmadığını kontrol eder
  static bool isSortingValidAfterPlacement(
    List<int?> slots,
    int placedNumber,
    int position,
  ) {
    // Yeni bir liste oluştur ve sayıyı yerleştir
    final newSlots = List<int?>.from(slots);
    newSlots[position] = placedNumber;

    // Sıralama kontrolü yap
    return isCorrectlySorted(newSlots);
  }

  /// Tüm dolu slotların sıralı olup olmadığını kontrol eder
  static bool areAllFilledSlotsSorted(List<int?> slots) {
    // Boş olmayan slotları al
    final filledSlots = <int>[];
    for (int i = 0; i < slots.length; i++) {
      if (slots[i] != null) {
        filledSlots.add(slots[i]!);
      }
    }

    // Sıralama kontrolü
    for (int i = 0; i < filledSlots.length - 1; i++) {
      if (filledSlots[i] >= filledSlots[i + 1]) {
        return false;
      }
    }

    return true;
  }
}
