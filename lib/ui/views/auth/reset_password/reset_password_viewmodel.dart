import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../../app/app.locator.dart';
import '../../../../app/app.router.dart';
import '../../../../core/data/repositories/repository.dart';
import '../../../../ui/views/auth/auth_view.dart';
import 'package:stacked_services/stacked_services.dart';

class ResetPasswordViewModel extends BaseViewModel {
  final _repo = locator<Repository>();
  final _snackbar = locator<SnackbarService>();
  final _nav = locator<NavigationService>();

  final String email, code;
  ResetPasswordViewModel({ required this.email, required this.code });

  final TextEditingController passwordController = TextEditingController();
  bool passwordVisible = false;

  void togglePasswordVisibility() {
    passwordVisible = !passwordVisible;
    notifyListeners();
  }

Future<bool> resetPassword(String email, String code, String newPassword) async {
  setBusy(true);
  try {
    final response = await _repo.verifyPasswordResetCode(
      email: email,
      code: code,
      newPassword: newPassword,
    );

    if (response.statusCode == 200) {
      _snackbar.showSnackbar(
        message: 'Password reset successful!',
        duration: const Duration(seconds: 2),
      );

      setBusy(false);

       _nav.replaceWithAuthView(
        authType: AuthType.login,
        initialIndex: 0,
      );

      return true;
    } else {
      _snackbar.showSnackbar(
        message: response.data['message'] ?? 'Reset failed, Please try again later.',
      );
    }
  } catch (e) {
    _snackbar.showSnackbar(
      message: 'Error resetting password: $e',
    );
  } finally {
    setBusy(false);
  }

  return false;
}


  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }
}

