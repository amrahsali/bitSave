import 'package:estate360Security/ui/common/app_colors.dart';
import 'package:estate360Security/ui/views/auth/registration.dart';
import 'package:estate360Security/ui/views/auth/user_selection.dart';
import 'package:estate360Security/ui/views/auth/verifyEmail.dart';
import 'package:estate360Security/ui/views/auth/forgetPasswordView.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stacked/stacked.dart';
import '../../../state.dart';
import 'auth_viewmodel.dart';
import 'login.dart';

enum AuthType { selection, login, adminLogin, register, otpVerify, forgotPassword }

class AuthView extends StatefulWidget {
  final AuthType authType;
  const AuthView({Key? key, required this.authType}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AuthViewState();
  }
}

class _AuthViewState extends State<AuthView> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AuthType currentAuthType;
  String emailForOtp = "";
  String password = "";

  @override
  void initState() {
    super.initState();
    currentAuthType = widget.authType;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void updateAuthPage(AuthType type, {String? email}) {
    setState(() {
      currentAuthType = type;
      _animationController.forward(from: 0);
    });

    if (type == AuthType.otpVerify && email != null) {
      emailForOtp = email;
    }
  }


  String getBackgroundImage() {
    switch (currentAuthType) {
      case AuthType.adminLogin:
        return "assets/svg_icons/new_logo.svg";
      case AuthType.login:
        return "assets/svg_icons/new_logo.svg";
      case AuthType.register:
        return "assets/svg_icons/new_logo.svg";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ViewModelBuilder<AuthViewModel>.reactive(
        onViewModelReady: (model) {},
        viewModelBuilder: () => AuthViewModel(),
        builder: (context, model, child) => SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 80), // Adds spacing from the top
              SvgPicture.asset(
                getBackgroundImage(),
                height: 60, // Reduced logo height
                width: 120, // Reduced logo width
              ),
              SizedBox(height: 20), // Adds spacing below the logo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: MediaQuery.of(context).size.height - 140, // Adjusted for screen height
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: getAuthScreen(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getAuthScreen() {
    switch (currentAuthType) {
      case AuthType.selection:
        return UserSelectionScreen(onSwitch: updateAuthPage);
      case AuthType.login:
        return LoginScreen(onSwitch: updateAuthPage, isAdmin: false);
      case AuthType.adminLogin:
        return LoginScreen(onSwitch: updateAuthPage, isAdmin: true);
      case AuthType.register:
        return RegisterScreen(onSwitch: updateAuthPage);
      case AuthType.otpVerify:
        return OTPVerificationScreen(onSwitch: updateAuthPage, email: emailForOtp);
      case AuthType.forgotPassword:
        return ForgotPasswordView(onSwitch: updateAuthPage);
    }
  }
}
