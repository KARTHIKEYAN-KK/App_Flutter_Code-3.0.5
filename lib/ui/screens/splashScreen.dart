// ignore_for_file: file_names

import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:news/cubits/Auth/registerTokenCubit.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/languageJsonCubit.dart';
import 'package:news/cubits/settingCubit.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/app/routes.dart';
import 'package:news/cubits/appSystemSettingCubit.dart';
import 'package:news/utils/hiveBoxKeys.dart';
import 'package:news/ui/widgets/Slideanimation.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<Splash> with TickerProviderStateMixin {
  AnimationController? _splashIconController;
  AnimationController? _newsImgController;
  AnimationController? _slideControllerBottom;
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<AppConfigurationCubit>().fetchAppConfiguration();
    });

    FirebaseMessaging.instance.getToken().then((token) async {
      if (token != context.read<SettingsCubit>().getSettings().token && token != null) {
        context.read<RegisterTokenCubit>().registerToken(fcmId: token, context: context);
      }
    });

    _slideControllerBottom = AnimationController(vsync: this, duration: const Duration(seconds: 3)); //4
    _splashIconController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _newsImgController = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    changeOpacity();
  }

  changeOpacity() {
    Future.delayed(const Duration(milliseconds: 2000), () {
      setState(() {
        opacity = opacity == 0.0 ? 1.0 : 0.0;
      });
    });
  }

  @override
  void dispose() {
    _splashIconController!.dispose();
    _newsImgController!.dispose();
    _slideControllerBottom!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(backgroundColor: backgroundColor, body: buildScale());
  }

  Future<void> navigationPage() async {
    Future.delayed(const Duration(seconds: 1), () async {
      final currentSettings = context.read<SettingsCubit>().state.settingsModel;

      if (currentSettings!.showIntroSlider) {
        Navigator.of(context).pushReplacementNamed(Routes.introSlider);
      } else {
        Navigator.of(context).pushReplacementNamed(Routes.home, arguments: false);
      }
    });
  }

  Widget buildScale() {
    return BlocConsumer<AppConfigurationCubit, AppConfigurationState>(
        bloc: context.read<AppConfigurationCubit>(),
        listener: (context, state) {
          if (state is AppConfigurationFetchSuccess) {
            String? currentLanguage = Hive.box(settingsBoxKey).get(currentLanguageCodeKey);
            if (currentLanguage == null) {
              context
                  .read<AppLocalizationCubit>()
                  .changeLanguage(state.appConfiguration.defaultLanDataModel![0].code!, state.appConfiguration.defaultLanDataModel![0].id!, state.appConfiguration.defaultLanDataModel![0].isRTL!);
              context.read<LanguageJsonCubit>().fetchCurrentLanguageAndLabels(state.appConfiguration.defaultLanDataModel![0].code!);
            } else {
              context.read<LanguageJsonCubit>().fetchCurrentLanguageAndLabels(currentLanguage);
            }
          }
        },
        builder: (context, state) {
          return BlocConsumer<LanguageJsonCubit, LanguageJsonState>(
              bloc: context.read<LanguageJsonCubit>(),
              listener: (context, state) {
                if (state is LanguageJsonFetchSuccess) {
                  navigationPage();
                }
              },
              builder: (context, state) {
                return Container(
                  width: double.maxFinite,
                  margin: const EdgeInsets.only(top: 2 * kToolbarHeight),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(200)),
                    color: darkSecondaryColor,
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const SizedBox(height: 100),
                    splashLogoIcon(),
                    newsTextIcon(),
                    subTitle(),
                    const Spacer(),
                    bottomText(),
                  ]),
                );
              });
        });
  }

  Widget splashLogoIcon() {
    return Center(
        child: SlideAnimation(
      position: 2,
      itemCount: 3,
      slideDirection: SlideDirection.fromRight,
      animationController: _splashIconController!,
      child: Image.asset(
        UiUtils.getImagePath("splash_Icon.png"),
        height: 60.0,
        fit: BoxFit.fill,
      ),
    ));
  }

  Widget newsTextIcon() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Center(
        child: SlideAnimation(
            position: 3,
            itemCount: 4,
            slideDirection: SlideDirection.fromLeft,
            animationController: _newsImgController!,
            child: Image.asset(
              UiUtils.getImagePath("news.png"),
              height: 30.0,
              fit: BoxFit.fill,
              color: backgroundColor,
            )),
      ),
    );
  }

  Widget subTitle() {
    return AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(seconds: 1),
        child: Container(
          margin: const EdgeInsets.only(top: 20.0),
          child: Text(UiUtils.getTranslatedLabel(context, 'fastTrendNewsLbl'), style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: backgroundColor)),
        ));
  }

  Widget bottomText() {
    return Container(
        //Logo & text @ bottom
        margin: const EdgeInsetsDirectional.only(bottom: 20),
        child: Column(
          children: [madeByText(), const SizedBox(height: 5), companyLogo()],
        ));
  }

  Widget madeByText() {
    return SlideAnimation(
      position: 1,
      itemCount: 2,
      slideDirection: SlideDirection.fromBottom,
      animationController: _slideControllerBottom!,
      child: Text(
        UiUtils.getTranslatedLabel(context, 'madeBy'),
        style: TextStyle(
          color: backgroundColor.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget companyLogo() {
    return SlideAnimation(
        position: 1,
        itemCount: 2,
        slideDirection: SlideDirection.fromBottom,
        animationController: _slideControllerBottom!,
        child: Image.asset(
          UiUtils.getImagePath("wrteam_logo.png"),
          height: 25.0,
          fit: BoxFit.fill,
        ));
  }
}
