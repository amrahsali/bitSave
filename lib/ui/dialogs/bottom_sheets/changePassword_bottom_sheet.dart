import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../components/submit_button.dart';
import '../../components/text_field_widget.dart';
import '../../views/Profile/profile_viewmodel.dart';

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {

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
                    "Change Password",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: kcPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.shade50, // light blue background
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 2.0, right: 8.0),
                          child: Icon(
                            Icons.sticky_note_2, // "note" icon
                            size: 18,
                            color: Colors.lightBlue, // icon color
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "New Password must be at least 8 characters long, contain a symbol, a capital letter and a number.",
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.2,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  verticalSpaceSmall,
                  TextFieldWidget(
                    obscureText: viewModel.obscure,
                    hint: " Old Password",
                    controller: viewModel.oldPassword,
                    suffix: InkWell(
                      onTap: () {
                        viewModel.toggleObscure();
                      },
                      child: Icon(viewModel.obscure
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                  ),
                  verticalSpaceSmall,
                  TextFieldWidget(
                    obscureText: viewModel.obscure,
                    hint: " New Password",
                    controller: viewModel.newPassword,
                    suffix: InkWell(
                      onTap: () {
                        viewModel.toggleObscure();
                      },
                      child: Icon(viewModel.obscure
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                  ),
                  verticalSpaceSmall,
                  TextFieldWidget(
                    obscureText: viewModel.obscure,
                    hint: " Confirm Password",
                    controller: viewModel.confirmPassword,
                    suffix: InkWell(
                      onTap: () {
                        viewModel.toggleObscure();
                      },
                      child: Icon(viewModel.obscure
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SubmitButton(
                    isLoading: viewModel.isChangePasswordLoading,
                    boldText: true,
                    label: "Change Password",
                    submit: () async {

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