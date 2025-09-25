import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';

class SendPaymentDialog extends StatefulWidget {
  final BindingLiquidSdk sdk;

  const SendPaymentDialog({super.key, required this.sdk});

  @override
  State<SendPaymentDialog> createState() => _SendPaymentDialogState();
}

class _SendPaymentDialogState extends State<SendPaymentDialog> {
  final TextEditingController invoiceController = TextEditingController();
  bool paymentInProgress = false;
  PrepareSendResponse? prepareSendResponse;

  @override
  Widget build(BuildContext context) {
    Widget promptContent() {
      return prepareSendResponse != null
          ? Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Please confirm the payment fee of ${prepareSendResponse!.feesSat} sats."),
          ],
        ),
      )
          : TextField(
        controller: invoiceController,
        decoration: InputDecoration(
          labelText: 'Enter Invoice',
          suffixIcon: IconButton(
            icon: const Icon(Icons.paste, color: Colors.cyan),
            onPressed: () async {
              final clipboardData = await Clipboard.getData('text/plain');
              if (clipboardData != null && clipboardData.text != null) {
                invoiceController.text = clipboardData.text!;
              }
            },
          ),
        ),
        maxLines: null,
      );
    }

    Widget inProgressContent() {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Sending..."),
            SizedBox(height: 16),
            CircularProgressIndicator(color: Colors.blue),
          ],
        ),
      );
    }

    Future<void> onOkPressed() async {
      try {
        setState(() => paymentInProgress = true);
        // Normalize destination input
        String raw = invoiceController.text.trim();
        if (raw.toLowerCase().startsWith('lightning:')) {
          raw = raw.substring('lightning:'.length);
        }
        // Remove accidental surrounding quotes/newlines
        raw = raw.replaceAll('\n', '').replaceAll('\r', '').replaceAll('"', '').trim();

        // Basic guard against LNURL which requires a different flow
        final lower = raw.toLowerCase();
        final isLnurl = lower.startsWith('lnurl') || lower.contains('lnurl1');
        if (isLnurl) {
          if (context.mounted) {
            final snackBar = const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('LNURL detected. Paste a BOLT11 invoice or BIP21/Liquid address.'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          setState(() => paymentInProgress = false);
          return;
        }

        final req = PrepareSendRequest(destination: raw);
        PrepareSendResponse res = await widget.sdk.prepareSendPayment(req: req);
        debugPrint(
          "prepareSendResponse destination ${res.destination} with fee ${res.feesSat} sats.\n",
        );
        setState(() {
          prepareSendResponse = res;
        });
      } catch (e) {
        final errMsg = "Error preparing payment: $e";
        debugPrint(errMsg);
        if (context.mounted) {
          Navigator.pop(context);
          final snackBar = SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(errMsg),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } finally {
        setState(() => paymentInProgress = false);
      }
    }

    Future<void> onConfirmPressed() async {
      try {
        setState(() => paymentInProgress = true);
        final sendPaymentReq = SendPaymentRequest(prepareResponse: prepareSendResponse!);
        await widget.sdk.sendPayment(req: sendPaymentReq);
        debugPrint(
          "Payment sent.\n",
        );
        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        final errMsg = "Error sending payment: $e";
        debugPrint(errMsg);
        if (context.mounted) {
          Navigator.pop(context);
          final snackBar = SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(errMsg),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } finally {
        setState(() => paymentInProgress = false);
      }
    }

    return AlertDialog(
      title: const Text("Send Payment"),
      content: paymentInProgress ? inProgressContent() : promptContent(),
      actions: paymentInProgress
          ? []
          : [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        prepareSendResponse == null
            ? TextButton(
          onPressed: onOkPressed,
          child: const Text("Ok"),
        )
            : TextButton(
          onPressed: onConfirmPressed,
          child: const Text("Confirm"),
        ),
      ],
    );
  }
}