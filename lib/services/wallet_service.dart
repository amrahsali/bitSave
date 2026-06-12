import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Stream<double> get spendingBalanceStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) => (snapshot.data()?['walletBalanceNGN'] as num?)?.toDouble() ?? 0.0);
  }

  Future<String> initializeDeposit({required double amount}) async {
    final callable = _functions.httpsCallable('initializePayment');
    final result = await callable.call({'amount': amount});
    return (result.data as Map<String, dynamic>)['checkoutUrl'] as String? ?? '';
  }
}