import 'dart:io' show Platform;

class AdHelper {
  // 1. كود إعلان البانر (الشريط السفلي/العلوي)
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4450861580835519/7101990778';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4450861580835519/9834975642';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // 2. كود الإعلان البيني (الشاشة الكاملة)
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4450861580835519/4582648960';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4450861580835519/1670230921';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}