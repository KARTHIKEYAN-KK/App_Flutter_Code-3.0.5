// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:news/cubits/languageJsonCubit.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/utils/labelKeys.dart';

import '../ui/styles/appTheme.dart';
import 'hiveBoxKeys.dart';

class UiUtils {
  static GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  static Future<void> setDynamicStringValue(String key, String value) async {
    Hive.box(settingsBoxKey).put(key, value);
  }

  static String getDynamicStringValue(String key) {
    return Hive.box(settingsBoxKey).get(key);
  }

  static Future<void> setDynamicListValue(String key, String value) async {
    List<String>? valueList = getDynamicListValue(key);
    if (!valueList.contains(value)) {
      if (valueList.length > 4) valueList.removeAt(0);
      valueList.add(value);

      Hive.box(settingsBoxKey).put(key, valueList);
    }
  }

  static List<String> getDynamicListValue(String key) {
    return Hive.box(settingsBoxKey).get(key);
  }

  static String getImagePath(String imageName) {
    return "assets/images/$imageName";
  }

  static String getFlagImagePath(String imageName) {
    return "assets/images/flag/$imageName";
  }

  static String getSvgImagePath(String imageName) {
    return "assets/images/svgImage/$imageName";
  }

  static ColorScheme getColorScheme(BuildContext context) {
    return Theme.of(context).colorScheme;
  }

// get app theme
  static String getThemeLabelFromAppTheme(AppTheme appTheme) {
    if (appTheme == AppTheme.Dark) {
      return darkThemeKey;
    }
    return lightThemeKey;
  }

  static AppTheme getAppThemeFromLabel(String label) {
    if (label == darkThemeKey) {
      return AppTheme.Dark;
    }
    return AppTheme.Light;
  }

  static String getTranslatedLabel(BuildContext context, String labelKey) {
    return context.read<LanguageJsonCubit>().getTranslatedLabels(labelKey);
  }

  static String? convertToAgo(BuildContext context, DateTime input, int from) {
    Duration diff = DateTime.now().difference(input);

    if (diff.inDays >= 1) {
      if (from == 0) {
        var newFormat = DateFormat("MMM dd, yyyy");
        final newsDate1 = newFormat.format(input);
        return newsDate1;
      } else if (from == 1) {
        return "${diff.inDays} ${getTranslatedLabel(context, 'days')} ${getTranslatedLabel(context, 'ago')}";
      } else if (from == 2) {
        var newFormat = DateFormat("dd MMMM yyyy HH:mm:ss");
        final newsDate1 = newFormat.format(input);
        return newsDate1;
      }
    } else if (diff.inHours >= 1) {
      if (input.minute == 00) {
        return "${diff.inHours} ${getTranslatedLabel(context, 'hours')} ${getTranslatedLabel(context, 'ago')}";
      } else {
        if (from == 2) {
          return "${getTranslatedLabel(context, 'about')} ${diff.inHours} ${getTranslatedLabel(context, 'hours')} ${input.minute} ${getTranslatedLabel(context, 'minutes')} ${getTranslatedLabel(context, 'ago')}";
        } else {
          return "${diff.inHours} ${getTranslatedLabel(context, 'hours')} ${input.minute} ${getTranslatedLabel(context, 'minutes')} ${getTranslatedLabel(context, 'ago')}";
        }
      }
    } else if (diff.inMinutes >= 1) {
      return "${diff.inMinutes} ${getTranslatedLabel(context, 'minutes')} ${getTranslatedLabel(context, 'ago')}";
    } else if (diff.inSeconds >= 1) {
      return "${diff.inSeconds} ${getTranslatedLabel(context, 'seconds')} ${getTranslatedLabel(context, 'ago')}";
    } else {
      return getTranslatedLabel(context, 'justNow');
    }
    return null;
  }

  static setUIOverlayStyle({required AppTheme appTheme}) {
    appTheme == AppTheme.Light
        ? SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: backgroundColor.withOpacity(0.8), statusBarBrightness: Brightness.light, statusBarIconBrightness: Brightness.dark))
        : SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(statusBarColor: darkSecondaryColor.withOpacity(0.8), statusBarBrightness: Brightness.dark, statusBarIconBrightness: Brightness.light));
  }
}
