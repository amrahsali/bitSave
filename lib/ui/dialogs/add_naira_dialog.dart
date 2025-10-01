import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/network/mavapay_service.dart';
import '../../core/data/models/mavapay_models.dart';
import '../../core/data/models/mavapay_models.dart';

class AddNairaDialog extends StatefulWidget {
  final String userId;
  final Function(double nairaAmount, double satsAmount) onFundsAdded;

  const AddNairaDialog({
    super.key,
    required this.userId,
    required this.onFundsAdded,
  });

  @override
  State<AddNairaDialog> createState() => _AddNairaDialogState();
}

class _AddNairaDialogState extends State<AddNairaDialog> {
  final TextEditingController _amountController = TextEditingController();
  final MavapayService _mavapayService = MavapayService();
  bool _isLoading = false;
  bool _isConverting = false;
  double _exchangeRate = 50000.0; // Default rate, will be fetched from API
  double _estimatedSats = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchExchangeRate();
    _amountController.addListener(_calculateSats);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchExchangeRate() async {
    try {
      final response = await _mavapayService.getBitcoinExchangeRate();
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _exchangeRate = (response.data['data']['rate'] ?? 50000.0).toDouble();
        });
      }
    } catch (e) {
      // Use default rate if API fails
      debugPrint('Failed to fetch exchange rate: $e');
    }
  }

  void _calculateSats() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount > 0) {
      setState(() {
        _estimatedSats = CurrencyConverter.nairaToSats(amount, _exchangeRate);
      });
    } else {
      setState(() {
        _estimatedSats = 0.0;
      });
    }
  }

  Future<void> _addFunds() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showErrorSnackBar('Please enter a valid amount');
      return;
    }

    if (amount < 100) {
      _showErrorSnackBar('Minimum amount is ₦100');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Add Naira funds
      final addFundsResponse = await _mavapayService.addNairaFunds(
        userId: widget.userId,
        amount: amount,
        currency: 'NGN',
        paymentMethod: 'bank_transfer',
        metadata: {
          'source': 'mobile_app',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (addFundsResponse.statusCode == 200 && addFundsResponse.data['success'] == true) {
        // Convert to Bitcoin
        setState(() => _isConverting = true);
        
        final conversionResponse = await _mavapayService.convertNairaToBitcoin(
          nairaAmount: amount,
          userId: widget.userId,
        );

        if (conversionResponse.statusCode == 200 && conversionResponse.data['success'] == true) {
          final conversionResult = MavapayConversionResult.fromJson(conversionResponse.data['data']);
          
          // Calculate sats amount
          final satsAmount = CurrencyConverter.bitcoinToSats(conversionResult.toAmount);
          
          // Notify parent widget
          widget.onFundsAdded(amount, satsAmount);
          
          _showSuccessSnackBar('Successfully added ₦${amount.toStringAsFixed(2)} and converted to ${satsAmount.toStringAsFixed(0)} sats');
          
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else {
          _showErrorSnackBar('Failed to convert to Bitcoin: ${conversionResponse.data['message'] ?? 'Unknown error'}');
        }
      } else {
        _showErrorSnackBar('Failed to add funds: ${addFundsResponse.data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _isConverting = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add Naira Funds',
        style: GoogleFonts.redHatDisplay(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter the amount you want to add to your account:',
            style: GoogleFonts.redHatDisplay(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Amount (NGN)',
              hintText: 'Enter amount in Naira',
              prefixText: '₦ ',
              border: const OutlineInputBorder(),
              helperText: 'Minimum: ₦100',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          const SizedBox(height: 16),
          if (_amountController.text.isNotEmpty && _estimatedSats > 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conversion Preview',
                    style: GoogleFonts.redHatDisplay(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₦${_amountController.text} → ${_estimatedSats.toStringAsFixed(0)} sats',
                    style: GoogleFonts.redHatDisplay(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Rate: ₦${_exchangeRate.toStringAsFixed(0)} per BTC',
                    style: GoogleFonts.redHatDisplay(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_isConverting) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  'Converting to Bitcoin...',
                  style: GoogleFonts.redHatDisplay(
                    fontSize: 12,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addFunds,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Add Funds'),
        ),
      ],
    );
  }
}
