// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:io';
import 'package:facebook_audience_network/ad/ad_native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:news/cubits/LikeAndDislikeNews/updateLikeAndDislikeCubit.dart';
import 'package:news/data/repositories/LikeAndDisLikeNews/LikeAndDisLikeNewsRepository.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/networkImage.dart';
import 'package:news/utils/constant.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/app/routes.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/Bookmark/UpdateBookmarkCubit.dart';
import 'package:news/cubits/Bookmark/bookmarkCubit.dart';
import 'package:news/cubits/LikeAndDislikeNews/LikeAndDislikeCubit.dart';
import 'package:news/cubits/appSystemSettingCubit.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/Bookmark/bookmarkRepository.dart';
import 'package:news/utils/internetConnectivity.dart';
import 'package:news/ui/widgets/SnackBarWidget.dart';
import 'package:news/ui/widgets/circularProgressIndicator.dart';
import 'package:news/ui/widgets/createDynamicLink.dart';
import 'package:news/ui/widgets/loginRequired.dart';

class NewsItem extends StatefulWidget {
  final NewsModel model;
  final int index;
  final List<NewsModel> newslist;
  final bool fromShowMore;

  const NewsItem({
    super.key,
    required this.model,
    required this.index,
    required this.newslist,
    required this.fromShowMore,
  });

  @override
  NewsItemState createState() => NewsItemState();
}

class NewsItemState extends State<NewsItem> {
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  Widget newsData() {
    List<String> tagList = [];
    if (widget.model.tagName! != "") {
      final tagName = widget.model.tagName!;
      tagList = tagName.split(',');
    }

    List<String> tagId = [];

    if (widget.model.tagId! != "") {
      tagId = widget.model.tagId!.split(",");
    }
    return Builder(builder: (context) {
      return Padding(
          padding: EdgeInsetsDirectional.only(top: widget.index == 0 ? 0 : 15.0, start: 10, end: 10),
          child: Column(children: [
            nativeAdsShow(),
            InkWell(
              child: Column(
                children: <Widget>[
                  Stack(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: CustomNetworkImage(
                            networkImageUrl: widget.model.image!,
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height / 4.2,
                            fit: BoxFit.cover,
                            isVideo: false,
                          )),
                      Positioned.directional(
                          textDirection: Directionality.of(context),
                          bottom: 7.0,
                          start: 7.0,
                          child: widget.model.tagName! != ""
                              ? SizedBox(
                                  height: 16.0,
                                  child: ListView.builder(
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: tagList.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: EdgeInsetsDirectional.only(start: index == 0 ? 0 : 5.5),
                                          child: InkWell(
                                            child: Container(
                                                height: 20.0,
                                                width: 65,
                                                alignment: Alignment.center,
                                                padding: const EdgeInsetsDirectional.only(start: 3.0, end: 3.0, top: 1.0, bottom: 1.0),
                                                decoration: BoxDecoration(
                                                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
                                                  color: secondaryColor.withOpacity(0.85),
                                                ),
                                                child: Text(
                                                  tagList[index],
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                        color: darkSecondaryColor,
                                                        fontSize: 8.5,
                                                      ),
                                                  overflow: TextOverflow.ellipsis,
                                                  softWrap: true,
                                                )),
                                            onTap: () async {
                                              Navigator.of(context).pushNamed(Routes.tagScreen, arguments: {"tagId": tagId[index], "tagName": tagList[index]});
                                            },
                                          ),
                                        );
                                      }))
                              : const SizedBox.shrink()),
                    ],
                  ),
                  Container(
                      alignment: Alignment.bottomLeft,
                      padding: const EdgeInsetsDirectional.only(top: 4.0, start: 5.0, end: 5.0),
                      child: Text(
                        widget.model.title!,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.9)),
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      )),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(top: 4.0, start: 5.0, end: 5.0),
                          child: Text(UiUtils.convertToAgo(context, DateTime.parse(widget.model.date!), 0)!,
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.5))),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 13.0),
                        child: InkWell(
                          child: const Icon(Icons.share_rounded),
                          onTap: () async {
                            if (await InternetConnectivity.isNetworkAvailable()) {
                              createDynamicLink(context: context, id: widget.model.id!, title: widget.model.title!, isVideoId: false, isBreakingNews: false, image: widget.model.image!);
                            } else {
                              showSnackBar(UiUtils.getTranslatedLabel(context, 'internetmsg'), context);
                            }
                          },
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width / 99.0),
                      BlocProvider(
                        create: (context) => UpdateBookmarkStatusCubit(BookmarkRepository()),
                        child: BlocBuilder<BookmarkCubit, BookmarkState>(
                            bloc: context.read<BookmarkCubit>(),
                            builder: (context, bookmarkState) {
                              bool isBookmark = context.read<BookmarkCubit>().isNewsBookmark(widget.model.id!);
                              return BlocConsumer<UpdateBookmarkStatusCubit, UpdateBookmarkStatusState>(
                                  bloc: context.read<UpdateBookmarkStatusCubit>(),
                                  listener: ((context, state) {
                                    if (state is UpdateBookmarkStatusSuccess) {
                                      if (state.wasBookmarkNewsProcess) {
                                        context.read<BookmarkCubit>().addBookmarkNews(state.news);
                                      } else {
                                        context.read<BookmarkCubit>().removeBookmarkNews(state.news);
                                      }
                                    }
                                  }),
                                  builder: (context, state) {
                                    return InkWell(
                                        onTap: () {
                                          if (context.read<AuthCubit>().getUserId() != "0") {
                                            if (state is UpdateBookmarkStatusInProgress) {
                                              return;
                                            }
                                            context.read<UpdateBookmarkStatusCubit>().setBookmarkNews(
                                                  context: context,
                                                  userId: context.read<AuthCubit>().getUserId(),
                                                  news: widget.model,
                                                  status: (isBookmark) ? "0" : "1",
                                                );
                                          } else {
                                            loginRequired(context);
                                          }
                                        },
                                        child: InkWell(
                                            child: state is UpdateBookmarkStatusInProgress
                                                ? SizedBox(
                                                    height: 15,
                                                    width: 15,
                                                    child: showCircularProgress(true, Theme.of(context).primaryColor),
                                                  )
                                                : Icon(
                                                    isBookmark ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                                                  )));
                                  });
                            }),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width / 99.0),
                      BlocProvider(
                          create: (context) => UpdateLikeAndDisLikeStatusCubit(LikeAndDisLikeRepository()),
                          child: BlocBuilder<LikeAndDisLikeCubit, LikeAndDisLikeState>(
                              bloc: context.read<LikeAndDisLikeCubit>(),
                              builder: (context, likeAndDislikeState) {
                                bool isLike = context.read<LikeAndDisLikeCubit>().isNewsLikeAndDisLike(widget.model.id!);
                                return BlocConsumer<UpdateLikeAndDisLikeStatusCubit, UpdateLikeAndDisLikeStatusState>(
                                    bloc: context.read<UpdateLikeAndDisLikeStatusCubit>(),
                                    listener: ((context, state) {
                                      if (state is UpdateLikeAndDisLikeStatusSuccess) {
                                        if (state.wasLikeAndDisLikeNewsProcess) {
                                          context.read<LikeAndDisLikeCubit>().addLikeAndDisLikeNews(state.news);
                                        } else {
                                          context.read<LikeAndDisLikeCubit>().removeLikeAndDisLikeNews(state.news);
                                        }
                                      }
                                    }),
                                    builder: (context, state) {
                                      return InkWell(
                                          splashColor: Colors.transparent,
                                          onTap: () {
                                            if (context.read<AuthCubit>().getUserId() != "0") {
                                              if (state is UpdateLikeAndDisLikeStatusInProgress) {
                                                return;
                                              }
                                              context.read<UpdateLikeAndDisLikeStatusCubit>().setLikeAndDisLikeNews(
                                                    context: context,
                                                    userId: context.read<AuthCubit>().getUserId(),
                                                    news: widget.model,
                                                    status: (isLike) ? "0" : "1",
                                                  );
                                            } else {
                                              loginRequired(context);
                                            }
                                          },
                                          child: (state is UpdateLikeAndDisLikeStatusInProgress)
                                              ? SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: showCircularProgress(true, Theme.of(context).primaryColor),
                                                )
                                              : isLike
                                                  ? const Icon(Icons.thumb_up_alt)
                                                  : const Icon(Icons.thumb_up_off_alt));
                                    });
                              })),
                    ],
                  ),
                ],
              ),
              onTap: () {
                List<NewsModel> newsList = [];
                newsList.addAll(widget.newslist);
                newsList.removeAt(widget.index);
                Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"model": widget.model, "newsList": newsList, "isFromBreak": false, "fromShowMore": false});
              },
            ),
          ]));
    });
  }

  BannerAd createBannerAd() {
    if (context.read<AppConfigurationCubit>().bannerId() != "") {
      _bannerAd = BannerAd(
        adUnitId: context.read<AppConfigurationCubit>().bannerId()!,
        request: const AdRequest(),
        size: AdSize.mediumRectangle,
        listener: BannerAdListener(
          onAdLoaded: (_) {
            setState(() {
              _isBannerAdReady = true;
              debugPrint("native ad is Loaded !!!");
            });
          },
          onAdFailedToLoad: (ad, err) {
            setState(() {
              _isBannerAdReady = false;
            });
            debugPrint("error in loading Native ad $err");
            ad.dispose();
          },
          onAdOpened: (Ad ad) => debugPrint('Native ad opened.'),
          // Called when an ad opens an overlay that covers the screen.
          onAdClosed: (Ad ad) => debugPrint('Native ad closed.'),
          // Called when an ad removes an overlay that covers the screen.
          onAdImpression: (Ad ad) => debugPrint('Native ad impression.'),
        ),
      );
    }
    debugPrint("banner ad ready bool - $_isBannerAdReady");
    return _bannerAd;
  }

  Widget bannerAdsShow() {
    return (_isBannerAdReady) ? AdWidget(key: UniqueKey(), ad: createBannerAd()..load()) : const SizedBox.shrink();
  }

  Widget fbNativeAdsShow() {
    return (context.read<AppConfigurationCubit>().nativeId() != "")
        ? FacebookNativeAd(
            placementId: context.read<AppConfigurationCubit>().nativeId()!,
            adType: Platform.isAndroid ? NativeAdType.NATIVE_AD : NativeAdType.NATIVE_AD_VERTICAL,
            width: double.infinity,
            height: 320,
            keepAlive: true,
            keepExpandedWhileLoading: false,
            expandAnimationDuraion: 300,
            listener: (result, value) {
              debugPrint("Native Ad: $result --> $value");
            },
          )
        : const SizedBox.shrink();
  }

  Widget nativeAdsShow() {
    if (context.read<AppConfigurationCubit>().checkAdsType() != null && context.read<AppConfigurationCubit>().checkAdsType() != "unity" && widget.index != 0 && widget.index % nativeAdsIndex == 0) {
      return Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Container(
              padding: const EdgeInsets.all(7.0),
              height: 320,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: context.read<AppConfigurationCubit>().checkAdsType() == "google" //google ads
                  ? bannerAdsShow()
                  : fbNativeAdsShow()));
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return newsData();
  }
}
