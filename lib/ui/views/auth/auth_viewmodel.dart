import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import '../../../core/network/api_response.dart';
import '../../../core/network/interceptors.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
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
  String selectedEstateId = '';
  final email = TextEditingController();
  final password = TextEditingController();
  int countdown = 0;
  Timer? _timer;
  bool get isCountdownActive => countdown > 0;
  bool obscure = true;
  String? errorMessage;
  bool codeSent = false;
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    password.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void init() {
  }

  void toggleRemember() {
    remember = !remember;
    rebuildUi();
  }

  void toggleObscure() {
    obscure = !obscure;
    rebuildUi();
  }

  /// **Start the countdown timer for OTP **
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

  Future<void> login() async {
    setBusy(true);
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      // Login success → go to home
      locator<NavigationService>().clearStackAndShow(Routes.homeView);
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else {
        message = e.message ?? 'Login failed';
      }

      locator<SnackbarService>().showSnackbar(message: message);
    } catch (e) {
      locator<SnackbarService>().showSnackbar(message: e.toString());
    } finally {
      setBusy(false);
    }
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
    final resp = await repo.resetPasswordRequest({ "email": email });
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


  Future<void> updateDeviceDetails() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceId = "";
      String deviceType = "";
      String operatingSystem = Platform.operatingSystem;
      // String timeZone = await FlutterTimezone.getLocalTimezone();
      String? pushNotificationToken = '';
      print("pushNotificationToken: $pushNotificationToken");
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
        // pushNotificationToken = await FirebaseMessaging.instance.getAPNSToken();
      }

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;

      // Send to backend
      final response = await repo.updateDeviceId({
        "deviceId": deviceId,
        "deviceType": deviceType,
        "operatingSystem": operatingSystem,
        "pushNotificationToken": pushNotificationToken,
        "appVersion": appVersion,
        // "timeZone": timeZone,
        "language": language,
      });

      if (response.statusCode == 200) {
        print("Device details updated successfully!");
      } else {
        print("Failed to update device details: ${response.data}");
      }
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
