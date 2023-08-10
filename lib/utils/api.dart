import 'dart:io';
import 'package:dio/dio.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:news/utils/ErrorMessageKeys.dart';
import 'package:news/utils/strings.dart';

import 'constant.dart';

class ApiMessageAndCodeException implements Exception {
  final String errorMessage;
  String? errorStatusCode;

  ApiMessageAndCodeException({required this.errorMessage, this.errorStatusCode});

  Map toError() => {"message": errorMessage, "code": errorStatusCode};

  @override
  String toString() => errorMessage;
}

class ApiException implements Exception {
  String errorMessage;

  ApiException(this.errorMessage);

  @override
  String toString() {
    return errorMessage;
  }
}

class Api {
  static String getToken() {
    final claimSet = JwtClaim(
      issuedAt: DateTime.now(),
      issuer: issuerName,
      expiry: DateTime.now().add(const Duration(days: 5)),
      subject: issSubjectName,
    );

    String token = issueJwtHS256(claimSet, jwtKey);
    return token;
  }

  static Map<String, String> get headers => {
        "Authorization": 'Bearer ${getToken()}',
      };

  //all apis list
  static String getUserSignUpApi = '${databaseUrl}user_signup';
  static String getNewsApi = '${databaseUrl}get_news';
  static String getNewsByCatApi = '${databaseUrl}get_news_by_category';
  static String getSettingApi = '${databaseUrl}get_settings';
  static String getCatApi = '${databaseUrl}get_category';
  static String getNewsByIdApi = '${databaseUrl}get_news_by_id';
  static String setBookmarkApi = '${databaseUrl}set_bookmark';
  static String getBookmarkApi = '${databaseUrl}get_bookmark';
  static String setCommentApi = '${databaseUrl}set_comment';
  static String getCommentByNewsApi = '${databaseUrl}get_comment_by_news';
  static String getBreakingNewsApi = '${databaseUrl}get_breaking_news';
  static String setProfileApi = '${databaseUrl}set_profile_image';
  static String setUpdateProfileApi = '${databaseUrl}update_profile';
  static String setRegisterToken = '${databaseUrl}register_token';
  static String getNotificationApi = '${databaseUrl}get_notification';
  static String setUserCatApi = '${databaseUrl}set_user_category';
  static String getUserByIdApi = '${databaseUrl}get_user_by_id';
  static String getNewsByUserCatApi = '${databaseUrl}get_news_by_user_category';
  static String setCommentDeleteApi = '${databaseUrl}delete_comment';
  static String setLikesDislikesApi = '${databaseUrl}set_like_dislike';
  static String setFlagApi = '${databaseUrl}set_flag';
  static String getLiveStreamingApi = '${databaseUrl}get_live_streaming';
  static String getSubCategoryApi = '${databaseUrl}get_subcategory_by_category';
  static String setLikeDislikeComApi = '${databaseUrl}set_comment_like_dislike';
  static String getNewsByTagApi = '${databaseUrl}get_news_by_tag';
  static String getUserNotificationApi = '${databaseUrl}get_user_notification';
  static String updateFCMIdApi = '${databaseUrl}update_fcm_id';
  static String deleteUserNotiApi = '${databaseUrl}delete_user_notification';
  static String getQueApi = '${databaseUrl}get_question';
  static String getQueResultApi = '${databaseUrl}get_question_result';
  static String setQueResultApi = '${databaseUrl}set_question_result';
  static String userDeleteApi = '${databaseUrl}delete_user';
  static String getTagsApi = '${databaseUrl}get_tag';
  static String setNewsApi = '${databaseUrl}set_news';
  static String updateNewsApi = '${databaseUrl}update_news';
  static String setDeleteNewsApi = '${databaseUrl}delete_news';
  static String setDeleteImageApi = '${databaseUrl}delete_news_images';
  static String getVideosApi = '${databaseUrl}get_videos';
  static String getLanguagesApi = '${databaseUrl}get_languages_list';
  static String getLangJsonDataApi = '${databaseUrl}get_language_json_data';
  static String getPagesApi = '${databaseUrl}get_pages';
  static String getPolicyPagesApi = '${databaseUrl}get_policy_pages';
  static String getFeatureSectionApi = '${databaseUrl}get_featured_sections';
  static String getLikeNewsApi = '${databaseUrl}get_like';
  static String getFeatureSectionByIdApi = '${databaseUrl}get_featured_section_by_id';

  static Future<Map<String, dynamic>> post({
    required Map<String, dynamic> body,
    required String url,
  }) async {
    try {
      final Dio dio = Dio();
      body[ACCESS_KEY] = accessKey;
      final FormData formData = FormData.fromMap(body, ListFormat.multiCompatible);

      final response = await dio.post(url, data: formData, options: Options(headers: headers));
      if (response.data['error'] == 'true') {
        throw ApiException(response.data['message']);
      }
      return Map.from(response.data);
    } on DioError catch (e) {
      throw ApiException(e.error is SocketException ? ErrorMessageKeys.noInternet : ErrorMessageKeys.defaultErrorMessage);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      throw ApiException(ErrorMessageKeys.defaultErrorMessage);
    }
  }
}
