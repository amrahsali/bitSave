import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_colors.dart';
import '../../components/code_input.dart';
import 'auth_view.dart';
import 'auth_viewmodel.dart';

class CreatePinScreen extends StatefulWidget {
  final Function(AuthType) onSwitch;

  const CreatePinScreen({
    required this.onSwitch,
    Key? key,
  }) : super(key: key);

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AuthViewModel>.reactive(
      viewModelBuilder: () => AuthViewModel(),
      builder: (context, model, child) {
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
                              // Going back to email verification or wherever appropriate
                              onTap: () => widget.onSwitch(AuthType.otpVerify),
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
                                  value: 1.0, // 100% progress
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
                          'Create a login pin',
                          style: GoogleFonts.redHatDisplay(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "You'll be able to login to bitSave using the following passcode",
                          style: GoogleFonts.redHatDisplay(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 60),

                        // ── PIN Input Boxes ───────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: CodeInputWidget(
                            codeController: _pinController,
                            onCompleted: (pin) {
                              // Auto-navigate or verify PIN here
                              model.createPin(pin, () {
                                // Once PIN is successfully created/stored, navigate to dashboard
                                // Example:
                                // locator<NavigationService>().clearStackAndShow(Routes.dashboardView);
                              });
                            },
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
