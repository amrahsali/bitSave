import 'package:bitSave/core/network/noodless_sdk.dart';
import 'package:bitSave/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../../../state.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../dialogs/recieve_dialog.dart';
import '../../dialogs/send_dialog.dart';
import '../../dialogs/add_naira_dialog.dart';
import 'balance.dart';
import 'dashboard_viewmodel.dart';

class DashboardView extends StackedView<DashboardViewModel> {
  final NodelessSdk sdk = NodelessSdk();

  DashboardView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, DashboardViewModel viewModel, Widget? child) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: _buildBody(context, viewModel),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DashboardViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () => viewModel.refreshData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 20),
            _buildAccountTabs(viewModel),
            const SizedBox(height: 16),
            _buildAccountContent(viewModel),
            const SizedBox(height: 16),
            _buildActionButtons(context, viewModel),
            const SizedBox(height: 24),
            _buildTransactionsSection(viewModel),
          ],
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


  Widget _buildAccountTabs(DashboardViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: _AnimatedAccountTabBar(
        currentIndex: viewModel.selectedAccountType,
        onTabChanged: (index) => viewModel.setAccountType(index),
      ),
    );
  }

  Widget _buildAccountContent(DashboardViewModel viewModel) {
    if (viewModel.selectedAccountType == 0) {
      return _buildFiatBalanceSection(viewModel);
    } else {
      return _buildCryptoBalanceSection(viewModel);
    }
  }

  Widget _buildFiatBalanceSection(DashboardViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
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
              Text(
                'Naira Account',
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
                  'Fiat',
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
              // Balance(getInfoStream: sdk.getInfoStream),
              Text(
                '₦0.00',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                fontFamily: 'Roboto',
              ),
              ),
              const SizedBox(width: 8),
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //   decoration: BoxDecoration(
              //     color: Colors.white.withOpacity(0.2),
              //     borderRadius: BorderRadius.circular(8),
              //   ),
                // child: Text(
                //   '₿ ${viewModel.cryptoBalance.toStringAsFixed(2)}',
                //   style: GoogleFonts.redHatDisplay(
                //     fontSize: 14,
                //     color: Colors.white,
                //     fontWeight: FontWeight.w600,
                //   ),
                // ),
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
                // Container(
                //   padding: const EdgeInsets.all(4),
                //   decoration: const BoxDecoration(
                //     color: Colors.green,
                //     shape: BoxShape.circle,
                //   ),
                //   child: const Icon(
                //     Icons.arrow_upward,
                //     color: Colors.white,
                //     size: 14,
                //   ),
                // ),
                // const SizedBox(width: 8),
                // Text(
                //   'Today +${viewModel.todayChange}%',
                //   style: GoogleFonts.redHatDisplay(
                //     color: Colors.white,
                //     fontSize: 14,
                //     fontWeight: FontWeight.w600,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoBalanceSection(DashboardViewModel viewModel) {
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

  void _handleAddAction(BuildContext context, DashboardViewModel viewModel) {
    if (viewModel.selectedAccountType == 0) {
      // Fiat account - show Add Naira dialog
      showDialog(
        context: context,
        builder: (context) => AddNairaDialog(
          userId: "user_123", // Replace with actual user ID
          onFundsAdded: (nairaAmount, satsAmount) {
            viewModel.addNairaFunds(nairaAmount, satsAmount);
          },
        ),
      );
    } else {
      // Crypto account - show Bitcoin receive dialog
      viewModel.handleAddAction(viewModel.selectedAccountType);
    }
  }

  Widget _buildActionButtons(BuildContext context, DashboardViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          'assets/icons/square-plus.svg',
          'Add',
          viewModel.selectedAccountType == 0 ? Colors.blue : Colors.purple,
              () => _handleAddAction(context, viewModel),
        ),
        _buildActionButton(
          'assets/icons/square-arrow-up.svg',
          'Transfer',
          viewModel.selectedAccountType == 0 ? Colors.green : Colors.orange,
              () => showDialog(
            context: context,
            builder: (context) => SendPaymentDialog(sdk: sdk.instance!),
          ),
        ),
        _buildActionButton(
          'assets/icons/square-arrow-down.svg',
          'Receive',
          viewModel.selectedAccountType == 0 ? Colors.purple : Colors.blue,
              () => showDialog(
            context: context,
            builder: (context) => ReceivePaymentDialog(
              sdk: sdk.instance!,
              paymentEventStream: sdk.paymentEventStream,
            ),
          ),
        ),
        _buildActionButton(
          'assets/icons/Swap.svg',
          'Swap',
          viewModel.selectedAccountType == 0 ? Colors.orange : Colors.green,
              () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Coming Soon"),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.grey,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),

      ],
    );
  }

  Widget _buildActionButton(String iconPath, String label, Color primaryColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor.withOpacity(0.1),
                    primaryColor.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            primaryColor.withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: SvgPicture.asset(
                        iconPath,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.redHatDisplay(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsSection(DashboardViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transactions',
              style: GoogleFonts.redHatDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              onTap: () {},
              child: Text(
                'See all',
                style: GoogleFonts.redHatDisplay(
                  color: kcPrimaryColor,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: viewModel.transactions.length,
          itemBuilder: (context, index) {
            final transaction = viewModel.transactions[index];
            return _buildTransactionItem(transaction);
          },
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final bool isNegative = transaction.amount < 0;
    final Color primaryColor = isNegative ? const Color(0xFFF44336) : const Color(0xFF4CAF50);
    final Color bgColor = primaryColor.withOpacity(0.05);

    final List<Color> avatarColors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];
    final int colorIndex = transaction.recipient.hashCode % avatarColors.length;
    final Color avatarColor = avatarColors[colorIndex];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        borderRadius: BorderRadius.circular(18),
        color: uiMode.value == AppUiModes.dark ? kcDarkGreyColor : kcWhiteColor,
        elevation: 0,
        child: InkWell(
          onTap: () => _showTransactionDetails(transaction),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.grey.withOpacity(0.1),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: avatarColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      transaction.recipient.substring(0, 1).toUpperCase(),
                      style: GoogleFonts.redHatDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: avatarColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            transaction.recipient,
                            style: GoogleFonts.redHatDisplay(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: uiMode.value == AppUiModes.dark ? kcWhiteColor : kcBlackColor,
                            ),
                          ),
                          Text(
                            '${isNegative ? '-' : '+'}₦${transaction.amount.abs().toStringAsFixed(2)}',
                            style: GoogleFonts.redHatDisplay(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${transaction.date}, ${transaction.time}',
                                style: GoogleFonts.redHatDisplay(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isNegative ? 'SENT' : 'RECEIVED',
                              style: GoogleFonts.redHatDisplay(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    // Implement transaction details dialog
  }

  @override
  DashboardViewModel viewModelBuilder(BuildContext context) => DashboardViewModel();

  @override
  void onViewModelReady(DashboardViewModel viewModel) {
    viewModel.refreshData();
    super.onViewModelReady(viewModel);
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