import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dashboard/dashboard_viewmodel.dart';

class AllTransactionsView extends StatelessWidget {
  final List<Transaction> transactions;

  const AllTransactionsView({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0A1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0A1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'All Transactions',
          style: GoogleFonts.redHatDisplay(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: transactions.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => Divider(
                color: Colors.white.withValues(alpha: 0.06),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return _buildTransactionTile(transaction);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF6B4EE6).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 40,
                color: Color(0xFF6B4EE6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No transactions yet',
              style: GoogleFonts.redHatDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your transactions will appear here\nonce you start saving.',
              textAlign: TextAlign.center,
              style: GoogleFonts.redHatDisplay(
                fontSize: 14,
                color: Colors.white54,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(Transaction transaction) {
    final bool isNegative = transaction.amount < 0;
    final Color amountColor =
        isNegative ? const Color(0xFFFF3B30) : const Color(0xFF34C759);

    final String initial = transaction.recipient.isNotEmpty
        ? transaction.recipient.substring(0, 1).toUpperCase()
        : 'U';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFF6B4EE6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: GoogleFonts.redHatDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isNegative
                        ? const Color(0xFFFF3B30)
                        : const Color(0xFF34C759),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFF0F0A1E), width: 2),
                  ),
                  child: Icon(
                    isNegative
                        ? Icons.arrow_outward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isNegative
                      ? 'Sent to ${transaction.recipient}'
                      : 'Received from ${transaction.recipient}',
                  style: GoogleFonts.redHatDisplay(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.date}, ${transaction.time}',
                  style: GoogleFonts.redHatDisplay(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Text(
            '${isNegative ? '-' : '+'}₦${transaction.amount.abs().toStringAsFixed(2)}',
            style: GoogleFonts.redHatDisplay(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
