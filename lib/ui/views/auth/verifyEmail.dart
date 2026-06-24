import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../components/code_input.dart';
import '../../components/submit_button.dart';
import 'auth_view.dart';
import 'auth_viewmodel.dart';

class EmailVerificationView extends StatefulWidget {
  const EmailVerificationView({Key? key}) : super(key: key);

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AuthViewModel>.reactive(
      viewModelBuilder: () => AuthViewModel(),
      builder: (context, model, child) {
       
        const displayEmail = "your email address";
        return Scaffold(
          backgroundColor: const Color(0xFF0F0A1E),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF3B2490), // deep purple top
                  Color(0xFF0F0A1E), // near-black bottom
                ],
                stops: [0.0, 0.4],
              ),
            ),
            child: SafeArea(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // ── Header row: back arrow + progress bar ──────────
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Clear stack back to the main login/auth route
                                locator<NavigationService>().clearStackAndShow(Routes.authView);
                              },
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: 0.8, // 80% progress
                                  minHeight: 5,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.2),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // ── Title ──────────────────────────────────────────
                        Text(
                          'Verify your Email',
                          style: GoogleFonts.redHatDisplay(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please enter the code sent to $displayEmail',
                          style: GoogleFonts.redHatDisplay(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 60),

                        // ── Code Input Boxes ───────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: CodeInputWidget(
                            codeController: model.otp,
                            onCompleted: (code) {
                              model.submitOtp(displayEmail, code);
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 16),

                        // ── Resend Code ────────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Didn't get the code? ",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.55),
                              ),
                            ),
                            GestureDetector(
                              onTap: model.isCountdownActive
                                  ? null
                                  : () => model.resendOtp(displayEmail),
                              child: Text(
                                model.isCountdownActive
                                    ? "Resend in ${model.countdown}s"
                                    : "Resend it.",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B4EE6), 
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // ── Continue Button ────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: model.isBusy 
                                ? null
                                : () {
                                    final code = model.otp.text.trim();
                                    if (code.length == 6) {
                                      model.submitOtp(displayEmail, code);
                                    } else {
                                       locator<SnackbarService>().showSnackbar(
                                         message: "Please enter the full 6-digit code."
                                       );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B4EE6), // Swapped out gray for your layout's active purple brand color
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  const Color(0xFF6B4EE6).withValues(alpha: 0.6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: model.isBusy
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Continue',
                                    style: GoogleFonts.redHatDisplay(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}