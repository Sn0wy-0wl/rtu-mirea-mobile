import 'package:dio/dio.dart';
import 'package:rtu_mirea_app/common/errors/exceptions.dart';
import 'package:rtu_mirea_app/data/models/schedule_model.dart';

abstract class ScheduleRemoteData {
  Future<ScheduleModel> getScheduleByGroup(String group);
  Future<List<String>> getGroups();
}

class ScheduleRemoteDataImpl implements ScheduleRemoteData {
  static const _API_BASE_URL = 'http://127.0.0.1:5000/api/';

  final Dio httpClient;

  ScheduleRemoteDataImpl({required this.httpClient});

  @override
  Future<List<String>> getGroups() async {
    try {
      final response = await httpClient.get(_API_BASE_URL + '/schedule/groups');
      if (response.statusCode == 200) {
        List<String> groups = response.data['groups'];
        return groups;
      } else {
        throw RemoteDataException(
            'Response status code is $response.statusCode');
      }
    } catch (e) {
      throw RemoteDataException(e.toString());
    }
  }

  @override
  Future<ScheduleModel> getScheduleByGroup(String group) async {
    try {
      final response = await httpClient
          .get(_API_BASE_URL + '/schedule/$group/full_schedule');
      if (response.statusCode == 200) {
        return ScheduleModel.fromJson(response.data);
      } else {
        throw RemoteDataException(
            'Response status code is $response.statusCode');
      }
    } catch (e) {
      throw RemoteDataException(e.toString());
    }
  }
}