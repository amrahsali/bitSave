import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../components/code_input.dart';
import '../../components/submit_button.dart';
import 'auth_view.dart';
import 'auth_viewmodel.dart';

class OTPVerificationScreen extends StatefulWidget {
  final Function(AuthType) onSwitch;
  final String email;

  const OTPVerificationScreen({
    required this.onSwitch, 
    required this.email,
    Key? key,
  }) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ViewModelBuilder<AuthViewModel>.reactive(
          onViewModelReady: (_) {},
          viewModelBuilder: () => AuthViewModel(),
          builder: (context, model, child) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpaceLarge,
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => widget.onSwitch(AuthType.forgotPassword),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 8.0),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
                verticalSpaceMedium,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/email_sent.svg",
                    ),
                  ],
                ),
                verticalSpaceMedium,
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8),
                  child: Text(
                    "Email Verification",
                    style: GoogleFonts.redHatDisplay(
                      textStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.0),
                  child: Text(
                      "Enter the verification code sent to your email address.",
                      style: GoogleFonts.redHatDisplay(
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      )),
                ),
                verticalSpaceMedium,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: CodeInputWidget(
                    codeController: model.otp,
                    onCompleted: (code) => model.submitOtp(widget.email, code),
                  ),
                ),
                verticalSpaceMedium,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.0),
                  child: SubmitButton(
                    isLoading: model.isBusy,
                    boldText: true,
                    textColor: kcBlackColor,
                    label: "Verify",
                    submit: () {
                      final code = model.otp.text.trim();
                      model.submitOtp(widget.email, code);
                    },
                    color: kcPrimaryColor,
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("Didn't receive the code? ",
                      style: TextStyle(fontSize: 12)),
                  TextButton(
                    onPressed: model.isCountdownActive
                        ? null
                        : () => model.resendOtp(widget.email),
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: Text(
                      model.isCountdownActive
                          ? "Resend in ${model.countdown}s"
                          : "Resend",
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
