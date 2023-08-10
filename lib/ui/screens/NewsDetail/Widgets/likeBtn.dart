// ignore_for_file: file_names

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/cubits/LikeAndDislikeNews/LikeAndDislikeCubit.dart';
import 'package:news/cubits/LikeAndDislikeNews/updateLikeAndDislikeCubit.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/ui/styles/colors.dart';
import 'package:news/ui/widgets/circularProgressIndicator.dart';
import 'package:news/ui/widgets/customTextLabel.dart';
import 'package:news/utils/uiUtils.dart';
import '../../../widgets/loginRequired.dart';

Widget likeBtn(BuildContext context, NewsModel model) {
  return BlocBuilder<LikeAndDisLikeCubit, LikeAndDisLikeState>(
      bloc: context.read<LikeAndDisLikeCubit>(),
      builder: (context, likeAndDislikeState) {
        bool isLike = context.read<LikeAndDisLikeCubit>().isNewsLikeAndDisLike(model.newsId!);
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
              return Positioned.directional(
                  textDirection: Directionality.of(context),
                  top: MediaQuery.of(context).size.height / 2.90,
                  end: MediaQuery.of(context).size.width / 8.5,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          if (context.read<AuthCubit>().getUserId() != "0") {
                            if (state is UpdateLikeAndDisLikeStatusInProgress) {
                              return;
                            }
                            context.read<UpdateLikeAndDisLikeStatusCubit>().setLikeAndDisLikeNews(
                                  context: context,
                                  userId: context.read<AuthCubit>().getUserId(),
                                  news: model,
                                  status: (isLike) ? "0" : "1",
                                );
                          } else {
                            loginRequired(context);
                          }
                        },
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(52.0),
                            child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 39,
                                  width: 39,
                                  decoration: const BoxDecoration(color: secondaryColor, shape: BoxShape.circle),
                                  child: (state is UpdateLikeAndDisLikeStatusInProgress)
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: showCircularProgress(true, Theme.of(context).primaryColor),
                                        )
                                      : isLike
                                          ? const Icon(Icons.thumb_up_alt, color: darkSecondaryColor)
                                          : const Icon(
                                              Icons.thumb_up_off_alt,
                                              color: darkSecondaryColor,
                                            ),
                                ))),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          top: 5.0,
                        ),
                        child: CustomTextLabel(
                          text: model.totalLikes != "0" ? "${model.totalLikes!} ${UiUtils.getTranslatedLabel(context, 'likeLbl')}" : "",
                          textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: UiUtils.getColorScheme(context).primaryContainer.withOpacity(0.7),
                              ),
                        ),
                      )
                    ],
                  ));
            });
      });
}
