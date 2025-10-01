import 'package:dio/dio.dart';


/// @author Amrah sali
/// email: saliamrah300@gmail.com
/// sept, 2025
///
///

class ApiResponse {
  Response response;

  ApiResponse(this.response);

  dynamic _data;
  int? _statusCode;

  dynamic get data {
    _data = response.data;
    return _data;
  }

  int? get statusCode {
    _statusCode = response.statusCode;
    return _statusCode;
  }
}
