// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/commentNewsCubit.dart';
import 'package:news/cubits/relatedNewsCubit.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/ImageView.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/horizontalBtnList.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/relatedNewsList.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/setBannderAds.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/tagView.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/titleView.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/videoBtn.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/appSystemSettingCubit.dart';
import 'package:news/data/models/BreakingNewsModel.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/CommentView.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/ReplyCommentView.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/RerwardAds/fbRewardAds.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/backBtn.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/dateView.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/descView.dart';
import 'package:news/ui/screens/NewsDetail/Widgets/likeBtn.dart';

class NewsSubDetails extends StatefulWidget {
  final NewsModel? model;
  final BreakingNewsModel? breakModel;
  final bool fromShowMore;
  final bool isFromBreak;

  const NewsSubDetails({Key? key, this.model, this.breakModel, required this.fromShowMore, required this.isFromBreak}) : super(key: key);

  @override
  NewsSubDetailsState createState() => NewsSubDetailsState();
}

class NewsSubDetailsState extends State<NewsSubDetails> {
  bool comEnabled = false;
  bool isReply = false;
  int? replyComIndex;
  int fontValue = 15;
  FlutterTts? _flutterTts;
  bool isPlaying = false;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  BannerAd? _bannerAd;
  late final ScrollController controller = ScrollController()..addListener(hasMoreCommScrollListener);

  @override
  void initState() {
    super.initState();
    getComments();
    getRelatedNews();
    initializeTts();
  }

  getComments() {
    if (!widget.isFromBreak) {
      Future.delayed(Duration.zero, () {
        context.read<CommentNewsCubit>().getCommentNews(context: context, newsId: widget.model!.id!, userId: context.read<AuthCubit>().getUserId());
      });
    }
  }

  getRelatedNews() {
    if (!widget.isFromBreak) {
      Future.delayed(Duration.zero, () {
        context.read<RelatedNewsCubit>().getRelatedNews(
            userId: context.read<AuthCubit>().getUserId(),
            langId: context.read<AppLocalizationCubit>().state.id,
            catId: widget.model!.subCatId == "0" || widget.model!.subCatId == '' ? widget.model!.categoryId : null,
            subCatId: widget.model!.subCatId != "0" || widget.model!.subCatId != '' ? widget.model!.subCatId : null);
      });
    }
  }

  @override
  void dispose() {
    _flutterTts!.stop();
    controller.dispose();
    super.dispose();
  }

  updateFontVal(int fontVal) {
    setState(() {
      fontValue = fontVal;
    });
  }

  initializeTts() {
    _flutterTts = FlutterTts();

    _flutterTts!.setStartHandler(() async {
      if (mounted) {
        setState(() {
          isPlaying = true;
        });
      }
    });

    _flutterTts!.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    });

    _flutterTts!.setErrorHandler((err) {
      if (mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    });
  }

  bannerAdsInitialized() {
    if (context.read<AppConfigurationCubit>().checkAdsType() == "unity") {
      UnityAds.init(
          gameId: context.read<AppConfigurationCubit>().unityGameId()!,
          testMode: true,
          onComplete: () {
            debugPrint('Initialization Complete');
          },
          onFailed: (error, message) {
            debugPrint('Initialization Failed: $error $message');
          });
    }

    if (context.read<AppConfigurationCubit>().checkAdsType() == "fb") {
      fbInit();
    }
    if (context.read<AppConfigurationCubit>().checkAdsType() == "google") {
      _createBottomBannerAd();
    } //banner load
  }

  void _createBottomBannerAd() {
    if (context.read<AppConfigurationCubit>().bannerId() != "") {
      _bannerAd = BannerAd(
        adUnitId: context.read<AppConfigurationCubit>().bannerId()!,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (_) {},
          onAdFailedToLoad: (ad, err) {
            ad.dispose();
          },
        ),
      );

      _bannerAd!.load();
    }
  }

  speak(String description) async {
    if (description.isNotEmpty) {
      await _flutterTts!.setVolume(volume);
      await _flutterTts!.setSpeechRate(rate);
      await _flutterTts!.setPitch(pitch);
      await _flutterTts!.getLanguages;
      await _flutterTts!.setLanguage(() {
        return context.read<AppLocalizationCubit>().state.languageCode;
      }());
      int length = description.length;
      if (length < 4000) {
        setState(() {
          isPlaying = true;
        });
        await _flutterTts!.speak(description);
        _flutterTts!.setCompletionHandler(() {
          setState(() {
            _flutterTts!.stop();
            isPlaying = false;
          });
        });
      } else if (length < 8000) {
        String temp1 = description.substring(0, length ~/ 2);
        await _flutterTts!.speak(temp1);
        _flutterTts!.setCompletionHandler(() {
          setState(() {
            isPlaying = true;
          });
        });

        String temp2 = description.substring(temp1.length, description.length);
        await _flutterTts!.speak(temp2);
        _flutterTts!.setCompletionHandler(() {
          setState(() {
            isPlaying = false;
          });
        });
      } else if (length < 12000) {
        String temp1 = description.substring(0, 3999);
        await _flutterTts!.speak(temp1);
        _flutterTts!.setCompletionHandler(() {
          setState(() {
            isPlaying = true;
          });
        });
        String temp2 = description.substring(temp1.length, 7999);
        await _flutterTts!.speak(temp2);
        _flutterTts!.setCompletionHandler(() {
          setState(() {});
        });
        String temp3 = description.substring(temp2.length, description.length);
        await _flutterTts!.speak(temp3);
        _flutterTts!.setCompletionHandler(() {
          setState(() {
            isPlaying = false;
          });
        });
      }
    }
  }

  stop() async {
    var result = await _flutterTts!.stop();
    if (result == 1) {
      setState(() {
        isPlaying = false;
      });
    }
  }

  Future<bool> onBackPress() {
    if (widget.fromShowMore == true) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  otherMainDetails() {
    return Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.7),
        child: Container(
          padding: const EdgeInsetsDirectional.only(top: 20.0, start: 20.0, end: 20.0),
          width: double.maxFinite,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              color: UiUtils.getColorScheme(context).secondary),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            allRowBtn(
                isFromBreak: widget.isFromBreak,
                context: context,
                breakModel: widget.isFromBreak ? widget.breakModel : null,
                model: !widget.isFromBreak ? widget.model! : null,
                fontVal: fontValue,
                updateFont: updateFontVal,
                isPlaying: isPlaying,
                speak: speak,
                stop: stop,
                updateComEnabled: updateCommentshow),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.isFromBreak) tagView(model: widget.model!, context: context),
                if (!widget.isFromBreak && !isReply && !comEnabled) dateView(context, widget.model!.date!),
                if (!isReply && !comEnabled) titleView(title: widget.isFromBreak ? widget.breakModel!.title! : widget.model!.title!, context: context),
                if (!isReply && !comEnabled) descView(desc: widget.isFromBreak ? widget.breakModel!.desc! : widget.model!.desc!, context: context, fontValue: fontValue.toDouble()),
              ],
            ),
            if (!widget.isFromBreak && !isReply && comEnabled) CommentView(newsId: widget.model!.id!, updateComFun: updateCommentshow, updateIsReplyFun: updateComReply),
            if (!widget.isFromBreak && isReply && comEnabled) ReplyCommentView(replyComIndex: replyComIndex!, replyComFun: updateComReply, newsId: widget.model!.id!),
            if (!widget.isFromBreak && !isReply && !comEnabled) RelatedNewsList(model: widget.model!)
          ]),
        ));
  }

  updateCommentshow(bool comEnabledUpdate) {
    setState(() {
      comEnabled = comEnabledUpdate;
    });
  }

  updateComReply(bool comReplyUpdate, int comIndex) {
    setState(() {
      isReply = comReplyUpdate;
      replyComIndex = comIndex;
    });
  }

  void hasMoreCommScrollListener() {
    if (!widget.isFromBreak && comEnabled && !isReply) {
      if (controller.position.maxScrollExtent == controller.offset) {
        if (context.read<CommentNewsCubit>().hasMoreCommentNews()) {
          context.read<CommentNewsCubit>().getMoreCommentNews(context: context, newsId: widget.model!.id!, userId: context.read<AuthCubit>().getUserId());
        } else {
          debugPrint("No more notification");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SingleChildScrollView(
                controller: !widget.isFromBreak && comEnabled && !isReply ? controller : null,
                child: Stack(children: <Widget>[
                  ImageView(
                    isFromBreak: widget.isFromBreak,
                    model: widget.model,
                    breakModel: widget.breakModel,
                  ),
                  backBtn(context, widget.fromShowMore),
                  videoBtn(context: context, isFromBreak: widget.isFromBreak, model: !widget.isFromBreak ? widget.model! : null, breakModel: widget.isFromBreak ? widget.breakModel! : null),
                  otherMainDetails(),
                  if (!widget.isFromBreak) likeBtn(context, widget.model!),
                ])),
          ),
          //add banner ads here - outside scrollbar
          Padding(padding: const EdgeInsets.only(top: 10.0, bottom: 10.0), child: setBannerAd(context, _bannerAd))
        ],
      ),
    );
  }
}
