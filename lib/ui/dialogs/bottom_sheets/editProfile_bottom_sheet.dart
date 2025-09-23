import 'package:estate360Security/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../state.dart';
import '../../common/app_colors.dart';
import '../../components/submit_button.dart';
import '../../views/Profile/profile_viewmodel.dart';

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(),
      builder: (context, viewModel, child) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Edit Profile",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: kcPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: viewModel.firstNameController,
                    decoration: InputDecoration(
                      hintText: "Name",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  verticalSpaceTiny,
                  TextField(
                    controller: viewModel.lastNameController,
                    decoration: InputDecoration(
                      hintText: "Surname",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  verticalSpaceTiny,
                  const SizedBox(height: 20),
                  SubmitButton(
                    isLoading: viewModel.isUpdateProfile,
                    boldText: true,
                    label: "Save",
                    submit:() {
                    },
                    color: kcPrimaryColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
