
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../components/text_field_widget.dart';
import '../../../components/submit_button.dart';
import '../../../common/app_colors.dart';
import 'reset_password_viewmodel.dart';
// import '../auth_view.dart';

class ResetPasswordView extends StackedView<ResetPasswordViewModel> {
  final String email;
  final String code;

  const ResetPasswordView({
    required this.email,
    required this.code,
    super.key,
  });


  @override
  ResetPasswordViewModel viewModelBuilder(BuildContext context) =>
    ResetPasswordViewModel(email: email, code: code);

  @override
  Widget builder(
    BuildContext context,
    ResetPasswordViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFieldWidget(
              hint: 'New Password',
              controller: viewModel.passwordController,
              obscureText: !viewModel.passwordVisible,
              suffix: IconButton(
                icon: Icon(
                  viewModel.passwordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: viewModel.togglePasswordVisibility,
              ),
            ),

            const SizedBox(height: 20),

            SubmitButton(
              isLoading: viewModel.isBusy,
              label: 'Reset',
              color: kcPrimaryColor,
              textColor: Colors.white,
              boldText: true,
              submit: () => viewModel.resetPassword(
                viewModel.email,
                viewModel.code,
                viewModel.passwordController.text.trim(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


