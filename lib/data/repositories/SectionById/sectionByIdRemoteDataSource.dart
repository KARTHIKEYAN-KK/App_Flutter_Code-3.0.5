// ignore_for_file: file_names

import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

class SectionByIdRemoteDataSource {
  Future<dynamic> getSectionById({required String limit, required String offset, required String userId, required String langId, required String sectionId}) async {
    try {
      final body = {LIMIT: limit, OFFSET: offset, USER_ID: userId, LANGUAGE_ID: langId, SECTION_ID: sectionId};

      final result = await Api.post(body: body, url: Api.getFeatureSectionByIdApi);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
