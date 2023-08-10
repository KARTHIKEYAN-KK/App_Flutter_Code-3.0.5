// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:news/ui/widgets/SnackBarWidget.dart';
import 'package:news/utils/uiUtils.dart';

import '../../app/routes.dart';

loginRequired(BuildContext context) {
  showSnackBar(UiUtils.getTranslatedLabel(context, 'loginReqMsg'), context);

  Future.delayed(const Duration(milliseconds: 1000), () {
    Navigator.of(context).pushNamed(Routes.login);
  });
}
