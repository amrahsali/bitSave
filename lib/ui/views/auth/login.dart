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
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF432E9D), // purple
                Colors.black,
              ],
            ),
          ),
          width: double.infinity,
          height: double.infinity,
          child: ViewModelBuilder<AuthViewModel>.reactive(
            onViewModelReady: (model) {
            },
            viewModelBuilder: () => AuthViewModel(),
            builder: (context, model, child) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 150),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Login Details',
                          style: TextStyle(
                              color: kcWhiteColor,
                              fontSize: 26,
                              fontWeight: FontWeight.bold),
                        ),
                        // const SizedBox(height: 4),
                        Text(
                          'Enter your login details',
                          style: TextStyle(
                              color: kcWhiteColor.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  verticalSpaceLarge,
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
                  verticalSpaceMedium,
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
      ),
    );
  }
}