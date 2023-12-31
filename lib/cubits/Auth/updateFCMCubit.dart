// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/Auth/authRepository.dart';

@immutable
abstract class UpdateFcmIdState {}

class UpdateFcmIdInitial extends UpdateFcmIdState {}

class UpdateFcmId extends UpdateFcmIdState {
  String? userId, fcmId;

  UpdateFcmId({this.userId, this.fcmId});
}

class UpdateFcmIdProgress extends UpdateFcmIdState {
  UpdateFcmIdProgress();
}

class UpdateFcmIdSuccess extends UpdateFcmIdState {
  UpdateFcmIdSuccess();
}

class UpdateFcmIdFailure extends UpdateFcmIdState {
  final String errorMessage;

  UpdateFcmIdFailure(this.errorMessage);
}

class UpdateFcmIdCubit extends Cubit<UpdateFcmIdState> {
  final AuthRepository _authRepository;

  UpdateFcmIdCubit(this._authRepository) : super(UpdateFcmIdInitial());

  //to update fcmId
  void updateFcmId({required String userId, required String fcmId, required BuildContext context}) {
    //emitting updateFcmIdProgress state
    emit(UpdateFcmIdProgress());
    //update fcmId of user with given provider and also update user fcmId in api
    _authRepository
        .updateFcmId(
      userId: userId,
      fcmId: fcmId,
      context: context,
    )
        .then((result) {
      emit(UpdateFcmIdSuccess());
    }).catchError((e) {
      emit(UpdateFcmIdFailure(e.toString()));
    });
  }
}
