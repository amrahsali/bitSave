import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/app.locator.dart';

class ProfileViewModel extends BaseViewModel {
  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool obscure = true;
  bool isChangePasswordLoading = false;
  bool isUpdateProfile = false;

  int profileImageFreshness = 0;
  final _snackbarService = locator<SnackbarService>();

  int friendsInvited = 0;
  int satsEarned = 0;


  void toggleObscure() {
    obscure = !obscure;
    rebuildUi();
  }

  void shareViaWhatsApp() async {
    final message = "🚀 Join me on BitSave! \n\nEarn SATS together! Use my invite link: https://bitsave.app/invite/karima123 \n\nGet fee-free transfers up to 500 SATS!";
    final url = "whatsapp://send?text=${Uri.encodeComponent(message)}";

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
        _trackShare("WhatsApp");
      } else {
        _copyToClipboard(message, "WhatsApp message");
      }
    } catch (e) {
      _copyToClipboard(message, "WhatsApp message");
    }
  }

  void shareViaTelegram() async {
    final message = "🚀 Join me on BitSave! \n\nEarn SATS together! Use my invite link: https://bitsave.app/invite/karima123 \n\nGet fee-free transfers up to 500 SATS!";
    final url = "tg://msg?text=${Uri.encodeComponent(message)}";

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
        _trackShare("Telegram");
      } else {
        _copyToClipboard(message, "Telegram message");
      }
    } catch (e) {
      _copyToClipboard(message, "Telegram message");
    }
  }

  void shareViaEmail() async {
    final subject = "🌟 Join me on BitSave and Earn SATS!";
    final body = """Hi there!

I'm using BitSave and thought you might love it too! 

🎁 You'll get:
• Fee-free transfers up to 500 SATS
• Easy savings and investment options
• Secure and reliable platform

Use my invite link to join:
https://bitsave.app/invite/karima123

Let's earn SATS together! 🚀""";

    final url = "mailto:?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}";

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
        _trackShare("Email");
      } else {
        _copyToClipboard("$subject\n\n$body", "email content");
      }
    } catch (e) {
      _copyToClipboard("$subject\n\n$body", "email content");
    }
  }

  void shareViaOther() {
    final message = "🚀 Join me on BitSave and earn SATS! Use my invite link: https://bitsave.app/invite/karima123 - Get fee-free transfers up to 500 SATS!";
    _copyToClipboard(message, "invite message");
  }

  void copyInviteLink() {
    final inviteLink = "https://bitsave.app/invite/karima123";
    _copyToClipboard(inviteLink, "invite link");
    _trackShare("Copy Link");
  }

  void copyfriendsLink() {
    final inviteLink = "https://bitsave.app/invite/karima123";
    _copyToClipboard(inviteLink, "invite link");
    _trackShare("Copy Link");
  }


  void _copyToClipboard(String text, String description) async {
    await Clipboard.setData(ClipboardData(text: text));
    _snackbarService.showSnackbar(
      message: "$description copied to clipboard! 📋",
      duration: const Duration(seconds: 3),
    );
  }

  void _trackShare(String platform) {
    friendsInvited++;
    notifyListeners();
  }

  // Getters for UI
  String get inviteProgress {
    int remaining = 3 - (friendsInvited % 3);
    return "$remaining more to earn 50 SATS";
  }


  bool get canEarnReward => (friendsInvited % 3) == 0 && friendsInvited > 0;

  void inviteFriend() {
    friendsInvited++;
    if (canEarnReward) {
      satsEarned += 50;
      _snackbarService.showSnackbar(
        message: "Congrats! You've earned 50 SATS! 🎉",
        duration: const Duration(seconds: 3),
      );
    }
    notifyListeners();
  }

  double get inviteProgressPercentage {
    return (friendsInvited % 3) / 3;
  }
  void onNavItemTapped(String item) {
    // Handle navigation item taps
    switch (item) {
      case 'Home':
      // Navigate to home
        break;
      case 'Savings':
      // Navigate to savings
        break;
      case 'Insights':
      // Navigate to insights
        break;
      case 'Invite':
      // Already on invite page
        break;
    }
  }

  void shareViaApp() {
    // Handle share via app action
    _snackbarService.showSnackbar(message: 'Share via app functionality');
  }

}




