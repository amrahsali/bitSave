import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:bitSave/state.dart';
import '../../common/app_colors.dart';
import 'Reports_viewmodel.dart';

class Reports extends StatelessWidget {
  const Reports({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
                const SizedBox(height: 16),
                _buildBitcoinPill(),
                const SizedBox(height: 20),

                // Make the main content scrollable
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Income & Expenses Section
                        _buildIncomeExpensesSection(model, kcPrimaryColor),
                        const SizedBox(height: 16),

                        // Chart Section
                        _buildChartSection(model, kcPrimaryColor),
                        const SizedBox(height: 16),

                        // Savings Goals Section
                        _buildSavingsGoalsSection(model, kcPrimaryColor),
                        const SizedBox(height: 16),

                        // Total Balance Section
                        _buildTotalBalanceSection(model, kcPrimaryColor),
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
    String name = currentUser.firstName?.isNotEmpty == true ? currentUser.firstName! : "Guest";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Hi, $name",
          style: GoogleFonts.redHatDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none_outlined, color: Colors.white, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBitcoinPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.currency_bitcoin, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Text(
            "Bitcoin Account",
            style: GoogleFonts.redHatDisplay(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildIncomeExpensesSection(ReportsViewModel model, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Insights",
          style: GoogleFonts.redHatDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1A22),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Income",
                    style: GoogleFonts.redHatDisplay(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    "Expenses",
                    style: GoogleFonts.redHatDisplay(
                      color: Colors.white38,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection(ReportsViewModel model, Color primaryColor) {
    return Container(
      height: 250,
      padding: const EdgeInsets.only(top: 20, right: 20, bottom: 20, left: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1A22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                drawHorizontalLine: true,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white.withValues(alpha: 0.05),
                  strokeWidth: 1,
                ),
                getDrawingVerticalLine: (value) => FlLine(
                  color: Colors.white.withValues(alpha: 0.05),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      const style = TextStyle(color: Colors.white70, fontSize: 10);
                      Widget text;
                      switch (value.toInt()) {
                        case 0: text = const Text('Jul', style: style); break;
                        case 1: text = const Text('Aug', style: style); break;
                        case 2: text = const Text('Sep', style: style); break;
                        case 3: text = const Text('Oct', style: style); break;
                        case 4: text = const Text('Nov', style: style); break;
                        case 5: text = const Text('Dec', style: style); break;
                        default: text = const Text(''); break;
                      }
                      return Padding(padding: const EdgeInsets.only(top: 8.0), child: text);
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 5000,
                    getTitlesWidget: (value, meta) {
                      const style = TextStyle(color: Colors.white70, fontSize: 10);
                      return Text('\$${value.toInt()}', style: style);
                    },
                    reservedSize: 42,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 5,
              minY: 0,
              maxY: 15000,
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 4000),
                    FlSpot(1, 10000),
                    FlSpot(2, 12000),
                    FlSpot(3, 13000),
                    FlSpot(4, 10000),
                    FlSpot(5, 11500),
                  ],
                  isCurved: true,
                  color: const Color(0xFF6B4EE6),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, barData) => spot.x == 3,
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 5,
                      color: Colors.white,
                      strokeWidth: 3,
                      strokeColor: const Color(0xFF6B4EE6),
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6B4EE6).withValues(alpha: 0.3),
                        const Color(0xFF6B4EE6).withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tooltip Overlay for BTC 12,455 at Oct
          Positioned(
            left: 175, 
            top: 40, 
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6B4EE6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "BTC 12,455",
                style: GoogleFonts.redHatDisplay(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Top right calendar icon
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF252136).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_month, color: Colors.white70, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsGoalsSection(ReportsViewModel model, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF252136),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.pie_chart, color: Color(0xFF6B4EE6), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Savings goals",
                  style: GoogleFonts.redHatDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B4EE6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Set your savings goal and\ntrack them here",
                  style: GoogleFonts.redHatDisplay(
                    fontSize: 14,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.add, color: Color(0xFF6B4EE6), size: 30),
        ],
      ),
    );
  }

  Widget _buildTotalBalanceSection(ReportsViewModel model, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF252136),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "BTC 14530,12",
                      style: GoogleFonts.redHatDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF6B4EE6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Total Balance",
                      style: GoogleFonts.redHatDisplay(
                        fontSize: 12,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "BTC 13540,40",
                      style: GoogleFonts.redHatDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF6B4EE6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Total amount in savings",
                      style: GoogleFonts.redHatDisplay(
                        fontSize: 12,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
               Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF6B4EE6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Personal business",
                          style: GoogleFonts.redHatDisplay(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "\$12400.00",
                          style: GoogleFonts.redHatDisplay(
                            fontSize: 14,
                            color: const Color(0xFF6B4EE6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B4EE6).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.85,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B4EE6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "85%",
                        style: GoogleFonts.redHatDisplay(
                          fontSize: 12,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
