// ignore_for_file: file_names

import 'package:news/utils/strings.dart';

class BreakingNewsModel {
  String? id, image, title, desc, contentType, contentValue, lanId;

  BreakingNewsModel({this.id, this.image, this.title, this.desc, this.contentValue, this.contentType, this.lanId});

  factory BreakingNewsModel.fromJson(Map<String, dynamic> json) {
    return BreakingNewsModel(
      id: json[ID],
      image: json[IMAGE],
      title: json[TITLE],
      desc: json[DESCRIPTION],
      contentValue: json[CONTENT_VALUE],
      contentType: json[CONTENT_TYPE],
      lanId: json[LANGUAGE_ID],
    );
  }
}
