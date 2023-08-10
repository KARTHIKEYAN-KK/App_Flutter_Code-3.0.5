// ignore_for_file: file_names

import 'package:news/utils/strings.dart';

class LanguageModel {
  String? id, language, image, code, isRtl;

  LanguageModel({this.id, this.image, this.language, this.code, this.isRtl});

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json[ID],
      image: json[IMAGE],
      language: json[LANGUAGE],
      code: json[CODE],
      isRtl: json[ISRTL],
    );
  }
}
