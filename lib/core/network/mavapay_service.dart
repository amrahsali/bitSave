import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_response.dart';

/// Mavapay API Service for handling Naira transactions
/// This service handles adding Naira funds and Bitcoin conversions
class MavapayService {
  final Dio _dio;
  String? _bearerToken;
  String? _apiKey;
  
  MavapayService() : _dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://api.mavapay.co/api/v1',
      connectTimeout: 30000,
      receiveTimeout: 30000,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    if (!kReleaseMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => debugPrint(object.toString()),
      ));
    }

    return dio;
  }

  // Optional: configure auth at runtime
  void setBearerToken(String token) {
    _bearerToken = token;
  }

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  Options _authOptions() {
    final headers = <String, dynamic>{};
    if (_bearerToken != null && _bearerToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ' + _bearerToken!;
    }
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      headers['x-api-key'] = _apiKey;
    }
    return Options(headers: headers.isEmpty ? null : headers);
  }

  /// Create a quote (NGN -> BTC)
  Future<ApiResponse> createQuote({
    required double amountNgn,
  }) async {
    try {
      final response = await _dio.post(
        '/quote',
        data: {
          'from_currency': 'NGN',
          'to_currency': 'BTC',
          'amount': amountNgn,
        },
        options: _authOptions(),
      );
      return ApiResponse(response);
    } on DioError catch (e) {
      return ApiResponse(
        Response(
          requestOptions: RequestOptions(path: '/quote'),
          statusCode: e.response?.statusCode ?? 500,
          data: e.response?.data ?? {'message': 'Failed to create quote: $e'},
        ),
      );
    } catch (e) {
      return ApiResponse(
        Response(
          requestOptions: RequestOptions(path: '/quote'),
          statusCode: 500,
          data: {'message': 'Network error: $e'},
        ),
      );
    }
  }

  /// Place an order using a quote
  Future<ApiResponse> createOrder({
    required String quoteId,
    String paymentMethod = 'bank_transfer',
  }) async {
    try {
      final response = await _dio.post(
        '/order',
        data: {
          'quote_id': quoteId,
          'payment_method': paymentMethod,
        },
        options: _authOptions(),
      );
      return ApiResponse(response);
    } on DioError catch (e) {
      return ApiResponse(
        Response(
          requestOptions: RequestOptions(path: '/order'),
          statusCode: e.response?.statusCode ?? 500,
          data: e.response?.data ?? {'message': 'Failed to create order: $e'},
        ),
      );
    } catch (e) {
      return ApiResponse(
        Response(
          requestOptions: RequestOptions(path: '/order'),
          statusCode: 500,
          data: {'message': 'Network error: $e'},
        ),
      );
    }
  }

  /// Get current Bitcoin to Naira exchange rate
  Future<ApiResponse> getBitcoinExchangeRate() async {
    try {
      // If 404, confirm correct pricing endpoint with provider (e.g. /price/btc-ngn)
      final response = await _dio.get('/price/btc-ngn', options: _authOptions());
      return ApiResponse(response);
    } on DioError catch (e) {
      return ApiResponse(
        Response(
          requestOptions: RequestOptions(path: '/price/btc-ngn'),
          statusCode: e.response?.statusCode ?? 500,
          data: e.response?.data ?? {'message': 'Failed to get exchange rate: $e'},
        ),
      );
    } catch (e) {
      return ApiResponse(
        Response(
          requestOptions: RequestOptions(path: '/price/btc-ngn'),
          statusCode: 500,
          data: {'message': 'Network error: $e'},
        ),
      );
    }
  }

  /// Convert Naira to Bitcoin
  Future<ApiResponse> convertNairaToBitcoin({
    required double nairaAmount,
    required String userId,
  }) async {
    try {
      final response = await _dio.post('/transactions/convert', data: {
        'user_id': userId,
        'from_currency': 'NGN',
        'to_currency': 'BTC',
        'amount': nairaAmount,
      }, options: _authOptions());

      return ApiResponse(response);
    } on DioError catch (e) {
      return ApiResponse(
        Response(
          requestOptions: RequestOptions(path: '/transactions/convert'),
          statusCode: e.response?.statusCode ?? 500,
          data: e.response?.data ?? {'message': 'Failed to convert currency: $e'},
        ),
      );
    } catch (e) {
      return ApiResponse(
        Response(
          requestOptions: RequestOptions(path: '/transactions/convert'),
          statusCode: 500,
          data: {'message': 'Network error: $e'},
        ),
      );
    }
  }
  /// Add Naira funds to user's account
  Future<ApiResponse> addNairaFunds({
    required String userId,
    required double amount,
    required String currency,
    required String paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.post(
        '/transactions/deposit',
        data: {
          'user_id': userId,
          'amount': amount,
          'currency': currency,
          'payment_method': paymentMethod,
          'metadata': metadata,
        },
        options: _authOptions(),
      );
      return ApiResponse(response);
    } on DioError catch (e) {
      return ApiResponse(
        Response(
          requestOptions: RequestOptions(path: '/transactions/deposit'),
          statusCode: e.response?.statusCode ?? 500,
          data: e.response?.data ?? {'message': 'Failed to add funds: $e'},
        ),
      );
    } catch (e) {
      return ApiResponse(
        Response(
          requestOptions: RequestOptions(path: '/transactions/deposit'),
          statusCode: 500,
          data: {'message': 'Network error: $e'},
        ),
      );
    }
  }

  /// Get wallets/balances
  Future<ApiResponse> getWallets() async {
    try {
      final response = await _dio.get('/wallet', options: _authOptions());
      return ApiResponse(response);
    } on DioError catch (e) {
      return ApiResponse(
        Response(
          requestOptions: RequestOptions(path: '/wallet'),
          statusCode: e.response?.statusCode ?? 500,
          data: e.response?.data ?? {'message': 'Failed to get balance: $e'},
        ),
      );
    } catch (e) {
      return ApiResponse(
        Response(
          requestOptions: RequestOptions(path: '/wallet'),
          statusCode: 500,
          data: {'message': 'Network error: $e'},
        ),
      );
    }
  }

  /// Get transaction history
  Future<ApiResponse> getTransactionHistory({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/users/$userId/transactions', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return ApiResponse(response);
    } on DioError catch (e) {
      return ApiResponse(
        Response(
          requestOptions: RequestOptions(path: '/users/$userId/transactions'),
          statusCode: e.response?.statusCode ?? 500,
          data: e.response?.data ?? {'message': 'Failed to get transaction history: $e'},
        ),
      );
    } catch (e) {
      return ApiResponse(
        Response(
          requestOptions: RequestOptions(path: '/users/$userId/transactions'),
          statusCode: 500,
          data: {'message': 'Network error: $e'},
        ),
      );
    }
  }

/// Get user balance information
Future<ApiResponse> getUserBalance(String userId) async {
  try {
    final response = await _dio.get(
      '/users/$userId/balance',
      options: _authOptions(),
    );
    return ApiResponse(response);
  } on DioError catch (e) {
    return ApiResponse(
      Response(
        requestOptions: RequestOptions(path: '/users/$userId/balance'),
        statusCode: e.response?.statusCode ?? 500,
        data: e.response?.data ?? {'message': 'Failed to get user balance: $e'},
      ),
    );
  } catch (e) {
    return ApiResponse(
      Response(
        requestOptions: RequestOptions(path: '/users/$userId/balance'),
        statusCode: 500,
        data: {'message': 'Network error: $e'},
      ),
    );
  }
}
}
