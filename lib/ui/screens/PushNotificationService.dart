// ignore_for_file: file_names

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:news/cubits/NewsByIdCubit.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/settingCubit.dart';
import 'package:path_provider/path_provider.dart';

import '../../app/app.dart';
import '../../app/routes.dart';
import '../../cubits/Auth/authCubit.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
FirebaseMessaging messaging = FirebaseMessaging.instance;

backgroundMessage(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: ${notificationResponse.actionId} with payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print('notification action tapped with input: ${notificationResponse.input}');
  }
}

class PushNotificationService {
  late BuildContext context;

  PushNotificationService({required this.context});

  Future initialise() async {
    iOSPermission();
    messaging.getToken().then((value) {});
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {},
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationPayload(notificationResponse.payload!);

            break;
          case NotificationResponseType.selectedNotificationAction:
            debugPrint("notification-action-id--->${notificationResponse.actionId}==${notificationResponse.payload}");

            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: backgroundMessage,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      var data = message.data;
      var notif = message.notification;
      if (data['type'] == "default" || data['type'] == "category") {
        var title = data['title'].toString();
        var body = data['message'].toString();
        var image = data['image'];
        var payload = data["news_id"];
        var lanId = data["language_id"];

        if (payload == null) {
          payload = "";
        } else {
          payload = payload;
        }
        if (lanId == context.read<AppLocalizationCubit>().state.id) {
          if (image != null && image != "") {
            if (context.read<SettingsCubit>().state.settingsModel!.notification) {
              generateImageNotication(title, body, image, payload);
            }
          } else {
            if (context.read<SettingsCubit>().state.settingsModel!.notification) {
              generateSimpleNotication(title, body, payload);
            }
          }
        }
      } else {
        //Direct Firebase Notification
        var title = notif?.title.toString();
        var msg = notif?.body.toString();
        var img = notif?.android?.imageUrl.toString();
        if (context.read<SettingsCubit>().state.settingsModel!.notification) {
          (img != null) ? generateImageNotication(title!, msg!, img, '') : generateSimpleNotication(title!, msg!, '');
        }
      }
    });

    messaging.getInitialMessage().then((RemoteMessage? message) async {
      if (message != null) {
        var data = message.data;
        var notif = message.notification;
        if (data['type'] == "default" || data['type'] == "category") {
          var title = data['title'].toString();
          var body = data['message'].toString();
          var image = data['image'];
          var payload = data["news_id"];
          var lanId = data["language_id"];

          if (payload == null) {
            payload = "";
          } else {
            payload = payload;
          }
          if (lanId == context.read<AppLocalizationCubit>().state.id) {
            if (image != null && image != "") {
              if (context.read<SettingsCubit>().state.settingsModel!.notification) {
                generateImageNotication(title, body, image, payload);
              }
            } else {
              if (context.read<SettingsCubit>().state.settingsModel!.notification) {
                generateSimpleNotication(title, body, payload);
              }
            }
          }
        } else {
          //Direct Firebase Notification
          var title = notif?.title.toString();
          var msg = notif?.body.toString();
          var img = notif?.android?.imageUrl.toString();
          if (context.read<SettingsCubit>().state.settingsModel!.notification) {
            (img != null) ? generateImageNotication(title!, msg!, img, '') : generateSimpleNotication(title!, msg!, '');
          }
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      var data = message.data;
      if (data['type'] == "default" || data['type'] == "category") {
        var payload = data["news_id"];

        if (payload == null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyApp()),
          );
        } else {
          context
              .read<NewsByIdCubit>()
              .getNewsById(context: context, newsId: payload, langId: context.read<AppLocalizationCubit>().state.id, userId: context.read<AuthCubit>().getUserId())
              .then((value) {
            Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"model": value[0], "isFromBreak": false, "fromShowMore": false});
          });
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
        );
      }
    });
  }

  void iOSPermission() async {
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  selectNotificationPayload(String? payload) async {
    if (payload != null && payload != "") {
      debugPrint('notification payload: $payload');
      context.read<NewsByIdCubit>().getNewsById(context: context, newsId: payload, langId: context.read<AppLocalizationCubit>().state.id, userId: context.read<AuthCubit>().getUserId()).then((value) {
        Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"model": value[0], "isFromBreak": false, "fromShowMore": false});
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
      );
    }
  }
}

Future<dynamic> myForgroundMessageHandler(RemoteMessage message) async {
  return Future<void>.value();
}

Future<String> _downloadAndSaveImage(String url, String fileName) async {
  var directory = await getApplicationDocumentsDirectory();
  var filePath = '${directory.path}/$fileName';
  Dio dio = Dio();
  var response = await dio.getUri(Uri.parse(url));

  var file = File(filePath);
  await file.writeAsBytes(response.data);
  return filePath;
}

Future<void> generateImageNotication(String title, String msg, String image, String type) async {
  var largeIconPath = await _downloadAndSaveImage(image, 'largeIcon');
  var bigPicturePath = await _downloadAndSaveImage(image, 'bigPicture');
  var bigPictureStyleInformation =
      BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath), hideExpandedLargeIcon: true, contentTitle: title, htmlFormatContentTitle: true, summaryText: msg, htmlFormatSummaryText: true);
  var androidPlatformChannelSpecifics = AndroidNotificationDetails('big text channel id', 'big text channel name',
      channelDescription: 'big text channel description', largeIcon: FilePathAndroidBitmap(largeIconPath), styleInformation: bigPictureStyleInformation);
  var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(0, title, msg, platformChannelSpecifics, payload: type);
}

const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
  categoryIdentifier: "",
);

Future<void> generateSimpleNotication(String title, String msg, String type) async {
  var androidPlatformChannelSpecifics =
      const AndroidNotificationDetails('your channel id', 'your channel name', channelDescription: 'your channel description', importance: Importance.max, priority: Priority.high, ticker: 'ticker');

  var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: darwinNotificationDetails);
  await flutterLocalNotificationsPlugin.show(0, title, msg, platformChannelSpecifics, payload: type);
}
