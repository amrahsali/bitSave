import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  FirebaseAuth get firebaseAuth => _auth;
  FirebaseFirestore get firestore => _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> registerNewUser({
    required String email,
    required String password,
    required String fullName,
    required String dob,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final String uid = credential.user!.uid;

      _currentUser = UserModel(
        uid: uid,
        fullName: fullName.trim(),
        email: email.trim(),
        dob: dob,
        walletBalanceNGN: 0.0,
        createdAt: DateTime.now(),
        isProfileComplete: true,
      );

      await _firestore.collection('users').doc(uid).set(_currentUser!.toJson());

      // Send Firebase Email Verification link
      await credential.user!.sendEmailVerification();

      return credential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('General Backend Error during provisioning: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth SignIn Error: ${e.message}');
      return null;
    } catch (e) {
      print('General sign-in error: $e');
      return null;
    }
  }

  /// STEP 2: Fetch existing user profile data from Firestore DTO
  Future<UserModel?> fetchUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists && doc.data() != null) {
        _currentUser = UserModel.fromJson(doc.data() as Map<String, dynamic>);
        return _currentUser;
      }
      return null;
    } catch (e) {
      print("Error fetching user profile DTO: $e");
      rethrow;
    }
  }

  Future<void> addFundsToWallet(double amount) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User is not authenticated");
    
    await _firestore.collection('users').doc(user.uid).update({
      'walletBalanceNGN': FieldValue.increment(amount),
    });
    
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        walletBalanceNGN: _currentUser!.walletBalanceNGN + amount,
      );
    }
  }

  /// STEP 3: Sign Out Utility
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
  }
}