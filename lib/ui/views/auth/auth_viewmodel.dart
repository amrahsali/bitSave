import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:estate360Security/ui/views/auth/verifyEmail.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../core/data/models/estate_model.dart';
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
  final email = TextEditingController();
  final phone = TextEditingController();
  final estateController = TextEditingController();
  final apartmentController = TextEditingController();
  final password = TextEditingController();
  final cPassword = TextEditingController();
  bool obscure = true;
  bool remember = false;
  late PhoneNumber phoneNumber;
  final otp = TextEditingController();
  List<Estate> estates = [];
  String selectedEstateId = '';

  int countdown = 0;
  Timer? _timer;
  bool get isCountdownActive => countdown > 0;

  String? errorMessage;
  bool codeSent = false;

  @override
  void dispose() {
    password.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void init() {
    getEstates();
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

  // void login() async {
  //   setBusy(true);
  //
  //   try {
  //     ApiResponse res = await repo.login({
  //       "username": email.text,
  //       "password": password.text,
  //       "isWebLogin": false
  //     });
  //
  //     if (res.statusCode == 200) {
  //       print("User login successful. Navigating to homeView...");
  //
  //       userLoggedIn.value = true;
  //
  //       // ✅ Extract tokens correctly
  //       final String accessToken = res.data['data']['accessToken'] ?? '';
  //       final String refreshToken = res.data['data']['refreshToken'] ?? '';
  //
  //       final userData = res.data['data']['user'];
  //       profile.value = User.fromJson(Map<String, dynamic>.from(userData));
  //
  //       if ((profile.value.roles ?? [])
  //           .any((r) => r.name?.toUpperCase() != 'ESTATE_SECURITY')) {
  //         locator<SnackbarService>().showSnackbar(
  //           message:
  //               "Your account is not authorized to login as a security guard.",
  //           duration: const Duration(seconds: 2),
  //         );
  //         setBusy(false);
  //         return;
  //       }
  //       if(profile.value.estates == null|| profile.value.estates!.isEmpty) {
  //         locator<SnackbarService>().showSnackbar(
  //           message: "You have not been assigned to any estate, please contact your estate manager.",
  //           duration: const Duration(seconds: 2),
  //         );
  //         setBusy(false);
  //         return;
  //       }
  //
  //       locator<LocalStorage>().save(LocalStorageDir.authToken, accessToken);
  //       locator<LocalStorage>()
  //           .save(LocalStorageDir.authRefreshToken, refreshToken);
  //       locator<LocalStorage>()
  //           .save(LocalStorageDir.authUser, jsonEncode(userData));
  //       locator<LocalStorage>().save(LocalStorageDir.remember, remember);
  //
  //       locator<SnackbarService>().showSnackbar(
  //         message: 'Login successful',
  //         duration: const Duration(seconds: 2),
  //       );
  //
  //       await updateDeviceDetails();
  //       // ✅ Navigate to HomeView
  //       locator<NavigationService>().clearStackAndShow(Routes.homeView);
  //       notifyListeners();
  //     } else {
  //       setBusy(false);
  //       String errorMessage = "Internal server error, try again later";
  //
  //       if (res.data["message"] is String) {
  //         errorMessage = res.data["message"];
  //       } else if (res.data["message"] is List<String>) {
  //         errorMessage = res.data["message"].join('\n');
  //       }
  //
  //       locator<SnackbarService>().showSnackbar(
  //         message: errorMessage,
  //         duration: const Duration(seconds: 3),
  //       );
  //     }
  //   } catch (e, stackTrace) {
  //     locator<SnackbarService>().showSnackbar(
  //       message: "Incorrect Username or Password",
  //       duration: const Duration(seconds: 3),
  //     );
  //     print("Error: $stackTrace");
  //     setBusy(false);
  //   }
  //
  //   setBusy(false);
  // }
  void login() async {

        locator<NavigationService>().clearStackAndShow(Routes.homeView);
        notifyListeners();
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


  Future<void> getEstates() async {
    setBusy(true);
    try {
      ApiResponse res = await repo.getEstates();
      if (res.statusCode == 200) {
        print('estates response: ${res.data}');
        estates = List<Estate>.from((res.data["data"]["items"] as List)
            .map((e) => Estate.fromJson(e as Map<String, dynamic>)));
        notifyListeners();
      } else {
        locator<SnackbarService>().showSnackbar(message: res.data["message"]);
      }
    } catch (e) {
      debugPrint(e.toString());
      locator<SnackbarService>()
          .showSnackbar(message: "Internal server error, $e");
    }
    setBusy(false);
  }

  Future<void> updateDeviceDetails() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceId = "";
      String deviceType = "";
      String operatingSystem = Platform.operatingSystem;
      String timeZone = await FlutterTimezone.getLocalTimezone();
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
        "timeZone": timeZone,
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
