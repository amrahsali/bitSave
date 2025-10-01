import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
import '../data/repositories/repository.dart';
import '../utils/dialog_utils.dart';
import 'api_service.dart';

/// @author Amrah sali
/// email: saliamrah300@gmail.com
/// sept, 2025
///
///

final nav = locator<NavigationService>();

final logInterceptor = PrettyDioLogger(
  requestHeader: true,
  requestBody: true,
  responseBody: true,
  responseHeader: false,
  error: true,
  compact: true,
  maxWidth: 90,
);

int refreshTokenRetryCount = 0;
const int maxRetryCount = 3;
final repo = locator<Repository>();
final apiService = locator<ApiService>();
bool isDialogBeingDisplayed = false;

final requestInterceptors = InterceptorsWrapper(
  onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  },
  onResponse: (Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  },
  onError: (DioError dioError, ErrorInterceptorHandler handler) async {

    if (dioError.type == DioErrorType.connectTimeout) {
      await showDialog("Connection Timed Out", null, isDialogBeingDisplayed);
    }
    else if (dioError.type == DioErrorType.other) {
      await showDialog("Network is unreachable", null, isDialogBeingDisplayed);
    }
    else if (dioError.type == DioErrorType.receiveTimeout) {
      await showDialog("Receive Timed Out", null, isDialogBeingDisplayed);
    }
    else if (dioError.response?.statusCode == 401 && !dioError.requestOptions.path.startsWith('auth')) {
      print('value of path is ${dioError.requestOptions.path}');
      handler.next(dioError);
    }
    else if(dioError.response?.statusCode == 401 && dioError.requestOptions.path.startsWith('/auth')){
      if (kDebugMode) {
        print('incorrect credentials');
      }
      if(dioError.response != null && dioError.response!.statusMessage != null){
        await showDialog(dioError.response!.statusMessage!, null, isDialogBeingDisplayed);
      }
    }
    else{
      handler.next(dioError);
    }
  },
);