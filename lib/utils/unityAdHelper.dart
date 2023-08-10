// ignore_for_file: camel_case_types, file_names

import 'dart:io';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

late UnityBannerAd bannerAd;

class unityAdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "Banner_Android";
    } else if (Platform.isIOS) {
      return "Banner_iOS";
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get interstitialAdUnitId {
    if (Platform.isIOS) {
      return "Interstitial_iOS";
    } else if (Platform.isAndroid) {
      return "Interstitial_Android";
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get rewardAdUnitId {
    if (Platform.isIOS) {
      return "Rewarded_iOS";
    } else if (Platform.isAndroid) {
      return "Rewarded_Android";
    }
    throw UnsupportedError("Unsupported platform");
  }
}
