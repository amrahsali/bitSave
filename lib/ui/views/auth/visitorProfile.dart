import 'package:cached_network_image/cached_network_image.dart';
import 'package:estate360Security/core/utils/string_util.dart';
import 'package:estate360Security/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../core/data/models/gate_pass_model.dart';
import '../../../core/network/interceptors.dart';
import '../../common/app_colors.dart';

class VisitorProfileDialog extends StatefulWidget {
  final GatePassModel gatePass;

  const VisitorProfileDialog({Key? key, required this.gatePass}) : super(key: key);

  @override
  _VisitorProfileDialogState createState() => _VisitorProfileDialogState();
}

class _VisitorProfileDialogState extends State<VisitorProfileDialog> {
  bool showRejectionField = false;
  bool isLoadingAccept = false;
  bool isLoadingReject = false;
  bool isInvitationAccept = true;
  final TextEditingController rejectionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final visitor = widget.gatePass.visitor;
    final resident = widget.gatePass.resident;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              CircleAvatar(
                radius: 50,
                backgroundImage: (visitor?.imageUrl.isNotEmpty ?? false)
                    ? CachedNetworkImageProvider(visitor!.imageUrl)
                    : const AssetImage("assets/images/default_user.png") as ImageProvider,
              ),
              const SizedBox(height: 10),

              Text(
                visitor?.name == null ? "Quick Invite" : "${visitor?.name}",
                style: GoogleFonts.redHatDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              RichText(
                text: TextSpan(
                  style: GoogleFonts.redHatDisplay(fontSize: 16, color: Colors.black),
                  children: [
                    const TextSpan(text: "Gate Pass: "),
                    TextSpan(
                      text: widget.gatePass.code,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              RichText(
                text: TextSpan(
                  style: GoogleFonts.redHatDisplay(fontSize: 16, color: Colors.black),
                  children: [
                    const TextSpan(text: "Expiry: "),
                    TextSpan(
                      text: formatDate(widget.gatePass.passExpiryDate),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              if (visitor != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kcPrimaryColor, Colors.purple.shade900],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Resident Information",
                                style: GoogleFonts.redHatDisplay(
                                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 5),
                            Text("Name: ${resident.firstName} ${resident.lastName}",
                                style: GoogleFonts.redHatDisplay(fontSize: 14, color: Colors.white)),
                            Text("Phone: ${resident.phone}",
                                style: GoogleFonts.redHatDisplay(fontSize: 14, color: Colors.white)),
                            Text("Address: ${resident.houseNumber} ${resident.houseDescription}",
                                style: GoogleFonts.redHatDisplay(fontSize: 14, color: Colors.white)),
                          ],
                        ),
                      ),

                      if (resident.pictureUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: resident.pictureUrl,
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              if (showRejectionField) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    controller: rejectionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: "Rejection Reason",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (!showRejectionField) {
                        print('not showing rejection field');
                        setState(() => showRejectionField = true);
                      } else {
                        if (rejectionController.text.isNotEmpty) {
                          setState(() => isLoadingReject = true);
                          await inviteAction("REJECTED", rejectionController.text);
                          setState(() => isLoadingReject = false);
                        } else {
                          locator<SnackbarService>().showSnackbar(
                            message: "Please provide a reason for rejection",
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: isLoadingReject
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : Text(showRejectionField ? "Confirm Reject" : "Reject",
                        style: const TextStyle(color: Colors.white)),
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      setState(() => isLoadingAccept = true);
                      await inviteAction("APPROVED", null);
                      setState(() => isLoadingAccept = false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: isLoadingAccept
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Text("Accept", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              verticalSpaceLarge,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> inviteAction(String action, String? rejectionReason) async {
    try {
      final response = await repo.updateInviteStatus({
        "gatePassCode": widget.gatePass.code,
        "action": action,
        "rejectionReason": rejectionController.text,
      });
      if (response.statusCode == 200) {
        Navigator.pop(context, true);
        locator<SnackbarService>().showSnackbar(
          message: response.data['message'],
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      locator<SnackbarService>().showSnackbar(
        message: "An error occurred. Please try again",
      );
    }
  }
}