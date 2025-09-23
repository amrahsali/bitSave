import 'package:estate360Security/ui/components/submit_button.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../common/app_colors.dart';
import '../common/ui_helpers.dart';
import '../views/dashboard/dashboard_viewmodel.dart';

class ScheduleVisitDialog extends StatefulWidget {
  final DashboardViewModel model;
  ScheduleVisitDialog({
    Key? key,
    required this.model,
  }) : super(key: key);

  @override
  _ScheduleVisitDialogState createState() => _ScheduleVisitDialogState();
}

class _ScheduleVisitDialogState extends State<ScheduleVisitDialog> {
  bool isLoading = false;
  String? errorMessage;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kcWhiteColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Red box
          // Title
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Visitation Code",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    // color: kcSecondaryColor,
                  ),
                ),
                SizedBox(height: 10),
                // Description
                Text(
                  "Input visitor's code, for Verification",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          verticalSpaceSmall,
          if (errorMessage != null)
            Text(
              errorMessage!,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          verticalSpaceSmall,
          PinCodeTextField(
            appContext: context,
            length: 5,
            obscureText: false,
            animationType: AnimationType.fade,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(10),
              fieldHeight: 60,
              fieldWidth: 45,
              activeFillColor: Colors.white,
              inactiveFillColor: Colors.white,
              selectedFillColor: Colors.white,
              activeColor: Colors.black,
              selectedColor: Colors.black,
              inactiveColor: Colors.black26,
            ),
            animationDuration: Duration(milliseconds: 300),
            backgroundColor: Colors.transparent,
            enableActiveFill: true,
            //controller: widget.model.visitCodeController,
            onCompleted: (value) {
              widget.model.verifyCode(context, value,
                  onFailure: (String reason) {
                    setState(() {
                      errorMessage = reason; // Set specific error message
                    });
                  }); // Corrected this line
            },
            onChanged: (value) {
              // Handle change if you need to
              if (errorMessage != null) {
                setState(() {
                  errorMessage = null; // Clear error message on input change
                });
              }
            },
            beforeTextPaste: (text) {
              // If you want to prevent clipboard pasting return false
              return true;
            },
          ),
          verticalSpace(30),

          SubmitButton(
            isLoading: isLoading,
            boldText: true,
            label: "Verify",
            submit: () {
              widget.model.verifyCode;
            },
            color: kcPrimaryColor,
          ),
        ],
      ),
    );
  }
}