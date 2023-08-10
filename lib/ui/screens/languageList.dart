// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/cubits/languageCubit.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/customBackBtn.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/networkImage.dart';
import 'package:news/utils/uiUtils.dart';
import '../../app/routes.dart';
import '../../cubits/Auth/authCubit.dart';
import '../../cubits/Bookmark/bookmarkCubit.dart';
import '../../cubits/LikeAndDislikeNews/LikeAndDislikeCubit.dart';
import '../../cubits/NotificationCubit.dart';
import '../../cubits/appLocalizationCubit.dart';
import '../../cubits/categoryCubit.dart';
import '../../cubits/featureSectionCubit.dart';
import '../../cubits/languageJsonCubit.dart';
import '../../cubits/liveStreamCubit.dart';
import '../../cubits/otherPagesCubit.dart';
import '../../cubits/UserNotification/userNotificationCubit.dart';
import '../../cubits/videosCubit.dart';

class LanguageList extends StatefulWidget {
  final int from;

  const LanguageList({super.key, required this.from});

  @override
  LanguageListState createState() => LanguageListState();

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
        builder: (_) => LanguageList(
              from: arguments['from'],
            ));
  }
}

class LanguageListState extends State<LanguageList> {
  String? selLanCode;
  String? selLanId;
  String? selLanRTL;

  @override
  void initState() {
    getLanguageData();
    super.initState();
  }

  Future getLanguageData() async {
    Future.delayed(Duration.zero, () {
      context.read<LanguageCubit>().getLanguage(context: context);
    });
  }

  Widget setTitle() {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: widget.from == 1 ? 55 : 20.0, start: 20.0),
      child: CustomTextLabel(
        text: 'chooseLanLbl',
        textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    );
  }

  Widget setBuilder() {
    return Container(margin: const EdgeInsetsDirectional.only(top: 40, bottom: 20), child: getLangList());
  }

  Widget getLangList() {
    return BlocBuilder<AppLocalizationCubit, AppLocalizationState>(builder: (context, stateLocale) {
      return BlocBuilder<LanguageCubit, LanguageState>(builder: (context, state) {
        if (state is LanguageFetchSuccess) {
          return ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 20),
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: ((context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                    leading: CustomNetworkImage(
                      networkImageUrl: state.language[index].image!,
                      isVideo: false,
                      height: 40,
                      fit: BoxFit.fill,
                      width: 40,
                    ),
                    title: Text(state.language[index].language!,
                        style: Theme.of(this.context).textTheme.titleLarge?.copyWith(
                              color: ((selLanCode ?? (stateLocale).languageCode) == state.language[index].code!)
                                  ? UiUtils.getColorScheme(context).secondary
                                  : UiUtils.getColorScheme(context).primaryContainer,
                            )),
                    tileColor: (selLanCode ?? stateLocale.languageCode) == state.language[index].code! ? UiUtils.getColorScheme(context).primaryContainer : null,
                    onTap: () {
                      setState(() {
                        selLanCode = state.language[index].code!;
                        selLanId = state.language[index].id!;
                        selLanRTL = state.language[index].isRtl!;
                      });
                    },
                  ),
                );
              }),
              separatorBuilder: (context, index) {
                return const SizedBox(height: 1.0);
              },
              itemCount: state.language.length);
        }
        if (state is LanguageFetchFailure) {
          return Center(
              child: Text(
            state.errorMessage.toString(),
            textAlign: TextAlign.center,
          ));
        }
        return Padding(padding: const EdgeInsets.only(bottom: 10.0, left: 30.0, right: 30.0), child: Container());
      });
    });
  }

  saveBtn() {
    return BlocConsumer<LanguageJsonCubit, LanguageJsonState>(
        bloc: context.read<LanguageJsonCubit>(),
        listener: (context, state) {
          if (state is LanguageJsonFetchSuccess) {
            UiUtils.setDynamicStringValue(context.read<AppLocalizationCubit>().state.languageCode, jsonEncode(state.languageJson));

            if (widget.from == 1) {
              Navigator.of(context).pushReplacementNamed(
                Routes.login,
              );
            } else {
              context.read<OtherPageCubit>().getOtherPage(context: context, langId: context.read<AppLocalizationCubit>().state.id);
              context.read<SectionCubit>().getSection(context: context, langId: context.read<AppLocalizationCubit>().state.id, userId: context.read<AuthCubit>().getUserId());
              context.read<LiveStreamCubit>().getLiveStream(context: context, langId: context.read<AppLocalizationCubit>().state.id);
              context.read<VideoCubit>().getVideo(context: context, langId: context.read<AppLocalizationCubit>().state.id);
              context.read<CategoryCubit>().getCategory(context: context, langId: context.read<AppLocalizationCubit>().state.id);
              if (context.read<AuthCubit>().getUserId() != "0") {
                context.read<LikeAndDisLikeCubit>().getLikeAndDisLike(context: context, langId: context.read<AppLocalizationCubit>().state.id, userId: context.read<AuthCubit>().getUserId());
                context.read<BookmarkCubit>().getBookmark(context: context, langId: context.read<AppLocalizationCubit>().state.id, userId: context.read<AuthCubit>().getUserId());
                context.read<UserNotificationCubit>().getUserNotification(context: context, userId: context.read<AuthCubit>().getUserId());
              }
              context.read<NotificationCubit>().getNotification(context: context, langId: context.read<AppLocalizationCubit>().state.id);
              Navigator.pop(context);
            }
          }
        },
        builder: (context, state) {
          return InkWell(
              child: Container(
                height: 55.0,
                margin: const EdgeInsetsDirectional.all(20),
                width: MediaQuery.of(context).size.width * 0.9,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(15.0)),
                child: CustomTextLabel(
                  text: 'saveLbl',
                  textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: backgroundColor, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                setState(() {
                  if (selLanCode != null && context.read<AppLocalizationCubit>().state.languageCode != selLanCode) {
                    context.read<AppLocalizationCubit>().changeLanguage(selLanCode!, selLanId!, selLanRTL!);

                    context.read<LanguageJsonCubit>().getLanguageJson(context: context, lanCode: selLanCode!);
                  } else {
                    if (widget.from == 1) {
                      Navigator.of(context).pushReplacementNamed(
                        Routes.login,
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  }
                });
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: saveBtn(),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          widget.from == 1
              ? const SizedBox.shrink()
              : const Padding(
                  padding: EdgeInsets.only(top: 35),
                  child: CustomBackButton(horizontalPadding: 20),
                ),
          setTitle(),
          setBuilder()
        ],
      ),
    );
  }
}
