// ignore_for_file: file_names

import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/AppSystemSettingModel.dart';
import 'package:news/utils/unityAdHelper.dart';
import '../data/repositories/AppSystemSetting/systemRepository.dart';

abstract class AppConfigurationState extends Equatable {}

class AppConfigurationInitial extends AppConfigurationState {
  @override
  List<Object?> get props => [];
}

class AppConfigurationFetchInProgress extends AppConfigurationState {
  @override
  List<Object?> get props => [];
}

class AppConfigurationFetchSuccess extends AppConfigurationState {
  final AppSystemSettingModel appConfiguration;

  AppConfigurationFetchSuccess({required this.appConfiguration});

  @override
  List<Object?> get props => [appConfiguration];
}

class AppConfigurationFetchFailure extends AppConfigurationState {
  final String errorMessage;

  AppConfigurationFetchFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class AppConfigurationCubit extends Cubit<AppConfigurationState> {
  final SystemRepository _systemRepository;

  AppConfigurationCubit(this._systemRepository) : super(AppConfigurationInitial());

  fetchAppConfiguration() async {
    emit(AppConfigurationFetchInProgress());
    try {
      final appConfiguration = AppSystemSettingModel.fromJson(await _systemRepository.fetchSettings());
      emit(AppConfigurationFetchSuccess(appConfiguration: appConfiguration));
    } catch (e) {
      emit(AppConfigurationFetchFailure(e.toString()));
    }
  }

  AppSystemSettingModel getAppConfiguration() {
    if (state is AppConfigurationFetchSuccess) {
      return (state as AppConfigurationFetchSuccess).appConfiguration;
    }
    return AppSystemSettingModel.fromJson({});
  }

  String? getBreakingNewsMode() {
    if (state is AppConfigurationFetchSuccess) {
      return getAppConfiguration().breakNewsMode;
    }
    return "";
  }

  String? getLiveStreamMode() {
    if (state is AppConfigurationFetchSuccess) {
      return getAppConfiguration().liveStreamMode;
    }
    return "";
  }

  String? getCategoryMode() {
    if (state is AppConfigurationFetchSuccess) {
      return getAppConfiguration().catMode;
    }
    return "";
  }

  String? getSubCatMode() {
    if (state is AppConfigurationFetchSuccess) {
      return getAppConfiguration().subCatMode;
    }
    return "";
  }

  String? getCommentsMode() {
    if (state is AppConfigurationFetchSuccess) {
      return getAppConfiguration().commentMode;
    }
    return "";
  }

  String? getInAppAdsMode() {
    if (state is AppConfigurationFetchSuccess) {
      return getAppConfiguration().inAppAdsMode;
    }
    return "";
  }

  String? getIosInAppAdsMode() {
    if (state is AppConfigurationFetchSuccess) {
      return getAppConfiguration().iosInAppAdsMode;
    }
    return "";
  }

  String? checkAdsType() {
    if (Platform.isIOS) {
      if (getIosInAppAdsMode() == "1") {
        return getIOSAdsType();
      }
    } else {
      if (getInAppAdsMode() == "1") {
        return getAdsType();
      }
    }
    return null;
  }

  String? getAdsType() {
    if (state is AppConfigurationFetchSuccess) {
      if (getAppConfiguration().adsType == "1") {
        return "google";
      }
      if (getAppConfiguration().adsType == "2") {
        return "fb";
      }
      if (getAppConfiguration().adsType == "3") {
        return "unity";
      }
    }
    return "";
  }

  String? getIOSAdsType() {
    if (state is AppConfigurationFetchSuccess) {
      if (getAppConfiguration().iosAdsType == "1") {
        return "google";
      }
      if (getAppConfiguration().iosAdsType == "2") {
        return "fb";
      }
      if (getAppConfiguration().iosAdsType == "3") {
        return "unity";
      }
    }
    return "";
  }

  String? bannerId() {
    if (state is AppConfigurationFetchSuccess) {
      if (Platform.isAndroid) {
        if (getInAppAdsMode() != "0") {
          if (getAdsType() == "fb") {
            return getAppConfiguration().fbBannerId;
          } else if (getAdsType() == "google") {
            return getAppConfiguration().goBannerId;
          } else {
            return unityAdHelper.bannerAdUnitId;
          }
        }
      }
      if (Platform.isIOS) {
        if (getIosInAppAdsMode() != "0") {
          if (getIOSAdsType() == "fb") {
            return getAppConfiguration().fbIOSBannerId;
          } else if (getIOSAdsType() == "google") {
            return getAppConfiguration().goIOSBannerId;
          } else {
            return unityAdHelper.bannerAdUnitId;
          }
        }
      }
    }
    return "";
  }

  String? rewardId() {
    if (state is AppConfigurationFetchSuccess) {
      if (Platform.isAndroid) {
        if (getInAppAdsMode() != "0") {
          if (getAdsType() == "fb") {
            return getAppConfiguration().fbRewardedId;
          } else if (getAdsType() == "google") {
            return getAppConfiguration().goRewardedId;
          } else {
            return unityAdHelper.rewardAdUnitId;
          }
        }
      }
      if (Platform.isIOS) {
        if (getIosInAppAdsMode() != "0") {
          if (getIOSAdsType() == "fb") {
            return getAppConfiguration().fbIOSRewardedId;
          } else if (getIOSAdsType() == "google") {
            return getAppConfiguration().goIOSRewardedId;
          } else {
            return unityAdHelper.rewardAdUnitId;
          }
        }
      }
    }
    return "";
  }

  String? nativeId() {
    if (state is AppConfigurationFetchSuccess) {
      if (Platform.isAndroid) {
        if (getInAppAdsMode() != "0") {
          if (getAdsType() == "fb") {
            return getAppConfiguration().fbNativeId;
          } else if (getAdsType() == "google") {
            return getAppConfiguration().goNativeId;
          } else {
            return "";
          }
        }
      }
      if (Platform.isIOS) {
        if (getIosInAppAdsMode() != "0") {
          if (getIOSAdsType() == "fb") {
            return getAppConfiguration().fbIOSNativeId;
          } else if (getIOSAdsType() == "google") {
            return getAppConfiguration().goIOSNativeId;
          } else {
            return "";
          }
        }
      }
    }
    return "";
  }

  String? interstitialId() {
    if (state is AppConfigurationFetchSuccess) {
      if (Platform.isAndroid) {
        if (getInAppAdsMode() != "0") {
          if (getAdsType() == "fb") {
            return getAppConfiguration().fbInterId;
          } else if (getAdsType() == "google") {
            return getAppConfiguration().goInterId;
          } else {
            return unityAdHelper.interstitialAdUnitId;
          }
        }
      }
      if (Platform.isIOS) {
        if (getIosInAppAdsMode() != "0") {
          if (getIOSAdsType() == "fb") {
            return getAppConfiguration().fbIOSInterId;
          } else if (getIOSAdsType() == "google") {
            return getAppConfiguration().goIOSInterId;
          } else {
            return unityAdHelper.interstitialAdUnitId;
          }
        }
      }
    }
    return "";
  }

  String? unityGameId() {
    if (Platform.isAndroid) {
      return getAppConfiguration().gameId;
    } else {
      return getAppConfiguration().iosGameId;
    }
  }
}
