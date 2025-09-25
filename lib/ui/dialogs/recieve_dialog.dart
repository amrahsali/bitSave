import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/network/noodless_sdk.dart';

class ReceivePaymentDialog extends StatefulWidget {
  final BindingLiquidSdk sdk;
  final Stream<PaymentEvent> paymentEventStream;

  const ReceivePaymentDialog({
    super.key,
    required this.sdk,
    required this.paymentEventStream
  });

  @override
  State<ReceivePaymentDialog> createState() => _ReceivePaymentDialogState();
}

class _ReceivePaymentDialogState extends State<ReceivePaymentDialog> {
  final TextEditingController payerAmountController = TextEditingController();
  int? payerAmountSat;
  int? feesSat;
  bool creatingInvoice = false;
  String? invoiceDestination;
  StreamSubscription<PaymentEvent>? streamSubscription;

  @override
  void initState() {
    super.initState();
    streamSubscription = widget.paymentEventStream.listen((paymentEvent) {
      if (invoiceDestination != null && invoiceDestination!.isNotEmpty) {
        final payment = paymentEvent.payment;
        final doesDestinationMatch = payment.destination != null &&
            payment.destination == invoiceDestination!;
        final isPaymentReceived = payment.paymentType == PaymentType.receive &&
            (payment.status == PaymentState.pending ||
                payment.status == PaymentState.complete);
        if (doesDestinationMatch && isPaymentReceived) {
          debugPrint(
              "Payment received Destination: ${payment.destination}, Status: ${payment.status}");
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> invoiceContent() {
      return [
        AspectRatio(
          aspectRatio: 1,
          child: SizedBox(
            width: 200.0,
            height: 200.0,
            child: QrImageView(
              data: invoiceDestination!,
              size: 200.0,
            ),
          ),
        ),
        if (payerAmountSat != null && feesSat != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text('Payer Amount:'),
                const Expanded(child: SizedBox(width: 0)),
                Text('$payerAmountSat sats'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text('Fees:'),
                const Expanded(child: SizedBox(width: 0)),
                Text('$feesSat sats'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text('Receive Amount:'),
                const Expanded(child: SizedBox(width: 0)),
                Text('${payerAmountSat! - feesSat!} sats'),
              ],
            ),
          ),
        ]
      ];
    }

    Future<void> onOkPressed() async {
      try {
        setState(() => creatingInvoice = true);
        int amountSat = int.parse(payerAmountController.text);
        final prepareReceiveReq = PrepareReceiveRequest(
          paymentMethod: PaymentMethod.lightning,
          amount: ReceiveAmount.bitcoin(payerAmountSat: BigInt.from(amountSat)),
        );
        PrepareReceiveResponse prepareResponse =
        await widget.sdk.prepareReceivePayment(req: prepareReceiveReq);
        setState(() {
          payerAmountSat = amountSat;
          feesSat = prepareResponse.feesSat.toInt();
        });
        final receiveReq = ReceivePaymentRequest(
          prepareResponse: prepareResponse,
        );
        ReceivePaymentResponse resp =
        await widget.sdk.receivePayment(req: receiveReq);
        debugPrint(
          "Invoice created: $payerAmountSat sat with $feesSat sats fee.\nDestination: ${resp.destination}",
        );
        setState(() {
          invoiceDestination = resp.destination;
        });
      } catch (e) {
        setState(() {
          payerAmountSat = null;
          feesSat = null;
          invoiceDestination = null;
        });
        final errMsg = "Error receiving payment: $e";
        debugPrint(errMsg);
        if (context.mounted) {
          final snackBar = SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(errMsg),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } finally {
        setState(() => creatingInvoice = false);
      }
    }

    return AlertDialog(
      title: creatingInvoice
          ? null
          : Text(invoiceDestination != null ? "Invoice" : "Receive Payment"),
      content: creatingInvoice || invoiceDestination != null
          ? Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (invoiceDestination != null) ...invoiceContent(),
          if (creatingInvoice) ...[
            const Text('Creating Invoice...'),
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: Colors.blue),
          ]
        ],
      )
          : TextField(
        controller: payerAmountController,
        decoration: const InputDecoration(
            label: Text("Enter payer amount in sats")),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        keyboardType: TextInputType.number,
      ),
      actions: creatingInvoice
          ? []
          : [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        if (invoiceDestination == null) ...[
          TextButton(
            onPressed: onOkPressed,
            child: const Text("Ok"),
          ),
        ]
      ],
    );
  }
}