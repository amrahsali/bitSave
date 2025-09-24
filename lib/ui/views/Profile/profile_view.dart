import 'package:bitSave/ui/views/Profile/profile_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../core/utils/string_util.dart';
import '../../../state.dart';
import '../../common/app_colors.dart';
import '../../dialogs/bottom_sheets/changePassword_bottom_sheet.dart';
import '../../dialogs/bottom_sheets/editProfile_bottom_sheet.dart';
import '../auth/auth_view.dart';
import 'dart:io';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePage();
}
  class _UserProfilePage extends State<UserProfilePage> {

    @override
    Widget build(BuildContext context) {
      return ViewModelBuilder<ProfileViewModel>.reactive(
        viewModelBuilder: () => ProfileViewModel(),
        onViewModelReady: (model) => model.getProfile(),
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, viewModel),
                const SizedBox(height: 20),
                _buildSectionTitle("Account Settings"),
                _buildListTile("Change password", Icons.lock_outline, () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    builder: (context) => const ChangePasswordSheet(),
                  );
                }),
                const SizedBox(height: 20),
                _buildSectionTitle("More"),
                _buildListTile("About us", Icons.info_outline, () {
                  viewModel.goToAbout("");
                }),
                _buildListTile("Invite a friend and earn", Icons.privacy_tip_outlined, () {
                  viewModel.goToAbout("invite");
                }),
                const SizedBox(height: 20),
                _buildLogoutButton(context, viewModel),
              ],
            ),
          );
        },
      );
    }

    Widget _buildProfileHeader(BuildContext context, ProfileViewModel viewModel) {
      return Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kcPrimaryColor, Colors.purple.shade900],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  //onTap: () => _showImageOverlay(context, viewModel),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white24,
                          // image: DecorationImage(
                          //   image: _resolveProfileImageProvider(viewModel),
                          //   fit: BoxFit.cover,
                          // ),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder<User>(
                        valueListenable: profile,
                        builder: (context, user, _) {
                          return Text(
                            "${profile.value.firstName ?? ''} ${profile.value.lastName ?? ''}",
                            style: GoogleFonts.redHatDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                          },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Karima Hussaini",
                        style: GoogleFonts.redHatDisplay(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        "email: ${profile.value.email ?? 'karima@gmail.com'}",
                        style: GoogleFonts.redHatDisplay(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 24,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                builder: (context) => const EditProfileSheet(),
                );
              },
            ),
          ),
        ],
      );
    }

    Widget _buildSectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
        child: Text(
          title,
          style: GoogleFonts.redHatDisplay(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      );
    }

    Widget _buildListTile(String title, IconData icon, VoidCallback onTap) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          title,
          style: GoogleFonts.redHatDisplay(fontSize: 16),
        ),
        trailing:
        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        leading: Icon(icon, color: Colors.black),
        onTap: onTap,
      );
    }

    Widget _buildLogoutButton(BuildContext context, ProfileViewModel viewModel) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () async {
              final res = await locator<DialogService>().showConfirmationDialog(
                  title: "Are you sure?",
                  cancelTitle: "No",
                  confirmationTitle: "Yes");
              if (res!.confirmed) {
                userLoggedIn.value = false;
                await locator<LocalStorage>().delete(LocalStorageDir.authToken);
                await locator<LocalStorage>().delete(LocalStorageDir.authUser);
                await locator<LocalStorage>()
                    .delete(LocalStorageDir.authRefreshToken);
                locator<NavigationService>().clearStackAndShow(Routes.authView,
                    arguments:
                    const AuthViewArguments(authType: AuthType.adminLogin));
              }
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: Text(
              "Logout",
              style: GoogleFonts.redHatDisplay(fontSize: 16, color: Colors.red),
            ),
          ),

        ],
      );
    }

    // ImageProvider _resolveProfileImageProvider(ProfileViewModel viewModel) {
    //   if (viewModel.confirmedImageFile != null) {
    //     return FileImage(File(viewModel.confirmedImageFile!.path));
    //   }
    //
    //   final picture = profile.value.picture;
    //   if (picture != null) {
    //     try {
    //       final dataField = picture.data;
    //       if (dataField != null && dataField.toString().isNotEmpty) {
    //         return MemoryImage(decodeBase64Image(dataField.toString()));
    //       }
    //     } catch (e) {
    //       debugPrint('Error decoding base64 image: $e');
    //     }
    //
    //     final url = picture.url?.toString();
    //     if (url != null && url.isNotEmpty) {
    //       final t = (viewModel.profileImageFreshness ?? 0);
    //       final sep = url.contains('?') ? '&' : '?';
    //       final finalUrl = t > 0 ? '$url$sep' 't=$t' : url;
    //       return NetworkImage(finalUrl);
    //     }
    //   }
    //
    //   return const AssetImage('assets/images/lady.png');
    // }

    // void _showImageOverlay(BuildContext context, ProfileViewModel viewModel) {
    //   showModalBottomSheet(
    //     context: context,
    //     isScrollControlled: true,
    //     backgroundColor: Colors.transparent,
    //     builder: (ctx) {
    //       return GestureDetector(
    //         behavior: HitTestBehavior.opaque,
    //         onTap: () => Navigator.of(ctx).pop(),
    //         child: Container(
    //           color: Colors.black54,
    //           child: Center(
    //             child: Padding(
    //               padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
    //               child: Material(
    //                 borderRadius: BorderRadius.circular(12),
    //                 clipBehavior: Clip.hardEdge,
    //                 child: Padding(
    //                   padding: const EdgeInsets.all(16.0),
    //                   child: ConstrainedBox(
    //                     constraints: const BoxConstraints(maxWidth: 420),
    //                     child: Column(
    //                       mainAxisSize: MainAxisSize.min,
    //                       children: [
    //                         Container(
    //                           width: 160,
    //                           height: 160,
    //                           decoration: BoxDecoration(
    //                             shape: BoxShape.circle,
    //                             image: DecorationImage(
    //                               image: _resolveProfileImageProvider(viewModel),
    //                               fit: BoxFit.cover,
    //                             ),
    //                           ),
    //                         ),
    //                         const SizedBox(height: 12),
    //                         Text(
    //                           "${profile.value.firstName ?? ''} ${profile.value.lastName ?? ''}",
    //                           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    //                         ),
    //                         const SizedBox(height: 8),
    //                         Text(profile.value.email ?? '', style: const TextStyle(color: kcMediumGrey)),
    //                         const SizedBox(height: 16),
    //                         Row(
    //                           children: [
    //                             Expanded(
    //                               child: ElevatedButton.icon(
    //                                 icon: const Icon(Icons.edit, color: kcWhiteColor),
    //                                 label: const Text(
    //                                   'Edit',
    //                                   style: TextStyle(color: kcWhiteColor),
    //                                   ),
    //                                 onPressed: () {
    //                                   Navigator.of(ctx).pop();
    //                                   _showPickOptions(context, viewModel);
    //                                 },
    //                                 style: ElevatedButton.styleFrom(
    //                                   backgroundColor: kcPrimaryColor,
    //                                   padding: const EdgeInsets.symmetric(vertical: 12),
    //                                 ),
    //                               ),
    //                             ),
    //                             const SizedBox(width: 12),
    //                             Expanded(
    //                               child: OutlinedButton(
    //                                 onPressed: () => Navigator.of(ctx).pop(),
    //                                 child: const Text('Close'),
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ),
    //       );
    //     },
    //   );
    // }
    //
    // void _showPickOptions(BuildContext context, ProfileViewModel viewModel) {
    //   showModalBottomSheet(
    //     context: context,
    //     backgroundColor: Colors.white,
    //     shape: const RoundedRectangleBorder(
    //       borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    //     ),
    //     builder: (ctx) => SafeArea(
    //       child: Wrap(
    //         children: [
    //           ListTile(
    //             leading: const Icon(Icons.photo_library),
    //             title: const Text('Choose from gallery'),
    //             onTap: () async {
    //               Navigator.of(ctx).pop();
    //               final XFile? file = await viewModel.pickImageFrom(ImageSource.gallery);
    //               if (file != null) {
    //                 await _showConfirmImageDialog(context, viewModel, file);
    //               }
    //             },
    //           ),
    //           ListTile(
    //             leading: const Icon(Icons.camera_alt),
    //             title: const Text('Take a photo'),
    //             onTap: () async {
    //               Navigator.of(ctx).pop();
    //               final XFile? file = await viewModel.pickImageFrom(ImageSource.camera);
    //               if (file != null) {
    //                 await _showConfirmImageDialog(context, viewModel, file);
    //               }
    //             },
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }
    //
    // Future<void> _showConfirmImageDialog(BuildContext context, ProfileViewModel viewModel, XFile picked) async {
    //   final file = File(picked.path);
    //
    //   await showModalBottomSheet(
    //     context: context,
    //     isScrollControlled: true,
    //     backgroundColor: Colors.transparent,
    //     builder: (ctx) {
    //       return GestureDetector(
    //         behavior: HitTestBehavior.opaque,
    //         onTap: () => Navigator.of(ctx).pop(),
    //         child: Container(
    //           color: Colors.black54,
    //           child: Center(
    //             child: Padding(
    //               padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
    //               child: Material(
    //                 borderRadius: BorderRadius.circular(12),
    //                 clipBehavior: Clip.hardEdge,
    //                 child: Padding(
    //                   padding: const EdgeInsets.all(16.0),
    //                   child: Column(
    //                     mainAxisSize: MainAxisSize.min,
    //                     children: [
    //                       Container(
    //                         width: 180,
    //                         height: 180,
    //                         decoration: BoxDecoration(
    //                           shape: BoxShape.circle,
    //                           image: DecorationImage(
    //                             image: FileImage(file),
    //                             fit: BoxFit.cover,
    //                           ),
    //                         ),
    //                       ),
    //                       const SizedBox(height: 12),
    //                       const Text('Confirm new profile picture?', style: TextStyle(fontSize: 16)),
    //                       const SizedBox(height: 16),
    //                       Row(
    //                         children: [
    //                           Expanded(
    //                             child: ElevatedButton(
    //                               onPressed: () async {
    //                                 Navigator.of(ctx).pop();
    //                                 viewModel.setConfirmedImageFile(picked);
    //                                 final success = await viewModel.uploadProfileImageMultipart(file, profile.value.id ?? 0);
    //                                 if (success) {
    //                                   locator<SnackbarService>().showSnackbar(
    //                                     message: "Profile picture updated successfully",
    //                                     duration: const Duration(seconds: 2),
    //                                   );
    //                                 } else {
    //                                   viewModel.clearConfirmedImageFile();
    //                                 }
    //                               },
    //                               style: ElevatedButton.styleFrom(backgroundColor: kcPrimaryColor),
    //                               child: const Text(
    //                                 'Confirm',
    //                                 style: TextStyle(color: kcWhiteColor),
    //                                 ),
    //                             ),
    //                           ),
    //                           const SizedBox(width: 12),
    //                           Expanded(
    //                             child: OutlinedButton(
    //                               onPressed: () {
    //                                 Navigator.of(ctx).pop();
    //                                 viewModel.clearPickedImageFile();
    //                               },
    //                               child: const Text('Cancel'),
    //                             ),
    //                           ),
    //                         ],
    //                       )
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ),
    //       );
    //     },
    //   );
    // }

  }
