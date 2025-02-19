import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

class DeleteUserNewsRemoteDataSource {
  Future deleteUserNews({required String newsId}) async {
    try {
      final body = {
        ID: newsId,
      };
      final result = await Api.sendApiRequest(
        body: body,
        url: Api.setDeleteNewsApi,
      );
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
