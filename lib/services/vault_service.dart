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
      }
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Vault lock error (${e.code}): ${e.message}');
    } catch (e) {
      throw Exception('Vault lock error: $e');
    }
  }
}
