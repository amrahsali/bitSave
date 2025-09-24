import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../components/submit_button.dart';
import 'auth_view.dart';
import 'package:animate_do/animate_do.dart';

class UserSelectionScreen extends StatefulWidget {
  final Function(AuthType) onSwitch;

  const UserSelectionScreen({super.key, required this.onSwitch});

  @override
  _UserSelectionScreenState createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController rippleController;
  late Animation<double> rippleAnimation;
  AuthType? selectedUserType;

  @override
  void initState() {
    super.initState();

    // Ripple Animation
    rippleController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    rippleAnimation =
        Tween<double>(begin: 80.0, end: 90.0).animate(rippleController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              rippleController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              rippleController.forward();
            }
          });

    rippleController.forward();
  }

  @override
  void dispose() {
    rippleController.dispose();
    super.dispose();
  }

  void _onCardSelected(AuthType type) {
    setState(() {
      selectedUserType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 50),
              SvgPicture.asset(
                'assets/svg_icons/new_logo.svg',
              ),
              const SizedBox(height: 10),
              FadeInLeft(
                duration: const Duration(milliseconds: 1000),
                child: Text(
                  'Register as ',
                  style: GoogleFonts.redHatDisplay(
                    textStyle: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              FadeInUp(
                duration: const Duration(milliseconds: 1000),
                child: SizedBox(
                  child: Column(
                    children: [
                      UserTypeCard(
                        onTap: () => _onCardSelected(AuthType.login),
                        isSelected: selectedUserType == AuthType.login,
                        icon: Icons.person,
                        text:
                            '',
                        title: "Resident",
                      ),
                    ],
                  ),
                ),
              ),
              FadeInDown(
                duration: const Duration(milliseconds: 1000),
                child: SizedBox(
                  child: Column(
                    children: [
                      verticalSpaceMedium,
                      UserTypeCard(
                        onTap: () => _onCardSelected(AuthType.adminLogin),
                        isSelected: selectedUserType == AuthType.adminLogin,
                        icon: Icons.admin_panel_settings,
                        text:
                            '',
                        title: "Estate manager",
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SubmitButton(
                isLoading: false,
                boldText: true,
                label: "Continue",
                submit: () {
                  if (selectedUserType != null) {
                    widget.onSwitch(
                        selectedUserType!); // Call onSwitch with selected type
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select a user type."),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                color: kcPrimaryColor,
              ),
              verticalSpaceMedium
            ],
          ),
        ),
      ),
    );
  }
}

/// **Animated User Type Card**
class AnimatedUserTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Animation<double> rippleAnimation;

  const AnimatedUserTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.rippleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: rippleAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade200,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: rippleAnimation.value,
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.black87),
              const SizedBox(height: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        );
      },
    );
  }
}

class UserTypeCard extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final String title;
  final bool isSelected;
  final IconData icon;
  const UserTypeCard({
    required this.onTap,
    required this.isSelected,
    required this.text,
    required this.title,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedButton(
        onTap: onTap,
        child: Container(
          width: 270,
          height: 180,
          padding: const EdgeInsets.all(12),
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isSelected ? kcPrimaryColor : kcWhiteColor,
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? kcPrimaryColor.withOpacity(0.4)
                    : Colors.grey.withOpacity(0.2),
                blurRadius: isSelected ? 10 : 7,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: GoogleFonts.redHatDisplay(
                  textStyle:  TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: isSelected ? kcWhiteColor : kcBlackColor,
                  ),
                ),
              ),
              const Spacer(),
              Icon(icon, size: 40, color: isSelected ? kcWhiteColor : kcBlackColor),
              verticalSpaceSmall,
              Text(
                title,
                style: GoogleFonts.redHatDisplay(
                  textStyle:  TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: isSelected ? kcWhiteColor : kcBlackColor,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const AnimatedButton({required this.child, required this.onTap, super.key});

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final Tween<double> _tween = Tween<double>(begin: 1.0, end: 0.95);
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward().then((_) {
          _controller.reverse();
        });
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _tween.animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
