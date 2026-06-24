import 'package:cloud_functions/cloud_functions.dart';

class VaultService {
  VaultService._();
  static final VaultService _instance = VaultService._();
  factory VaultService() => _instance;

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Request a new vault lock (server-side Cloud Function will perform validation)
  Future<Map<String, dynamic>> requestNewLockPlan({required double amount, required int durationInMonths}) async {
    try {
      final callable = _functions.httpsCallable('executeVaultLock');
      final HttpsCallableResult result = await callable.call(<String, dynamic>{
        'amount': amount,
        'durationInMonths': durationInMonths,
      });

      final data = result.data as Map<String, dynamic>?;
      if (data == null || data['success'] != true) {
        throw Exception('Vault lock failed: ${data ?? 'unknown response'}');
      }

      return data;
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Vault lock error (${e.code}): ${e.message}');
    } catch (e) {
      throw Exception('Vault lock error: $e');
    }
  }

  /// Request a withdrawal for a matured lock
  Future<void> requestWithdrawal({
    required String lockId,
    required String accountNumber,
    required String bankCode,
  }) async {
    try {
      final result = await _functions.httpsCallable('executeVaultWithdrawal')
          .call(<String, dynamic>{
        'lockId': lockId,
        'accountNumber': accountNumber,
        'bankCode': bankCode,
      });

      final data = result.data as Map<String, dynamic>?;
      if (data == null || data['success'] != true) {
        throw Exception('Withdrawal failed: ${data ?? 'unknown response'}');
      }
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Withdrawal error (${e.code}): ${e.message}');
    } catch (e) {
      throw Exception('Withdrawal error: $e');
    }
  }
}
