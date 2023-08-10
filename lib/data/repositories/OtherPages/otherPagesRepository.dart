// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:news/data/models/OtherPageModel.dart';
import 'otherPageRemoteDataSorce.dart';

class OtherPageRepository {
  static final OtherPageRepository _otherPageRepository = OtherPageRepository._internal();

  late OtherPageRemoteDataSource _otherPageRemoteDataSource;

  factory OtherPageRepository() {
    _otherPageRepository._otherPageRemoteDataSource = OtherPageRemoteDataSource();
    return _otherPageRepository;
  }

  OtherPageRepository._internal();

  Future<Map<String, dynamic>> getOtherPage({required BuildContext context, required String langId}) async {
    final result = await _otherPageRemoteDataSource.getOtherPages(context: context, langId: langId);

    return {
      "OtherPage": (result['data'] as List).map((e) => OtherPageModel.fromJson(e)).toList(),
    };
  }
}
