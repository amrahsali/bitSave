import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class CodeInputWidget extends StatelessWidget {
  final TextEditingController codeController;
  final Function(String) onCompleted;

  CodeInputWidget({required this.codeController, required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: 6,
      obscureText: false,
      animationType: AnimationType.fade,
      textStyle: const TextStyle(color: Colors.white, fontSize: 20),
      keyboardType: TextInputType.number,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(10),
        fieldHeight: 52,
        fieldWidth: 45,
        activeFillColor: const Color(0xFF3B3B3B),
        inactiveFillColor: const Color(0xFF3B3B3B),
        selectedFillColor: const Color(0xFF3B3B3B),
        activeColor: Colors.transparent,
        selectedColor: Colors.transparent,
        inactiveColor: Colors.transparent,
      ),
      animationDuration: const Duration(milliseconds: 300),
      backgroundColor: Colors.transparent,
      enableActiveFill: true,
      controller: codeController,
      onCompleted: onCompleted,
      onChanged: (value) {
        // Handle change if you need to
      },
      beforeTextPaste: (text) {
        // If you want to prevent clipboard pasting return false
        return true;
      },
    );
  }
}
