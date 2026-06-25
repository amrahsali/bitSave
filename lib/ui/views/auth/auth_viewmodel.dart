// Path: lib/ui/views/auth/auth_viewmodel.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/data/repositories/repository.dart';
import '../../../services/authentication_service.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart'; // need Fixing of typo from 'local_stotage.dart' to [local_storage.dart]
import '../../../state.dart';
import 'auth_view.dart';
import './reset_password/reset_password_view.dart';

enum RegistrationResult { success, failure }

class AuthViewModel extends BaseViewModel {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final firstname = TextEditingController();
  final lastname = TextEditingController();
  final phone = TextEditingController();
  final estateController = TextEditingController();
  final apartmentController = TextEditingController();
  final cPassword = TextEditingController();
  bool remember = false;
  late PhoneNumber phoneNumber;
  final otp = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  int countdown = 0;
  Timer? _timer;
  bool get isCountdownActive => countdown > 0;
  bool obscure = true;
  String? errorMessage;
  bool codeSent = false;
  
  final AuthenticationService _authService = locator<AuthenticationService>();
  final Repository _repo = locator<Repository>();

  @override
  void dispose() {
    firstname.dispose();
    lastname.dispose();
    phone.dispose();
    estateController.dispose();
    apartmentController.dispose();
    cPassword.dispose();
    otp.dispose();
    email.dispose();
    password.dispose();
    _timer?.cancel();
    _verificationTimer?.cancel();
    super.dispose();
  }

  void init() {}

  void toggleRemember() {
    remember = !remember;
    rebuildUi();
  }

  void toggleObscure() {
    obscure = !obscure;
    rebuildUi();
  }

  void startCountdown() {
    countdown = 30;
    notifyListeners();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        countdown--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  /// Registers a new user with Firebase Auth and switches to the strict verification screen.
  Future<void> register({
    required String fullName,
    required String dob,
    required VoidCallback onSuccess,
  }) async {
    setBusy(true);
    try {
      if (email.text.trim().isEmpty || password.text.trim().isEmpty) {
        locator<SnackbarService>().showSnackbar(
          message: 'Please fill in all required fields.',
        );
        return;
      }

      // 1. Invokes registration (AuthService internally pushes to Firestore and shoots the email verification)
      final credential = await _authService.registerNewUser(
        email: email.text.trim(),
        password: password.text.trim(),
        fullName: fullName,
        dob: dob,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        locator<SnackbarService>().showSnackbar(
          message: 'Registration failed. Please try again.',
        );
        return;
      }

      await firebaseUser.updateDisplayName(fullName);

      // 2. Temporarily track data, but keep global state unverified until email confirmation
      profile.value = User.fromFirebase(firebaseUser);
      
      // 3. Trigger screen routing callback securely passed from the view layer
      onSuccess();
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account with this email already exists.';
          break;
        case 'invalid-email':
          message = 'That email address looks invalid.';
          break;
        case 'weak-password':
          message = 'Your password is too weak. Use at least 8 characters.';
          break;
        default:
          message = 'Registration failed. Please try again.';
      }
      locator<SnackbarService>().showSnackbar(message: message);
    } catch (e) {
      locator<SnackbarService>().showSnackbar(
        message: 'Something went wrong. Please try again later.',
      );
    } finally {
      setBusy(false);
    }
  }

  /// Logs a user in and strictly enforces validation check blocks
  Future<void> login() async {
    setBusy(true);
    try {
      if (email.text.trim().isEmpty || password.text.trim().isEmpty) {
        locator<SnackbarService>().showSnackbar(
          message: "Please enter both your email and password to continue.",
        );
        return;
      }

      final credential = await _authService.signIn(
        email.text.trim(),
        password.text.trim(),
      );

      final firebaseUser = credential?.user;
      if (firebaseUser == null) {
        locator<SnackbarService>().showSnackbar(
          message: 'Login failed. Please check your credentials.',
        );
        return;
      }

      // STRICT GATE ENFORCEMENT: Is the incoming session validated via email link?
      if (!firebaseUser.emailVerified) {
        locator<SnackbarService>().showSnackbar(
          message: "Your email is not verified yet. Please check your inbox.",
        );
        
        // Push unverified user directly to the locked tracking view screen
        locator<NavigationService>().clearStackAndShow(
          Routes.authView,
          arguments: const AuthViewArguments(authType: AuthType.emailVerification),
        ); 
        return;
      }

      // If user is cleared via email verification, parse authorization credentials normally
      final loggedInUser = User.fromFirebase(firebaseUser);

      profile.value = loggedInUser;
      userLoggedIn.value = true;

      await locator<LocalStorage>().save(
        LocalStorageDir.authUser,
        jsonEncode(profile.value.toJson()),
      );

      // Pull metadata modifications (tokens, platform architecture versions)
      updateDeviceDetails();

      locator<NavigationService>().clearStackAndShow(Routes.homeView);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-credential': // Catches unified modern auth errors
          message = "We couldn't find an account matching those credentials.";
          break;
        case 'wrong-password':
          message = "The password you entered is incorrect.";
          break;
        case 'invalid-email':
          message = "That email address looks invalid. Please try again.";
          break;
        case 'user-disabled':
          message = "This account has been disabled. Contact support for help.";
          break;
        default:
          message = "Login failed. Please check your details and try again.";
      }
      locator<SnackbarService>().showSnackbar(message: message);
    } catch (e) {
      locator<SnackbarService>().showSnackbar(
        message: "Something went wrong. Please try again later.",
      );
    } finally {
      setBusy(false);
    }
  }

  Timer? _verificationTimer;

  void startVerificationCheckTimer(VoidCallback onVerified) {
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      final user = _authService.firebaseAuth.currentUser;
      if (user != null) {
        await user.reload();
        final updatedUser = _authService.firebaseAuth.currentUser;
        if (updatedUser != null && updatedUser.emailVerified) {
          timer.cancel();
          // Update profile and log in
          final loggedInUser = User.fromFirebase(updatedUser);
          profile.value = loggedInUser;
          userLoggedIn.value = true;

          await locator<LocalStorage>().save(
            LocalStorageDir.authUser,
            jsonEncode(profile.value.toJson()),
          );

          updateDeviceDetails();
          onVerified();
        }
      }
    });
  }

  void cancelVerificationTimer() {
    _verificationTimer?.cancel();
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = _authService.firebaseAuth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        locator<SnackbarService>().showSnackbar(
          message: "A new verification link has been sent to your email.",
        );
      }
    } catch (e) {
      locator<SnackbarService>().showSnackbar(
        message: "Failed to send verification link: $e",
      );
    }
  }

  Future<bool> checkEmailVerificationStatus() async {
    setBusy(true);
    try {
      final user = _authService.firebaseAuth.currentUser;
      if (user != null) {
        await user.reload();
        final updatedUser = _authService.firebaseAuth.currentUser;
        if (updatedUser != null && updatedUser.emailVerified) {
          // Update user profile status
          final loggedInUser = User.fromFirebase(updatedUser);
          profile.value = loggedInUser;
          userLoggedIn.value = true;

          await locator<LocalStorage>().save(
            LocalStorageDir.authUser,
            jsonEncode(profile.value.toJson()),
          );

          updateDeviceDetails();
          setBusy(false);
          return true;
        }
      }
    } catch (e) {
      debugPrint("Error checking email verification: $e");
    }
    setBusy(false);
    return false;
  }

  Future<void> submitOtp(String email, String code) async {
    locator<NavigationService>().navigateToView(
      ResetPasswordView(email: email, code: code),
    );
  }

  Future<void> resendOtp(String email) async {
    if (isCountdownActive) return;

    final startTime = DateTime.now();
    setBusy(true);

    try {
      final resp = await _repo.resetPasswordRequest({"email": email});
      final elapsed = DateTime.now().difference(startTime);
      debugPrint("Resend OTP latency: ${elapsed.inMilliseconds}ms");

      if (resp.statusCode == 200) {
        startCountdown();
      } else {
        locator<SnackbarService>().showSnackbar(
          message: resp.data["message"] ?? "Failed to resend OTP",
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      debugPrint("Error resending OTP: $e");
      locator<SnackbarService>().showSnackbar(
        message: "Error sending OTP: $e",
        duration: const Duration(seconds: 2),
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> createPin(String pin, VoidCallback onSuccess) async {
    setBusy(true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      onSuccess();
    } catch (e) {
      locator<SnackbarService>().showSnackbar(message: "Failed to create PIN.");
    } finally {
      setBusy(false);
    }
  }

  Future<void> updateDeviceDetails() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceId = "";
      String deviceType = "";
      String operatingSystem = Platform.operatingSystem;
      String? pushNotificationToken = '';
      String appVersion = "";
      String language = Platform.localeName;

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        deviceType = androidInfo.model;
        pushNotificationToken = await FirebaseMessaging.instance.getToken();
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? "Unknown";
        deviceType = iosInfo.utsname.machine ?? "iOS Device";
        pushNotificationToken = await FirebaseMessaging.instance.getToken();
      }

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;

      await _repo.updateDeviceId({
        "deviceId": deviceId,
        "deviceType": deviceType,
        "operatingSystem": operatingSystem,
        "pushNotificationToken": pushNotificationToken,
        "appVersion": appVersion,
        "language": language,
      });
    } catch (e, stackTrace) {
      print("Error updating device details: $e");
      print(stackTrace);
    }
  }

  void resetForgotPasswordState() {
    codeSent = false;
    errorMessage = null;
    notifyListeners();
  }
}