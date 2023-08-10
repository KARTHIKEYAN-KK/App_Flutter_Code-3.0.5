// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/data/models/NotificationModel.dart';
import 'package:news/ui/screens/Notification/Widgets/shimmerNotification.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/app/routes.dart';
import 'package:news/cubits/NewsByIdCubit.dart';
import 'package:news/cubits/NotificationCubit.dart';
import 'package:news/ui/widgets/circularProgressIndicator.dart';
import 'package:news/ui/widgets/networkImage.dart';

class NotificationList extends StatefulWidget {
  const NotificationList({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NotificationState();
  }
}

class _NotificationState extends State<NotificationList> {
  List<String> selectedList = [];
  late final ScrollController controller = ScrollController()..addListener(hasMoreNotiScrollListener);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void hasMoreNotiScrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<NotificationCubit>().hasMoreNotification()) {
        context.read<NotificationCubit>().getMoreNotification(context: context, langId: context.read<AppLocalizationCubit>().state.id);
      } else {
        debugPrint("No more notifications");
      }
    }
  }

  _buildNotiContainer({
    required NotificationModel model,
    required int index,
    required int totalCurrentNoti,
    required bool hasMoreNotiFetchError,
    required bool hasMore,
  }) {
    if (index == totalCurrentNoti - 1) {
      //check if hasMore
      if (hasMore) {
        if (hasMoreNotiFetchError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
              child: IconButton(
                  onPressed: () {
                    context.read<NotificationCubit>().getMoreNotification(context: context, langId: context.read<AppLocalizationCubit>().state.id);
                  },
                  icon: Icon(
                    Icons.error,
                    color: Theme.of(context).primaryColor,
                  )),
            ),
          );
        } else {
          return Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0), child: showCircularProgress(true, Theme.of(context).primaryColor)));
        }
      }
    }

    return Hero(
        tag: model.id!,
        child: Padding(
            padding: const EdgeInsetsDirectional.only(
              top: 5.0,
              bottom: 10.0,
            ),
            child: InkWell(
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(color: UiUtils.getColorScheme(context).background, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: <Widget>[
                    ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: model.image! != ""
                            ? CustomNetworkImage(
                                networkImageUrl: model.image!,
                                fit: BoxFit.cover,
                                width: 80,
                                height: 80,
                                isVideo: false,
                              )
                            : Image.asset(
                                UiUtils.getImagePath(
                                  "Placeholder_video.jpg",
                                ),
                                height: 80.0,
                                width: 80,
                                fit: BoxFit.cover,
                              )),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 13.0, end: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(model.title!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold, color: UiUtils.getColorScheme(context).primaryContainer, fontSize: 15.0, letterSpacing: 0.1)),
                          Padding(
                              padding: const EdgeInsetsDirectional.only(top: 8.0),
                              child: Text(UiUtils.convertToAgo(context, DateTime.parse(model.dateSent!), 2)!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontWeight: FontWeight.normal, color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7), fontSize: 11)))
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              onTap: () {
                context
                    .read<NewsByIdCubit>()
                    .getNewsById(context: context, newsId: model.newsId!, langId: context.read<AppLocalizationCubit>().state.id, userId: context.read<AuthCubit>().getUserId())
                    .then((value) {
                  if (value.isNotEmpty) {
                    Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"model": value[0], "isFromBreak": false, "fromShowMore": false});
                  }
                });
              },
            )));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        if (state is NotificationFetchSuccess) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0, top: 10.0, bottom: 10.0),
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationCubit>().getNotification(context: context, langId: context.read<AppLocalizationCubit>().state.id);
              },
              child: ListView.builder(
                  controller: controller,
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: state.notification.length,
                  itemBuilder: (context, index) {
                    return _buildNotiContainer(
                      model: state.notification[index],
                      hasMore: state.hasMore,
                      hasMoreNotiFetchError: state.hasMoreFetchError,
                      index: index,
                      totalCurrentNoti: state.notification.length,
                    );
                  }),
            ),
          );
        }
        if (state is NotificationFetchFailure) {
          return Center(
              child: Text(
            UiUtils.getTranslatedLabel(context, 'notiNotAvail'),
            textAlign: TextAlign.center,
          ));
        }
        //state is NotificationFetchInProgress || state is NotificationInitial
        return Padding(padding: const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0), child: shimmerNotification(context));
      },
    );
  }
}
