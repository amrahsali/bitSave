import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../services/wallet_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DepositViewModel extends BaseViewModel {
  final WalletService _walletService = locator<WalletService>();

  Future<void> startDepositFlow(String amountStr) async {
    setBusy(true);
    try {
      final amount = double.parse(amountStr);
      final checkoutUrl = await _walletService.initializeDeposit(amount: amount);
      if (checkoutUrl.isNotEmpty && await canLaunchUrl(Uri.parse(checkoutUrl))) {
        await launchUrl(Uri.parse(checkoutUrl));
      }
    } catch (e) {
      rethrow;
    } finally {
      setBusy(false);
    }
  }
}