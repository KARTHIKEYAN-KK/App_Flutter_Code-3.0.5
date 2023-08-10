// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../utils/constant.dart';
import '../../utils/uiUtils.dart';

Future<void> createDynamicLink(
    {required BuildContext context, required String id, required String title, required bool isVideoId, required bool isBreakingNews, required String image, int? index}) async {
  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: deepLinkUrlPrefix,
    link: Uri.parse('https://$deepLinkName/?id=$id&index=$index&isVideoId=$isVideoId&isBreakingNews=$isBreakingNews'),
    androidParameters: const AndroidParameters(
      packageName: packageName,
      minimumVersion: 1,
    ),
    iosParameters: const IOSParameters(
      bundleId: iosPackage,
      minimumVersion: '1',
      appStoreId: appStoreId,
    ),
  );

  final ShortDynamicLink shortenedLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
  var str = "$title\n\n$appName\n\n${UiUtils.getTranslatedLabel(context, 'shareMsg')}\n\nAndroid:\n"
      "$androidLink$packageName\n\n iOS:\n$iosLink";

  String documentDirectory;

  if (Platform.isIOS) {
    documentDirectory = (await getApplicationDocumentsDirectory()).path;
  } else {
    documentDirectory = (await getExternalStorageDirectory())!.path;
  }
  final Dio dio = Dio();
  final response1 = await dio.get<List<int>>(
    image,
    options: Options(responseType: ResponseType.bytes), // Set the response type to `bytes`.
  );
  final bytes1 = response1.data;

  final File imageFile = File('$documentDirectory/temp.png');

  imageFile.writeAsBytesSync(bytes1!);
  Share.shareXFiles([XFile(imageFile.path)], text: "$title\n${shortenedLink.shortUrl.toString()}\n$str");
}
