// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/UserNotification/userNotificationCubit.dart';
import 'package:news/ui/screens/Notification/Widgets/userNotificationWidget.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/cubits/NotificationCubit.dart';
import 'Widgets/NotificationList.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  NotificationScreenState createState() => NotificationScreenState();

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => const NotificationScreen(),
    );
  }
}

class NotificationScreenState extends State<NotificationScreen> with TickerProviderStateMixin {
  ScrollController controller = ScrollController();
  TabController? _tc;

  @override
  void initState() {
    getNotification();
    _tc = TabController(length: 2, vsync: this, initialIndex: 0);

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    _tc!.dispose();
    super.dispose();
  }

  void getNotification() {
    Future.delayed(Duration.zero, () {
      context.read<UserNotificationCubit>().getUserNotification(context: context, userId: context.read<AuthCubit>().getUserId());
    });
    Future.delayed(Duration.zero, () {
      context.read<NotificationCubit>().getNotification(context: context, langId: context.read<AppLocalizationCubit>().state.id);
    });
  }

  setTabs() {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: DefaultTabController(
              length: 2,
              child: Row(children: [
                Expanded(
                  child: Container(
                      padding: const EdgeInsetsDirectional.only(start: 10.0, end: 25.0),
                      width: MediaQuery.of(context).size.width / 1.1,
                      height: 32.0,
                      child: TabBar(
                        controller: _tc,
                        labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
                        labelColor: UiUtils.getColorScheme(context).primaryContainer,
                        unselectedLabelColor: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7),
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                        indicatorColor: Theme.of(context).colorScheme.background,
                        indicator: UnderlineTabIndicator(
                            borderSide: BorderSide(width: 3.0, color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.8)), insets: const EdgeInsets.symmetric(horizontal: 30.0)),
                        tabs: const [
                          CustomTextLabel(text: 'personalLbl'),
                          CustomTextLabel(text: 'newsLbl'),
                        ],
                      )),
                ),
              ])),
        ),
        Padding(
            padding: const EdgeInsetsDirectional.only(end: 15.0),
            child: Divider(
              thickness: 1.5,
              height: 1.0,
              color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.3),
            ))
      ],
    );
  }

  setAppBar() {
    return PreferredSize(
        preferredSize: const Size(double.infinity, 92),
        child: Container(
          padding: EdgeInsetsDirectional.only(top: MediaQuery.of(context).padding.top + 10.0, start: 25),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CustomTextLabel(
              text: 'notificationLbl',
              textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.w600, letterSpacing: 0.5),
            ),
            const Spacer(),
            setTabs(),
          ]),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: setAppBar(), body: TabBarView(controller: _tc, children: const [UserNotificationWidget(), NotificationList()]));
  }
}
