// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:news/utils/api.dart';
import 'package:news/utils/hiveBoxKeys.dart';
import 'languageJsonRemoteDataRepo.dart';

class LanguageJsonRepository {
  static final LanguageJsonRepository _languageRepository = LanguageJsonRepository._internal();

  late LanguageJsonRemoteDataSource _languageRemoteDataSource;

  factory LanguageJsonRepository() {
    _languageRepository._languageRemoteDataSource = LanguageJsonRemoteDataSource();
    return _languageRepository;
  }

  LanguageJsonRepository._internal();

  Future<dynamic> getLanguageJson({required String lanCode}) async {
    final result = await _languageRemoteDataSource.getLanguageJson(lanCode: lanCode);
    return result['data'];
  }

  Future<Map<dynamic, dynamic>> fetchLanguageLabels(String langCode) async {
    try {
      final languageLabels = Hive.box(settingsBoxKey).get(langCode);
      debugPrint("languagelabels***$languageLabels");
      if (languageLabels != null) {
        final result = await getLanguageJson(lanCode: langCode);
        Map<dynamic, dynamic> languageLabelsJson = result;
        await Hive.box(settingsBoxKey).put(langCode, languageLabelsJson);
        return languageLabelsJson;
      } else {
        return languageLabels;
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
