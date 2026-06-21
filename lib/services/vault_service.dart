import 'package:cloud_functions/cloud_functions.dart';

class VaultService {
  VaultService._();
  static final VaultService _instance = VaultService._();
  factory VaultService() => _instance;

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<void> requestNewLockPlan({required double amount, required int durationInMonths}) async {
    try {
      final callable = _functions.httpsCallable('executeVaultLock');
      final HttpsCallableResult result = await callable.call(<String, dynamic>{
        'amount': amount,
        'durationInMonths': durationInMonths,
      });

      final data = result.data as Map<String, dynamic>?;
      if (data == null || data['success'] != true) {
        throw Exception('Vault lock failed: ${data ?? 'unknown response'}');


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
      // We can optionally check the result, but the function returns success.
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Withdrawal error (\${e.code}): \${e.message}');
    } catch (e) {
      throw Exception('Withdrawal error: $e');
    }
  }

}
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Vault lock error (${e.code}): ${e.message}');
    } catch (e) {
      throw Exception('Vault lock error: $e');
    }
  }
}
