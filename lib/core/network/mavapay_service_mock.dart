import 'package:dio/dio.dart';
import 'api_response.dart';

/// Mock Mavapay Service for development and testing
/// This provides mock responses when the actual Mavapay API is not available
class MavapayServiceMock {
  
  /// Mock adding Naira funds
  Future<ApiResponse> addNairaFunds({
    required String userId,
    required double amount,
    required String currency,
    String? paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    return ApiResponse(
      Response(
        requestOptions: RequestOptions(path: '/transactions/deposit'),
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'transaction_id': 'mock_${DateTime.now().millisecondsSinceEpoch}',
            'amount': amount,
            'currency': currency,
            'status': 'completed',
            'created_at': DateTime.now().toIso8601String(),
          },
          'message': 'Funds added successfully'
        },
      ),
    );
  }

  /// Mock getting Bitcoin exchange rate
  Future<ApiResponse> getBitcoinExchangeRate() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return ApiResponse(
      Response(
        requestOptions: RequestOptions(path: '/exchange-rates/btc-ngn'),
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'from_currency': 'BTC',
            'to_currency': 'NGN',
            'rate': 50000.0, // Mock rate: 1 BTC = 50,000 NGN
            'last_updated': DateTime.now().toIso8601String(),
          },
          'message': 'Exchange rate retrieved successfully'
        },
      ),
    );
  }

  /// Mock converting Naira to Bitcoin
  Future<ApiResponse> convertNairaToBitcoin({
    required double nairaAmount,
    required String userId,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));
    
    final exchangeRate = 50000.0; // Mock rate
    final btcAmount = nairaAmount / exchangeRate;
    final fees = btcAmount * 0.01; // 1% fee
    final finalBtcAmount = btcAmount - fees;
    
    return ApiResponse(
      Response(
        requestOptions: RequestOptions(path: '/transactions/convert'),
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'transaction_id': 'convert_${DateTime.now().millisecondsSinceEpoch}',
            'from_amount': nairaAmount,
            'from_currency': 'NGN',
            'to_amount': finalBtcAmount,
            'to_currency': 'BTC',
            'exchange_rate': exchangeRate,
            'fees': fees,
            'created_at': DateTime.now().toIso8601String(),
          },
          'message': 'Currency converted successfully'
        },
      ),
    );
  }

  /// Mock getting user balance
  Future<ApiResponse> getUserBalance(String userId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    return ApiResponse(
      Response(
        requestOptions: RequestOptions(path: '/users/$userId/balance'),
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'naira_balance': 10000.0, // Mock Naira balance
            'bitcoin_balance': 0.0002, // Mock Bitcoin balance
            'bitcoin_balance_sats': 20000.0, // Mock sats balance
            'last_updated': DateTime.now().toIso8601String(),
          },
          'message': 'Balance retrieved successfully'
        },
      ),
    );
  }

  /// Mock getting transaction history
  Future<ApiResponse> getTransactionHistory({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    return ApiResponse(
      Response(
        requestOptions: RequestOptions(path: '/users/$userId/transactions'),
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'transactions': [
              {
                'id': 'txn_1',
                'type': 'deposit',
                'amount': 5000.0,
                'currency': 'NGN',
                'status': 'completed',
                'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
                'metadata': {'source': 'bank_transfer'}
              },
              {
                'id': 'txn_2',
                'type': 'conversion',
                'amount': 0.0001,
                'currency': 'BTC',
                'status': 'completed',
                'created_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
                'metadata': {'from_currency': 'NGN', 'from_amount': 5000.0}
              },
            ],
            'pagination': {
              'current_page': page,
              'total_pages': 1,
              'total_items': 2,
            }
          },
          'message': 'Transaction history retrieved successfully'
        },
      ),
    );
  }
}
