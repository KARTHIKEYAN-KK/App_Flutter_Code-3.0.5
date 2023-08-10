import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:news/app/routes.dart';
import 'package:news/cubits/AddNewsCubit.dart';
import 'package:news/cubits/Auth/deleteUserCubit.dart';
import 'package:news/cubits/Auth/registerTokenCubit.dart';
import 'package:news/cubits/Auth/updateFCMCubit.dart';
import 'package:news/cubits/Auth/updateUserCubit.dart';
import 'package:news/cubits/Bookmark/UpdateBookmarkCubit.dart';
import 'package:news/cubits/Bookmark/bookmarkCubit.dart';
import 'package:news/cubits/LikeAndDislikeNews/LikeAndDislikeCubit.dart';
import 'package:news/cubits/LikeAndDislikeNews/updateLikeAndDislikeCubit.dart';
import 'package:news/cubits/NewsComment/deleteCommentCubit.dart';
import 'package:news/cubits/NewsComment/flagCommentCubit.dart';
import 'package:news/cubits/NewsComment/likeAndDislikeCommCubit.dart';
import 'package:news/cubits/NewsComment/setCommentCubit.dart';
import 'package:news/cubits/UserNotification/deleteUserNotification.dart';
import 'package:news/cubits/UserPreferences/setUserPreferenceCatCubit.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/breakingNewsCubit.dart';
import 'package:news/cubits/commentNewsCubit.dart';
import 'package:news/cubits/deleteImageId.dart';
import 'package:news/cubits/deleteUserNewsCubit.dart';
import 'package:news/cubits/editNewsCubit.dart';
import 'package:news/cubits/getSurveyAnswerCubit.dart';
import 'package:news/cubits/getUserDataByIdCubit.dart';
import 'package:news/cubits/getUserNewsCubit.dart';
import 'package:news/cubits/languageCubit.dart';
import 'package:news/cubits/relatedNewsCubit.dart';
import 'package:news/cubits/sectionByIdCubit.dart';
import 'package:news/cubits/setSurveyAnswerCubit.dart';
import 'package:news/cubits/settingCubit.dart';
import 'package:news/cubits/Auth/soicalSignUpCubit.dart';
import 'package:news/cubits/UserPreferences/userByCategoryCubit.dart';
import 'package:news/cubits/tagCubit.dart';
import 'package:news/cubits/tagNewsCubit.dart';
import 'package:news/data/repositories/AddNews/addNewsRepository.dart';
import 'package:news/data/repositories/Auth/authRepository.dart';
import 'package:news/data/repositories/Bookmark/bookmarkRepository.dart';
import 'package:news/data/repositories/BreakingNews/breakNewsRepository.dart';
import 'package:news/data/repositories/CommentNews/commNewsRepository.dart';
import 'package:news/data/repositories/DeleteImageId/deleteImageRepository.dart';
import 'package:news/data/repositories/DeleteUserNews/deleteUserNewsRepository.dart';
import 'package:news/data/repositories/DeleteUserNotification/deleteUserNotiRepository.dart';
import 'package:news/data/repositories/EditNews/editNewsRepository.dart';
import 'package:news/data/repositories/GetSurveyAnswer/getSurveyAnsRepository.dart';
import 'package:news/data/repositories/GetUserById/getUserByIdRepository.dart';
import 'package:news/data/repositories/GetUserNews/getUserNewsRepository.dart';
import 'package:news/data/repositories/LikeAndDisLikeNews/LikeAndDisLikeNewsRepository.dart';
import 'package:news/data/repositories/NewsComment/DeleteComment/deleteCommRepository.dart';
import 'package:news/data/repositories/NewsComment/FlagComment/flagCommRepository.dart';
import 'package:news/data/repositories/NewsComment/LikeAndDislikeComment/likeAndDislikeCommRepository.dart';
import 'package:news/data/repositories/NewsComment/SetComment/setComRepository.dart';
import 'package:news/data/repositories/RelatedNews/relatedNewsRepository.dart';
import 'package:news/data/repositories/SectionById/sectionByIdRepository.dart';
import 'package:news/data/repositories/SetSurveyAnswer/setSurveyAnsRepository.dart';
import 'package:news/data/repositories/SetUserPreferenceCat/setUserPrefCatRepository.dart';
import 'package:news/data/repositories/SurveyQuestion/surveyQueRepository.dart';
import 'package:news/data/repositories/Tag/tagRepository.dart';
import 'package:news/data/repositories/TagNews/tagNewsRepository.dart';
import 'package:news/data/repositories/UserByCategory/userByCatRepository.dart';
import 'package:news/data/repositories/language/languageRepository.dart';
import 'package:news/data/repositories/Settings/settingRepository.dart';
import 'package:news/data/repositories/Settings/settingsLocalDataRepository.dart';
import 'package:news/data/repositories/AppSystemSetting/systemRepository.dart';

import '../cubits/NewsByIdCubit.dart';
import '../cubits/NotificationCubit.dart';
import '../cubits/appSystemSettingCubit.dart';
import '../cubits/categoryCubit.dart';
import '../cubits/featureSectionCubit.dart';
import '../cubits/languageJsonCubit.dart';
import '../cubits/liveStreamCubit.dart';
import '../cubits/otherPagesCubit.dart';
import '../cubits/subCategoryCubit.dart';
import '../cubits/surveyQuestionCubit.dart';
import '../cubits/themeCubit.dart';
import '../cubits/UserNotification/userNotificationCubit.dart';
import '../cubits/videosCubit.dart';
import '../data/repositories/Category/categoryRepository.dart';
import '../data/repositories/FeatureSection/sectionRepository.dart';
import '../data/repositories/LanguageJson/languageJsonRepository.dart';
import '../data/repositories/LiveStream/liveStreamRepository.dart';
import '../data/repositories/NewsById/NewsByIdRepository.dart';
import '../data/repositories/Notification/notificationRepository.dart';
import '../data/repositories/OtherPages/otherPagesRepository.dart';
import '../data/repositories/SubCategory/subCatRepository.dart';
import '../data/repositories/UserNotification/userNotiRepository.dart';
import '../data/repositories/Videos/videosRepository.dart';
import '../ui/screens/PushNotificationService.dart';
import '../ui/styles/appTheme.dart';

import '../utils/hiveBoxKeys.dart';
import '../utils/uiUtils.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  MobileAds.instance.initialize();

  await Firebase.initializeApp();

  await Hive.initFlutter();

  await Hive.openBox(authBoxKey);

  await Hive.openBox(settingsBoxKey);

  runApp(MultiBlocProvider(providers: [
    BlocProvider<AppConfigurationCubit>(create: (context) => AppConfigurationCubit(SystemRepository())),
    BlocProvider<SettingsCubit>(create: (_) => SettingsCubit(SettingsRepository())),
    BlocProvider<AppLocalizationCubit>(create: (_) => AppLocalizationCubit(SettingsLocalDataRepository())),
    BlocProvider<ThemeCubit>(create: (_) => ThemeCubit(SettingsLocalDataRepository())),
    BlocProvider<LanguageJsonCubit>(create: (_) => LanguageJsonCubit(LanguageJsonRepository())),
    BlocProvider<LanguageCubit>(create: (context) => LanguageCubit(LanguageRepository())),
    BlocProvider<SectionCubit>(create: (_) => SectionCubit(SectionRepository())),
    BlocProvider<VideoCubit>(create: (_) => VideoCubit(VideoRepository())),
    BlocProvider<NotificationCubit>(create: (_) => NotificationCubit(NotificationRepository())),
    BlocProvider<UserNotificationCubit>(create: (_) => UserNotificationCubit(UserNotificationRepository())),
    BlocProvider<NewsByIdCubit>(create: (_) => NewsByIdCubit(NewsByIdRepository())),
    BlocProvider<OtherPageCubit>(create: (_) => OtherPageCubit(OtherPageRepository())),
    BlocProvider<LiveStreamCubit>(create: (_) => LiveStreamCubit(LiveStreamRepository())),
    BlocProvider<CategoryCubit>(create: (_) => CategoryCubit(CategoryRepository())),
    BlocProvider<SubCategoryCubit>(
      create: (_) => SubCategoryCubit(SubCategoryRepository()),
    ),
    BlocProvider<SurveyQuestionCubit>(
      create: (_) => SurveyQuestionCubit(SurveyQuestionRepository()),
    ),
    BlocProvider<SetSurveyAnsCubit>(
      create: (_) => SetSurveyAnsCubit(SetSurveyAnsRepository()),
    ),
    BlocProvider<GetSurveyAnsCubit>(
      create: (_) => GetSurveyAnsCubit(GetSurveyAnsRepository()),
    ),
    BlocProvider<CommentNewsCubit>(
      create: (_) => CommentNewsCubit(CommentNewsRepository()),
    ),
    BlocProvider<RelatedNewsCubit>(
      create: (_) => RelatedNewsCubit(RelatedNewsRepository()),
    ),
    BlocProvider<SocialSignUpCubit>(
      create: (_) => SocialSignUpCubit(AuthRepository()),
    ),
    BlocProvider<AuthCubit>(
      create: (_) => AuthCubit(AuthRepository()),
    ),
    BlocProvider<RegisterTokenCubit>(
      create: (_) => RegisterTokenCubit(AuthRepository()),
    ),
    BlocProvider<UpdateFcmIdCubit>(
      create: (_) => UpdateFcmIdCubit(AuthRepository()),
    ),
    BlocProvider<UserByCatCubit>(
      create: (_) => UserByCatCubit(UserByCatRepository()),
    ),
    BlocProvider<SetUserPrefCatCubit>(
      create: (_) => SetUserPrefCatCubit(SetUserPrefCatRepository()),
    ),
    BlocProvider<UpdateUserCubit>(
      create: (_) => UpdateUserCubit(AuthRepository()),
    ),
    BlocProvider<DeleteUserCubit>(
      create: (_) => DeleteUserCubit(AuthRepository()),
    ),
    BlocProvider<BookmarkCubit>(
      create: (_) => BookmarkCubit(BookmarkRepository()),
    ),
    BlocProvider<UpdateBookmarkStatusCubit>(
      create: (_) => UpdateBookmarkStatusCubit(BookmarkRepository()),
    ),
    BlocProvider<LikeAndDisLikeCubit>(
      create: (_) => LikeAndDisLikeCubit(LikeAndDisLikeRepository()),
    ),
    BlocProvider<UpdateLikeAndDisLikeStatusCubit>(
      create: (_) => UpdateLikeAndDisLikeStatusCubit(LikeAndDisLikeRepository()),
    ),
    BlocProvider<BreakingNewsCubit>(
      create: (_) => BreakingNewsCubit(BreakingNewsRepository()),
    ),
    BlocProvider<TagNewsCubit>(
      create: (_) => TagNewsCubit(TagNewsRepository()),
    ),
    BlocProvider<SetCommentCubit>(
      create: (_) => SetCommentCubit(SetCommentRepository()),
    ),
    BlocProvider<LikeAndDislikeCommCubit>(
      create: (_) => LikeAndDislikeCommCubit(LikeAndDislikeCommRepository()),
    ),
    BlocProvider<DeleteCommCubit>(
      create: (_) => DeleteCommCubit(DeleteCommRepository()),
    ),
    BlocProvider<SetFlagCubit>(
      create: (_) => SetFlagCubit(SetFlagRepository()),
    ),
    BlocProvider<AddNewsCubit>(
      create: (_) => AddNewsCubit(AddNewsRepository()),
    ),
    BlocProvider<TagCubit>(
      create: (_) => TagCubit(TagRepository()),
    ),
    BlocProvider<EditNewsCubit>(
      create: (_) => EditNewsCubit(EditNewsRepository()),
    ),
    BlocProvider<GetUserNewsCubit>(
      create: (_) => GetUserNewsCubit(GetUserNewsRepository()),
    ),
    BlocProvider<DeleteUserNewsCubit>(
      create: (_) => DeleteUserNewsCubit(DeleteUserNewsRepository()),
    ),
    BlocProvider<DeleteImageCubit>(
      create: (_) => DeleteImageCubit(DeleteImageRepository()),
    ),
    BlocProvider<DeleteUserNotiCubit>(
      create: (_) => DeleteUserNotiCubit(DeleteUserNotiRepository()),
    ),
    BlocProvider<GetUserByIdCubit>(
      create: (_) => GetUserByIdCubit(GetUserByIdRepository()),
    ),
    BlocProvider<SectionByIdCubit>(
      create: (_) => SectionByIdCubit(SectionByIdRepository()),
    ),
  ], child: const MyApp()));
}

class GlobalScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    final pushNotificationService = PushNotificationService(context: context);
    pushNotificationService.initialise();
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    if (brightness == Brightness.dark || (context.read<ThemeCubit>().state.appTheme == AppTheme.Dark)) {
      context.read<ThemeCubit>().changeTheme(AppTheme.Dark);
    } else {
      context.read<ThemeCubit>().changeTheme(AppTheme.Light);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final currentTheme = context.watch<ThemeCubit>().state.appTheme;

      return BlocBuilder<AppLocalizationCubit, AppLocalizationState>(builder: (context, state) {
        return MaterialApp(
          navigatorKey: UiUtils.rootNavigatorKey,
          theme: appThemeData[currentTheme],
          builder: (context, widget) {
            return ScrollConfiguration(
                behavior: GlobalScrollBehavior(), child: Directionality(textDirection: state.isRTL == '' || state.isRTL == "0" ? TextDirection.ltr : TextDirection.rtl, child: widget!));
          },
          debugShowCheckedModeBanner: false,
          initialRoute: Routes.splash,
          onGenerateRoute: Routes.onGenerateRouted,
        );
      });
    });
  }
}
