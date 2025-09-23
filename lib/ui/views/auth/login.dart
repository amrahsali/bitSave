import 'package:estate360Security/ui/views/auth/verifyEmail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../components/submit_button.dart';
import '../../components/text_field_widget.dart';
import 'auth_view.dart';
import 'auth_viewmodel.dart';
import 'forgetPasswordView.dart';


/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///



class LoginScreen extends  StatefulWidget {
  final Function(AuthType, {String? email}) onSwitch;
  final bool isAdmin;

  const LoginScreen({required this.onSwitch, required this.isAdmin});


  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Scaffold(
        body: ViewModelBuilder<AuthViewModel>.reactive(
          onViewModelReady: (model) {
          },
          viewModelBuilder: () => AuthViewModel(),
          builder: (context, model, child) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: kcPrimaryColor, width: 2),
                      borderRadius:
                      BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage('assets/images/header-image.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'BitSave Login',
                          style: TextStyle(
                              color: kcWhiteColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                verticalSpaceSmall,
                TextFieldWidget(

                  hint: "Email",
                  controller: model.email,
                ),
                verticalSpaceMedium,
                TextFieldWidget(
                  hint: "Password",
                  controller: model.password,
                  obscureText: model.obscure,
                  suffix: InkWell(
                    onTap: () {
                      model.toggleObscure();
                    },
                    child: Icon(
                        model.obscure ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
                verticalSpaceTiny,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: model.toggleRemember,
                      child: Row(
                        children: [
                          Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                  color: model.remember
                                      ? kcSecondaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: model.remember
                                          ? Colors.transparent
                                          : kcPrimaryColor)),
                              child: model.remember
                                  ? const Center(
                                child: Icon(
                                  Icons.check,
                                  color: kcWhiteColor,
                                  size: 14,
                                ),
                              )
                                  : const SizedBox()),
                          const Text(
                            "Remember Me",
                            style: TextStyle(
                                fontSize: 14, decoration: TextDecoration.underline),
                          )
                        ],
                      ),
                    ),
                    horizontalSpaceSmall,
                    InkWell(
                      // onTap: () => widget.onSwitch(AuthType.forgotPassword),
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(
                          fontSize: 16,
                          color: kcPrimaryColor,
                        ),
                      ),
                    )
                  ],
                ),
                verticalSpaceLarge,
                SubmitButton(
                  isLoading: model.isBusy,
                  boldText: true,
                  textColor: kcWhiteColor,
                  label: "Login",
                  submit: () {
                     model.login();
                  },
                  color: kcPrimaryColor,
                ),
                verticalSpaceMedium,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
