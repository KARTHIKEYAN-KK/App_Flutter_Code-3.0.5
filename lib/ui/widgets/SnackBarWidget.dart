// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:news/utils/uiUtils.dart';

showSnackBar(String msg, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: UiUtils.getColorScheme(context).primaryContainer),
      ),
      duration: const Duration(milliseconds: 1000), //bydefault 4000 ms
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 1.0,
    ),
  );
}
