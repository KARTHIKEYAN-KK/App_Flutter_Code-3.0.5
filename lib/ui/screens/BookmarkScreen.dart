// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/Bookmark/bookmarkCubit.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/customAppBar.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/ui/widgets/networkImage.dart';
import 'package:news/ui/widgets/shimmerNewsList.dart';
import 'package:news/utils/uiUtils.dart';
import 'package:news/app/routes.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/ui/widgets/circularProgressIndicator.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  BookmarkScreenState createState() => BookmarkScreenState();
}

class BookmarkScreenState extends State<BookmarkScreen> {
  late final ScrollController _controller = ScrollController()..addListener(hasMoreUserNotiScrollListener);

  @override
  void initState() {
    super.initState();
    getBookMark();
  }

  getBookMark() {
    Future.delayed(Duration.zero, () {
      context.read<BookmarkCubit>().getBookmark(
            context: context,
            langId: context.read<AppLocalizationCubit>().state.id,
            userId: context.read<AuthCubit>().getUserId(),
          );
    });
  }

  void hasMoreUserNotiScrollListener() {
    if (_controller.position.maxScrollExtent == _controller.offset) {
      if (context.read<BookmarkCubit>().hasMoreBookmark()) {
        context.read<BookmarkCubit>().getMoreBookmark(context: context, langId: context.read<AppLocalizationCubit>().state.id, userId: context.read<AuthCubit>().getUserId());
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: setCustomAppBar(height: 45, isBackBtn: true, label: 'bookmarkLbl', context: context, horizontalPad: 15, isConvertText: true),
        body: Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 10.0, start: 0.0, end: 0.0),
            child: context.read<AuthCubit>().getUserId() != "0"
                ? BlocBuilder<BookmarkCubit, BookmarkState>(
                    builder: (context, state) {
                      if (state is BookmarkFetchSuccess && state.bookmark.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(start: 15.0, end: 15.0, top: 10.0, bottom: 10.0),
                          child: RefreshIndicator(
                            onRefresh: () async {
                              context.read<BookmarkCubit>().getBookmark(
                                    context: context,
                                    langId: context.read<AppLocalizationCubit>().state.id,
                                    userId: context.read<AuthCubit>().getUserId(),
                                  );
                            },
                            child: ListView.builder(
                                controller: _controller,
                                physics: const AlwaysScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: state.bookmark.length,
                                itemBuilder: (context, index) {
                                  return _buildBookmarkContainer(
                                    model: state.bookmark[index],
                                    hasMore: state.hasMore,
                                    hasMoreBookFetchError: state.hasMoreFetchError,
                                    index: index,
                                    totalCurrentBook: state.bookmark.length,
                                  );
                                }),
                          ),
                        );
                      }
                      if (state is BookmarkFetchFailure || ((state is! BookmarkFetchInProgress) && (state as BookmarkFetchSuccess).bookmark.isEmpty)) {
                        //List check due to forcefully successState for getBookmark APi @Cubit
                        return const Center(
                            child: CustomTextLabel(
                          text: 'bookmarkNotAvail',
                          textAlign: TextAlign.center,
                        ));
                      }
                      //default/Processing state
                      return Padding(padding: const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0), child: shimmerNewsList(context));
                    },
                  )
                : loginMsg()));
  }

  _buildBookmarkContainer({
    required NewsModel model,
    required int index,
    required int totalCurrentBook,
    required bool hasMoreBookFetchError,
    required bool hasMore,
  }) {
    if (index == totalCurrentBook - 1) {
      //check if hasMore
      if (hasMore) {
        if (hasMoreBookFetchError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
              child: IconButton(
                  onPressed: () {
                    context.read<BookmarkCubit>().getMoreBookmark(context: context, langId: context.read<AppLocalizationCubit>().state.id, userId: context.read<AuthCubit>().getUserId());
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

    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 15.0),
      child: InkWell(
        child: Stack(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(10.0), child: CustomNetworkImage(networkImageUrl: model.image!, height: 215, width: double.maxFinite, fit: BoxFit.cover, isVideo: false)),
            Positioned.directional(
                textDirection: Directionality.of(context),
                bottom: 0,
                start: 0,
                end: 0,
                height: 95,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [darkSecondaryColor.withOpacity(0.01), darkSecondaryColor.withOpacity(0.75)])
                          .createShader(bounds);
                    },
                    blendMode: BlendMode.overlay,
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      color: Colors.transparent,
                      child: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 10, end: 10),
                          child: Container(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  UiUtils.convertToAgo(context, DateTime.parse(model.date!), 0)!,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.w600),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      model.title!,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: secondaryColor, fontWeight: FontWeight.w600, fontSize: 15, height: 1.0, letterSpacing: 0.5),
                                      maxLines: 3,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                              ],
                            ),
                          )),
                    ),
                  ),
                )),
          ],
        ),
        onTap: () async {
          Navigator.of(context).pushNamed(Routes.newsDetails, arguments: {"model": model, "isFromBreak": false, "fromShowMore": false});
        },
      ),
    );
  }

//news bookmark list have no news then call this function
  Widget getNoItem() {
    return const Center(child: CustomTextLabel(text: 'bookmarkNotAvail'));
  }

//user not login then show this function used to navigate login screen
  Widget loginMsg() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomTextLabel(
              text: 'bookmarkLogin',
              textStyle: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            InkWell(
                child: CustomTextLabel(
                  text: 'loginNowLbl',
                  textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(Routes.login);
                }),
          ],
        ));
  }
}
