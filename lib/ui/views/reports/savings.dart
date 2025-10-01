import 'package:bitSave/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:bitSave/state.dart';
import '../../common/ui_helpers.dart';
// import '../dashboard/balance.dart';
import 'Reports_viewmodel.dart';

class Savings extends StatelessWidget {
  const Savings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: ViewModelBuilder<ReportsViewModel>.reactive(
        onViewModelReady: (model) => model.init(),
        viewModelBuilder: () => ReportsViewModel(),
        builder: (context, model, child) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with time and user info
                _buildWelcomeHeader(),
                const SizedBox(height: 20),

                // Make the main content scrollable
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAccountContent(model),
                        const SizedBox(height: 20),
                        _buildQuickSaveButton(context, model, kcPrimaryColor),
                        const SizedBox(height: 30),
                        _buildRecommendationsSection(model, kcPrimaryColor),
                        const SizedBox(height: 30),
                        _buildOngoingSavingsSection(model, kcPrimaryColor),
                        const SizedBox(height: 20),
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

  Widget _buildWelcomeHeader() {
    final currentUser = profile.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentUser.firstName?.isNotEmpty == true
              ? "Hi, ${currentUser.firstName}"
              : "Hi, Guest",
          style: GoogleFonts.redHatDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountContent(ReportsViewModel viewModel) {
    if (viewModel.selectedAccountType == 0) {
      return _buildFiatBalanceSection(viewModel);
    } else {
      return _buildCryptoBalanceSection(viewModel);
    }
  }

  Widget _buildFiatBalanceSection(ReportsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.savings_outlined, color: kcPrimaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "My Total Savings",
                    style: GoogleFonts.redHatDisplay(
                      fontSize: 16,
                      color: kcWhiteColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Bitcoin',
                  style: GoogleFonts.redHatDisplay(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Total Balance',
            style: GoogleFonts.redHatDisplay(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                "₿20,999.99",
                style: GoogleFonts.redHatDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //   decoration: BoxDecoration(
              //     color: Colors.white.withOpacity(0.2),
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   child: Text(
              //     '₿ ${viewModel.cryptoBalance.toStringAsFixed(2)}',
              //     style: GoogleFonts.redHatDisplay(
              //       fontSize: 14,
              //       color: Colors.white,
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              // ),
            ],
          ),
          verticalSpaceMedium,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Today +${viewModel.todayChange}%',
                  style: GoogleFonts.redHatDisplay(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoBalanceSection(ReportsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bitcoin account',
                style: GoogleFonts.redHatDisplay(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Bitcoin',
                  style: GoogleFonts.redHatDisplay(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Total Value',
            style: GoogleFonts.redHatDisplay(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${viewModel.cryptoBalanceInSats.toStringAsFixed(0)} sats',
                style: GoogleFonts.redHatDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              //
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //   decoration: BoxDecoration(
              //     color: Colors.white.withOpacity(0.2),
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   child: Text(
              //     '₿ ${viewModel.cryptoBalance.toStringAsFixed(6)}',
              //     style: GoogleFonts.redHatDisplay(
              //       fontSize: 14,
              //       color: Colors.white,
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 8),
          // Row(
          //   children: [
          //     Container(
          //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //       decoration: BoxDecoration(
          //         color: Colors.white.withOpacity(0.15),
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //       child: Text(
          //         '₦${(viewModel.cryptoBalance * 50000).toStringAsFixed(2)}',
          //         style: GoogleFonts.redHatDisplay(
          //           fontSize: 12,
          //           color: Colors.white,
          //           fontWeight: FontWeight.w500,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '24h +5.2%',
                  style: GoogleFonts.redHatDisplay(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  void _showQuickSaveDialog(BuildContext context, ReportsViewModel model) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Quick Save",
                        style: GoogleFonts.redHatDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Amount Input
                  Text(
                    "Enter Amount to Save",
                    style: GoogleFonts.redHatDisplay(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.redHatDisplay(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 8),
                          child: Text(
                            "₿",
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Amount Buttons
                  Text(
                    "Quick Amounts",
                    style: GoogleFonts.redHatDisplay(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildAmountChip("₿1000", context, model),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildAmountChip("₿2500", context, model),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildAmountChip("₿5000", context, model),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.redHatDisplay(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle save logic here
                            model.quickSave();
                            Navigator.of(context).pop();
                            _showSuccessSnackbar(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF667eea),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.savings_outlined, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                "Save Now",
                                style: GoogleFonts.redHatDisplay(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmountChip(String amount, BuildContext context, ReportsViewModel model) {
    return GestureDetector(
      onTap: () {
        // Set the amount in the text field when chip is tapped
        // You'll need to add a TextEditingController to your model for this
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Text(
          amount,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF667eea),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Money added successfully! Converting to Bitcoin...",
                style: GoogleFonts.redHatDisplay(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildQuickSaveButton(BuildContext context, ReportsViewModel model, Color primaryColor) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showQuickSaveDialog(context, model),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: primaryColor.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline, size: 20),
            const SizedBox(width: 8),
            Text(
              "Quick Save",
              style: GoogleFonts.redHatDisplay(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection(ReportsViewModel model, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recommendations",
                style: GoogleFonts.redHatDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor,
                ),
              ),
              GestureDetector(
                onTap: () => model.showMoreOptions(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "More",
                        style: GoogleFonts.redHatDisplay(
                          fontSize: 14,
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, size: 12, color: primaryColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(width: 4),
              _buildRecommendationCard("₿5000", "Buying Car", "9 Months", primaryColor, Icons.directions_car_filled_outlined),
              const SizedBox(width: 12),
              _buildRecommendationCard("₿6000", "Buying House", "6 years", primaryColor, Icons.house_outlined),
              const SizedBox(width: 12),
              _buildRecommendationCard("₿9000", "Education", "2 years", primaryColor, Icons.category_outlined),
              const SizedBox(width: 12),
              _buildRecommendationCard("₿7500", "Others", "6 months", primaryColor, Icons.school_outlined),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(String amount, String purpose, String duration, Color primaryColor, IconData icon) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.05),
            primaryColor.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: primaryColor),
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: GoogleFonts.redHatDisplay(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor,
            ),
          ),
          Text(
            purpose,
            style: GoogleFonts.redHatDisplay(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              duration,
              style: GoogleFonts.redHatDisplay(
                fontSize: 10,
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOngoingSavingsSection(ReportsViewModel model, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ongoing Savings",
                style: GoogleFonts.redHatDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor,
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),

        // My Safe Lock Card
        _buildSavingsCard(
          "My safe lock",
          "₿6,000",
          "Uncompleted",
          "6 Months remaining",
          Icons.lock_outline,
          primaryColor,
          model,
        ),
        const SizedBox(height: 12),

        // Others Card
        _buildSavingsCard(
          "Others",
          "₿6,000",
          "Uncompleted",
          "6 Months remaining",
          Icons.category_outlined,
          primaryColor,
          model,
        ),
      ],
    );
  }

  Widget _buildSavingsCard(String title, String amount, String status, String duration, IconData icon, Color primaryColor, ReportsViewModel model) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: uiMode.value == AppUiModes.dark ? kcDarkGreyColor : kcWhiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 20, color: primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: GoogleFonts.redHatDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor,
                    ),
                  ),
                ],
              ),
              Text(
                amount,
                style: GoogleFonts.redHatDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.redHatDisplay(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    duration,
                    style: GoogleFonts.redHatDisplay(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => model.unlockSavings(title),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: Text(
                      "Unlock",
                      style: GoogleFonts.redHatDisplay(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => model.completeSavings(title),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      elevation: 2,
                    ),
                    child: Text(
                      "Complete",
                      style: GoogleFonts.redHatDisplay(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedAccountTabBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabChanged;
  final double borderRadius;

  const _AnimatedAccountTabBar({
    required this.currentIndex,
    required this.onTabChanged,
    this.borderRadius = 30,
  });

  @override
  State<_AnimatedAccountTabBar> createState() => __AnimatedAccountTabBarState();
}

class __AnimatedAccountTabBarState extends State<_AnimatedAccountTabBar> {
  late List<bool> isHoverList = [false, false];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        2,
            (index) {
          return InkWell(
            onTap: () {
              widget.onTabChanged(index);
            },
            onHover: (value) {
              setState(() {
                isHoverList[index] = value;
              });
            },
            child: AnimatedContainer(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.center,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeIn,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                color: widget.currentIndex == index || isHoverList[index]
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300],
              ),
              child: Text(
                ['Fiat Accounts', 'Bitcoin Accounts'][index],
                style: GoogleFonts.redHatDisplay(
                  color: widget.currentIndex == index ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}