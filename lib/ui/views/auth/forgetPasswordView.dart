import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_colors.dart';
import '../../components/text_field_widget.dart';
import 'auth_viewmodel.dart';
import 'auth_view.dart';

class ForgotPasswordView extends ViewModelWidget<AuthViewModel> {
  final void Function(AuthType, {String? email}) onSwitch;
  const ForgotPasswordView({required this.onSwitch, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, AuthViewModel model) {
    debugPrint('ForgotPasswordView.build called — model: ${model.hashCode}');
    return Padding(
      padding: const EdgeInsets.all(24),
      // child: Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     TextFieldWidget(
      //       hint: 'Enter your email',
      //       controller: model.emailController,
      //       inputType: TextInputType.emailAddress,
      //       onChanged: (_) {},
      //     ),
      //     const SizedBox(height: 20),
      //     ElevatedButton(
      //       style: ElevatedButton.styleFrom(
      //         backgroundColor: kcPrimaryColor,
      //         foregroundColor: kcWhiteColor,
      //       ),
      //       onPressed: () async {
      //         final success = await model.resetForgottenPassword();
      //
      //         if (success) {
      //           await Future.delayed(const Duration(seconds: 2));
      //           onSwitch(
      //             AuthType.otpVerify,
      //             email: model.emailController.text.trim(),
      //           );
      //         }
      //       },
      //       child: Text(model.isBusy ? 'Sending…' : 'Send Reset Link'),
      //     ),
      //     const SizedBox(height: 12),
      //     TextButton(
      //       style: TextButton.styleFrom(
      //         foregroundColor: kcPrimaryColor,
      //       ),
      //       onPressed: () => onSwitch(AuthType.login),
      //       child: const Text('← Back to Login'),
      //     ),
      //   ],
      // ),
    );

  }


}