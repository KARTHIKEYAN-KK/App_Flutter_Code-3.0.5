// ignore_for_file: file_names

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/Bookmark/bookmarkCubit.dart';
import 'package:news/cubits/LikeAndDislikeNews/LikeAndDislikeCubit.dart';
import 'package:news/cubits/featureSectionCubit.dart';
import 'package:news/cubits/getUserDataByIdCubit.dart';
import 'package:news/data/models/AuthModel.dart';
import 'package:news/data/models/FeatureSectionModel.dart';
import 'package:news/ui/screens/HomePage/Widgets/LiveWithSearchView.dart';
import 'package:news/ui/screens/HomePage/Widgets/SectionShimmer.dart';
import 'package:news/ui/screens/HomePage/Widgets/WeatherData.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import '../../../cubits/appLocalizationCubit.dart';
import '../../../cubits/liveStreamCubit.dart';
import '../../../data/models/WeatherData.dart';
import '../../../utils/constant.dart';
import 'package:location/location.dart' as loc;
import '../../../utils/strings.dart';
import 'Widgets/SectionStyle1.dart';
import 'Widgets/SectionStyle2.dart';
import 'Widgets/SectionStyle3.dart';
import 'Widgets/SectionStyle4.dart';
import 'Widgets/SectionStyle5.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => const HomeScreen(),
    );
  }
}

class HomeScreenState extends State<HomeScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  WeatherData? weatherData;
  bool weatherLoad = true;
  final loc.Location _location = loc.Location();
  bool? _serviceEnabled;
  loc.PermissionStatus? _permissionGranted;

  void getSections() {
    Future.delayed(Duration.zero, () {
      context.read<SectionCubit>().getSection(context: context, langId: context.read<AppLocalizationCubit>().state.id, userId: context.read<AuthCubit>().getUserId());
    });
  }

  void getLiveStreamData() {
    Future.delayed(Duration.zero, () {
      context.read<LiveStreamCubit>().getLiveStream(context: context, langId: context.read<AppLocalizationCubit>().state.id);
    });
  }

  void getBookmark() {
    Future.delayed(Duration.zero, () {
      context.read<BookmarkCubit>().getBookmark(context: context, langId: context.read<AppLocalizationCubit>().state.id, userId: context.read<AuthCubit>().getUserId());
    });
  }

  void getLikeNews() {
    Future.delayed(Duration.zero, () {
      context.read<LikeAndDisLikeCubit>().getLikeAndDisLike(context: context, langId: context.read<AppLocalizationCubit>().state.id, userId: context.read<AuthCubit>().getUserId());
    });
  }

  void getUserData() {
    Future.delayed(Duration.zero, () {
      context.read<GetUserByIdCubit>().getUserById(context: context, userId: context.read<AuthCubit>().getUserId());
    });
  }

  getWeatherData() async {
    loc.LocationData locationData;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled!) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }
    locationData = await _location.getLocation();

    final lat = locationData.latitude;
    final lon = locationData.longitude;
    final Dio dio = Dio();
    final weatherResponse = await dio.get('https://api.weatherapi.com/v1/forecast.json?key=d0f2f4dbecc043e78d6123135212408&q=${lat.toString()},${lon.toString()}&days=1&aqi=no&alerts=no');

    if (weatherResponse.statusCode == 200) {
      if (mounted) {
        return setState(() {
          weatherData = WeatherData.fromJson(Map.from(weatherResponse.data));
          weatherLoad = false;
        });
      }
    }

    setState(() {
      weatherLoad = false;
    });
  }

  @override
  void initState() {
    if (context.read<AuthCubit>().getUserId() != "0") {
      getUserData();
      getBookmark();
      getLikeNews();
    }
    getLiveStreamData();
    if (isWeatherDataShow) {
      getWeatherData();
    }
    getSections();

    super.initState();
  }

  Widget getSectionList() {
    return BlocBuilder<SectionCubit, SectionState>(builder: (context, state) {
      if (state is SectionFetchSuccess) {
        return ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: ((context, index) {
              return sectionData(index, state.section[index]);
            }),
            itemCount: state.section.length);
      }
      if (state is SectionFetchFailure) {
        return Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height / 3.2,
          ),
          child: const CustomTextLabel(
            text: 'noNews',
            textAlign: TextAlign.center,
          ),
        );
      }
      return sectionShimmer(context); //state is SectionFetchInProgress || state is SectionInitial
    });
  }

  Widget sectionData(int index, FeatureSectionModel model) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (model.styleApp == 'style_1') Style1Section(model: model),
        if (model.styleApp == 'style_2') Style2Section(model: model),
        if (model.styleApp == 'style_3') Style3Section(model: model),
        if (model.styleApp == 'style_4') Style4Section(model: model),
        if (model.styleApp == 'style_5') Style5Section(model: model),
      ],
    );
  }

  //refresh function to refresh page
  Future<void> _refresh() async {
    if (context.read<AuthCubit>().getUserId() != "0") {
      getUserData();
      getBookmark();
      getLikeNews();
    }
    getLiveStreamData();
    if (isWeatherDataShow) {
      setState(() {
        weatherLoad = true;
        weatherData = null;
      });
      getWeatherData();
    }
    getSections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () => _refresh(),
            child: BlocListener<GetUserByIdCubit, GetUserByIdState>(
              bloc: context.read<GetUserByIdCubit>(),
              listener: (context, state) {
                if (state is GetUserByIdFetchSuccess) {
                  var data = (state).result;
                  context.read<AuthCubit>().updateDetails(
                      authModel: AuthModel(
                          id: data[0][ID],
                          name: data[0][NAME],
                          status: data[0][STATUS],
                          mobile: data[0][MOBILE],
                          email: data[0][EMAIL],
                          type: data[0][TYPE],
                          profile: data[0][PROFILE],
                          role: data[0][ROLE]));
                }
              },
              child: ListView(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsetsDirectional.only(top: MediaQuery.of(context).padding.top, start: 15.0, end: 15.0, bottom: 10.0),
                  children: [const LiveWithSearchView(), if (weatherData != null) WeatherDataView(weatherData: weatherData!, weatherLoad: weatherLoad), getSectionList()]),
            )));
  }
}
