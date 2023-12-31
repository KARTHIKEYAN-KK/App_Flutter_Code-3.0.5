// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/NewsModel.dart';

import 'package:news/data/repositories/SurveyQuestion/surveyQueRepository.dart';

abstract class SurveyQuestionState {}

class SurveyQuestionInitial extends SurveyQuestionState {}

class SurveyQuestionFetchInProgress extends SurveyQuestionState {}

class SurveyQuestionFetchSuccess extends SurveyQuestionState {
  final List<NewsModel> surveyQuestion;

  SurveyQuestionFetchSuccess({
    required this.surveyQuestion,
  });
}

class SurveyQuestionFetchFailure extends SurveyQuestionState {
  final String errorMessage;

  SurveyQuestionFetchFailure(this.errorMessage);
}

class SurveyQuestionCubit extends Cubit<SurveyQuestionState> {
  final SurveyQuestionRepository _surveyQuestionRepository;

  SurveyQuestionCubit(this._surveyQuestionRepository) : super(SurveyQuestionInitial());

  Future<void> getSurveyQuestion({required BuildContext context, required String userId, required String langId}) async {
    try {
      emit(SurveyQuestionFetchInProgress());
      await _surveyQuestionRepository.getSurveyQuestion(context: context, langId: langId, userId: userId).then((value) {
        emit(SurveyQuestionFetchSuccess(surveyQuestion: value['SurveyQuestion']));
      });
    } catch (e) {
      emit(SurveyQuestionFetchFailure(e.toString()));
    }
  }

  void removeQuestion(int index) {
    if (state is SurveyQuestionFetchSuccess) {
      List<NewsModel> queList = List.from((state as SurveyQuestionFetchSuccess).surveyQuestion)..removeAt(index);

      emit(SurveyQuestionFetchSuccess(surveyQuestion: queList));
    }
  }

  List surveyList() {
    if (state is SurveyQuestionFetchSuccess) {
      return (state as SurveyQuestionFetchSuccess).surveyQuestion;
    }
    return [];
  }
}
