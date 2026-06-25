import 'package:bitSave/ui/views/Profile/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 110.0, top: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Invite and earn  50 SATS",
                  style: GoogleFonts.redHatDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 60),
                // Custom Graphic Collage Section
                Center(
                  child: SizedBox(
                    height: 160,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Left Bitcoin Icon Outline Overlay
                        Positioned(
                          left: 0,
                          child: Transform.rotate(
                            angle: -0.1,
                            child: const Icon(
                              Icons.currency_bitcoin,
                              size: 100,
                              color: Color(0xFF6B4EE6),
                            ),
                          ),
                        ),
                        // Right Bitcoin Icon Outline Overlay
                        Positioned(
                          right: 10,
                          child: Transform.rotate(
                            angle: 0.1,
                            child: const Icon(
                              Icons.currency_bitcoin,
                              size: 90,
                              color: Color(0xFF6B4EE6),
                            ),
                          ),
                        ),
                        // Left Avatar (Male)
                        Positioned(
                          left: 45,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[800]!, width: 3),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/default_user.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        // Paper Airplane / Send Graphic
                        Positioned(
                          child: Transform.rotate(
                            angle: -0.2,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.yellow.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.send,
                                color: Colors.yellowAccent,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                        // Right Avatar (Female)
                        Positioned(
                          right: 60,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[800]!, width: 2),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/lady.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                // Reward Details Text
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.redHatDisplay(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                    children: const [
                      TextSpan(text: "Earn "),
                      TextSpan(
                        text: "50 SATS",
                        style: TextStyle(color: Color(0xFF6B4EE6), fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: " for every 3 friends who transfer over 200 SATS. They'll get a fee-free transfer up to "),
                      TextSpan(
                        text: "500SATS",
                        style: TextStyle(color: Color(0xFF6B4EE6), fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: "."),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                // Buttons
                _buildActionCard("Invite a friend", model.copyfriendsLink),
                const SizedBox(height: 16),
                _buildActionCard("Share via an app", model.shareViaApp),
                const SizedBox(height: 16),
                _buildActionCard("Copy the invite link", model.copyInviteLink),
                const SizedBox(height: 16),
                _buildActionCard("Log Out", model.logout, isDestructive: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, Function onTap, {bool isDestructive = false}) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1A22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDestructive
                ? Colors.redAccent.withValues(alpha: 0.5)
                : const Color(0xFF6B4EE6).withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: GoogleFonts.redHatDisplay(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDestructive ? Colors.redAccent : Colors.white,
          ),
        ),
      ),
    );
  }
}