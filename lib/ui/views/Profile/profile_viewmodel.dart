import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/app.locator.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/interceptors.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../state.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ProfileViewModel extends BaseViewModel {
  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool obscure = true;
  bool isChangePasswordLoading = false;
  bool isUpdateProfile = false;

  int profileImageFreshness = 0;
  XFile? pickedImageFile;
  XFile? confirmedImageFile;
  final ImagePicker _picker = ImagePicker();

  void toggleObscure() {
    obscure = !obscure;
    rebuildUi();
  }

  void setConfirmedImageFile(XFile file) {
    confirmedImageFile = file;
    notifyListeners();
  }

  void clearConfirmedImageFile() {
    confirmedImageFile = null;
    notifyListeners();
  }

  void clearPickedImageFile() {
    pickedImageFile = null;
    notifyListeners();
  }

  Future<void> goToAbout(String url) async {
    final Uri toLaunch =
    Uri(scheme: 'https', host: 'www.estate360hub.com', path: '/');

    if (!await launchUrl(toLaunch, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> changePassword(context) async {
    isChangePasswordLoading = true;
    try {
      ApiResponse res =
      await repo.changePassword(
        {
          "currentPassword": oldPassword.text,
          "newPassword": newPassword.text,

        },
      );

      if (res.statusCode == 200) {
        locator<SnackbarService>().showSnackbar(
          message: 'Change Password successful',
          duration: const Duration(seconds: 2),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      locator<SnackbarService>().showSnackbar(
        message: "Unable to update password: $e",
        duration: const Duration(seconds: 2),
      );
    }
    finally{
      setBusy(false);
    }
    notifyListeners();
  }


  Future<void> getProfile() async {
  }

  Future<XFile?> pickImageFrom(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source, 
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (file != null) {
        pickedImageFile = file;
        notifyListeners();
      }
      return file;
    } catch (e) {
      debugPrint('Error picking image: $e');
      locator<SnackbarService>().showSnackbar(message: 'Error Selecting image: ${e.toString()}');
      return null;
    }
  }

  Future<bool> uploadProfileImageMultipart(File imageFile, int userId) async {
    try {
      setBusy(true);

      final filename = imageFile.path.split(Platform.pathSeparator).last;
      final multipart = await MultipartFile.fromFile(imageFile.path, filename: filename);

      final req = {
        'image': multipart,
      };

      final ApiResponse res = await repo.updateProfilePictureMultipart(req, userId.toString());

      if (res.statusCode == 200 || res.statusCode == 201) {
        await getProfile();
        return true;
      } else {
        String message = 'Failed to upload profile picture';
        if (res.data != null) {
          try {
            final d = res.data;
            if (d is Map && d['message'] != null) {
              message = d['message'].toString();
            } else if (d is String) {
              message = d;
            }
          } catch (e) {
            debugPrint('Error parsing error message: $e');
          }
        }
        locator<SnackbarService>().showSnackbar(message: message);
        return false;
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      locator<SnackbarService>().showSnackbar(message: 'Upload error: ${e.toString()}');
      return false;
    } finally {
      setBusy(false);
    }
  }


}




