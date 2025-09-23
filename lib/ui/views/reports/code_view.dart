// import 'dart:ffi';
//
// import 'package:estate360/ui/common/app_colors.dart';
// import 'package:estate360/ui/common/ui_helpers.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:stacked_services/stacked_services.dart';
// import '../../../app/app.locator.dart';
// import '../../../app/app.router.dart';
// import '../../../core/data/models/invite_model.dart';
// import '../../../core/utils/string_util.dart';
// import '../../../state.dart';
//
// class CodeView extends StatelessWidget {
//   final GuestInviteModel invite;
//
//   const CodeView({
//     Key? key,
//     required this.invite,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     DateTime validFrom = DateTime.parse(invite.arrivalDate!);
//     DateTime validTo = validFrom.add(
//       Duration(
//         hours: int.parse(invite.duration!.endTime!.split(":")[0]) -
//             int.parse(invite.duration!.startTime!.split(":")[0]),
//         minutes: int.parse(invite.duration!.endTime!.split(":")[1]) -
//             int.parse(invite.duration!.startTime!.split(":")[1]),
//       ),
//     );
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         automaticallyImplyLeading: false,
//         actions: [
//           IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: const Icon(Icons.cancel, color: Colors.red),
//           ),
//         ],
//       ),
//       body: Center(
//         // Ensures the entire column is centered
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center, // Centers vertically
//             crossAxisAlignment:
//                 CrossAxisAlignment.center, // Centers horizontally
//             mainAxisSize:
//                 MainAxisSize.min, // Ensures it doesn’t take the full height
//             children: [
//               verticalSpaceLarge,
//               SvgPicture.asset(
//                 "assets/icons/mailer.svg",
//                 height: 68,
//                 width: 68,
//               ),
//               verticalSpaceLarge,
//               Text(
//                 "One time code for '${capitalizeFirstLetter(invite.name ?? 'Guest')}'",
//                 style: GoogleFonts.redHatDisplay(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 26),
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//                 decoration: BoxDecoration(
//                   color: Colors.amber.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SelectableText(
//                       invite.inviteCode ?? 'No code found',
//                       style: GoogleFonts.redHatDisplay(
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     //clickable icon
//                     IconButton(
//                       onPressed: () {
//                         Clipboard.setData(
//                             ClipboardData(text: invite.inviteCode ?? ''));
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text("Code copied!")),
//                         );
//                       },
//                       icon: const Icon(Icons.copy_all, color: Colors.black),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextButton.icon(
//                 style: TextButton.styleFrom(
//                   foregroundColor: Colors.black,
//                   elevation: 1,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//                 ),
//                 onPressed: () {
//                   _shareInvite(invite);
//                 },
//                 icon: const Icon(Icons.share, color: Colors.black),
//                 label:
//                     Text("Share Code", style: TextStyle(color: Colors.black)),
//               ),
//               verticalSpaceMedium,
//               Text(
//                 "Valid on",
//                 style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
//               ),
//               Text(
//                 "${DateFormat.yMMMMd().add_jm().format(validFrom)} - ${DateFormat.jm().format(validTo)}",
//                 style: GoogleFonts.redHatDisplay(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               Spacer(),
//               ElevatedButton(
//                 onPressed: () {
//                   locator<NavigationService>().clearStackAndShow(Routes.homeView);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: kcPrimaryColor,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//                 ),
//                 child: const Text("Back to Dashboard",
//                     style: TextStyle(color: Colors.black)),
//               ),
//               verticalSpaceMedium
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _shareInvite(GuestInviteModel invite) {
//     final String inviteMessage = """
//       Hey ${invite.name}! 🎉
//
//       You've been invited by ${profile.value.firstname ?? 'a friend'} to visit ${profile.value.estate?.estateName}.
//       Here’s your special entry code: **${invite.inviteCode}** 🔐
//
//       📅 Valid from: ${DateFormat.yMMMMd().add_jm().format(DateTime.parse(invite.arrivalDate!))}
//       ⏰ Until: ${invite.duration?.endTime}
//
//       Use this code at the gate for smooth entry. Looking forward to seeing you! 😊
//
//       #EstateEntry #ExclusiveInvite
//
//       """;
//
//     Share.share(inviteMessage);
//   }
// }
