import 'package:bitSave/state.dart';
import 'package:bitSave/ui/common/app_colors.dart';
import 'package:bitSave/ui/views/Profile/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:bitSave/state.dart';
import '../../common/ui_helpers.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(),
      builder: (context, model, child) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        verticalSpaceMedium,
                        _buildInviteCard(model, kcPrimaryColor),
                        verticalSpaceMedium,
                        _buildInviteOptions(model, kcPrimaryColor),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Invite and earn  50 SATS",
            style: GoogleFonts.redHatDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? kcWhiteColor : kcBlackColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteCard(ProfileViewModel model, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Invite and earn 50 SATS",
            style: GoogleFonts.redHatDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Earn 50 SATS for every 3 friends who transfer over 200 SATS. They'll get a fee-free transfer up to 500SATS.",
            style: GoogleFonts.redHatDisplay(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInviteOptions(ProfileViewModel model, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Share via",
          style: GoogleFonts.redHatDisplay(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor,
          ),
        ),
        verticalSpaceSmall,
        _buildInviteOption(
          icon: Icons.people_alt_outlined,
          title: "Invite friends",
          subtitle: "Copy and share your personal invite link",
          onTap: model.copyfriendsLink,
          primaryColor: primaryColor,
        ),
verticalSpaceSmall,
        // Share via app option
        _buildInviteOption(
          icon: Icons.share_outlined,
          title: "Share via an app",
          subtitle: "Share through social media or messaging apps",
          onTap: model.shareViaApp,
          primaryColor: primaryColor,
        ),
        verticalSpaceSmall,
        // Copy invite link option
        _buildInviteOption(
          icon: Icons.link_outlined,
          title: "Copy the invite link",
          subtitle: "Copy and share your personal invite link",
          onTap: model.copyInviteLink,
          primaryColor: primaryColor,
        ),



      ],
    );
  }

  Widget _buildInviteOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Function onTap,
    required Color primaryColor,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: uiMode.value == AppUiModes.dark ? kcDarkGreyColor : kcWhiteColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.redHatDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.redHatDisplay(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  }