import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthenticationService {
  // Initialize the Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Track the currently logged-in user model in memory
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  
  /// STREAM: Listens to the authentication state changes.
  /// This lets the app instantly know if a user logs out or logs in.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// STEP 1: Register User with Email and basic 
  /// Because Firebase Auth requires a password to create an account, for the MVP
  /// we can temporarily pass a placeholder password or combine this step with a later profile completion step where the user sets their password.  
  Future<UserCredential?> registerNewUser({
    required String email,
    required String password,
    required String fullName,
    required String dob,
  }) async {
    try {
      // 1. Create the credential inside Firebase Authentication
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final String uid = credential.user!.uid;

      // 2. Wrapping the form data into our structured DTO
      _currentUser = UserModel(
        uid: uid,
        fullName: fullName.trim(),
        email: email.trim(),
        dob: dob,
        walletBalanceNGN: 0.0, // New users start with 0 Naira
        createdAt: DateTime.now(),
        isProfileComplete: true,
      );

      // 3. Provision the profile inside Cloud Firestore using the DTO
      await _firestore
          .collection('users')
          .doc(uid)
          .set(_currentUser!.toJson());

      return credential;
    } on FirebaseAuthException catch (e) {
      // Catch specific Firebase issues (e.g., email-already-in-use)
      print("Firebase Auth Error: ${e.message}");
      return null;
    } catch (e) {
      print("General Backend Error during provisioning: $e");
      return null;
    }
  }

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth SignIn Error: ${e.message}");
      return null;
    } catch (e) {
      print("General sign-in error: $e");
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

  /// STEP 3: Sign Out Utility
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
  }
}