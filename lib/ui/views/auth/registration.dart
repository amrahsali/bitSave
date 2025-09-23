import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../components/submit_button.dart';
import '../../components/text_field_widget.dart';
import 'auth_view.dart';
import 'auth_viewmodel.dart';



class RegisterScreen extends  StatefulWidget {
  final Function(AuthType, {String? email}) onSwitch;

  const RegisterScreen({required this.onSwitch});

  @override
  State<RegisterScreen> createState() => _RegisterState();

}

class _RegisterState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Scaffold(
        body: ViewModelBuilder<AuthViewModel>.reactive(
          onViewModelReady: (model) {
            model.getEstates();
          },
          viewModelBuilder: () => AuthViewModel(),
          builder: (context, model, child) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: kcPrimaryColor, width: 2), // Add border
                        borderRadius:
                        BorderRadius.circular(10), // Optional rounded corners
                        image: DecorationImage(
                          image: AssetImage('assets/images/header-image.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Registration',
                            style: TextStyle(
                                color: kcWhiteColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          // Container(
                          //   width: 60,
                          //   height: 40,
                          //   decoration: BoxDecoration(
                          //     color: Colors.blue, // Background color
                          //     borderRadius: BorderRadius.circular(
                          //         8), // Optional: Rounded corners
                          //   ),
                          //   child: Center(
                          //     child: const Text(
                          //       "back",
                          //       style: TextStyle(
                          //         color: kcWhiteColor,
                          //         fontSize: 16,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  const Text(
                    "Create an account so you can esplore our hight quality services",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                    ),
                  ),
                  verticalSpaceMedium,
                  TextFieldWidget(
                    hint: "Email Address",
                    controller: model.email,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'required';
                      }
                      if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value)) {
                        return 'Invalid email address';
                      }
                      return null; // Return null to indicate no validation error
                    },
                  ),
                  verticalSpaceSmall,
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: TextFieldWidget(
                  //         hint: "Firstname",
                  //         controller: model.firstname,
                  //         inputType: TextInputType.name,
                  //         validator: (value) {
                  //           if (value.isEmpty) {
                  //             return 'required';
                  //           }
                  //           return null; // Return null to indicate no validation error
                  //         },
                  //       ),
                  //     ),
                  //     const SizedBox(
                  //       width: 5,
                  //     ),
                  //     Expanded(
                  //       child: TextFieldWidget(
                  //         hint: "Lastname",
                  //         controller: model.lastname,
                  //         validator: (value) {
                  //           if (value.isEmpty) {
                  //             return 'required';
                  //           }
                  //           return null; // Return null to indicate no validation error
                  //         },
                  //       ),
                  //     ),
                  //     verticalSpaceSmall,
                  //   ],
                  // ),
                  // verticalSpaceSmall,
                  // IntlPhoneField(
                  //   decoration: InputDecoration(
                  //     labelText: 'Phone Number',
                  //     labelStyle: const TextStyle(color: Colors.black, fontSize: 13),
                  //     floatingLabelStyle: const TextStyle(color: kcLightGrey),
                  //     filled: true, // Ensure the background is filled
                  //     fillColor: Colors.white, // Set background color to white
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(10.0), // Add border curve
                  //       borderSide: const BorderSide(color: kcLightGrey), // Default grey border
                  //     ),
                  //     enabledBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(10.0), // Add border curve
                  //       borderSide: const BorderSide(color: Colors.grey), // Default grey border when not focused
                  //     ),
                  //     focusedBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(10.0), // Add border curve
                  //       borderSide: const BorderSide(color: Color(0xFFCC9933)), // Border color on focus
                  //     ),
                  //   ),
                  //   validator: (value) {
                  //     if (value == null || value.completeNumber.isEmpty) {
                  //       return 'Required';
                  //     }
                  //     return null; // Return null to indicate no validation error
                  //   },
                  //   initialCountryCode: 'NG',
                  //   controller: model.phone,
                  //   onChanged: (phone) {
                  //     model.phoneNumber = phone;
                  //     print('Phone code is: ${phone.countryISOCode}');
                  //   },
                  // ),
                  // Autocomplete<String>(
                  //   optionsBuilder: (TextEditingValue textEditingValue) {
                  //     if (textEditingValue.text.isEmpty) {
                  //       return const Iterable<String>.empty();
                  //     }
                  //     return model.estates
                  //         .where((estate) => (estate.estateName ?? "")
                  //         .toLowerCase()
                  //         .contains(textEditingValue.text.toLowerCase()))
                  //         .map((estate) => estate.estateName ?? "");
                  //   },
                  //   onSelected: (String selectedEstate) {
                  //     model.estateController.text = selectedEstate;
                  //     final selectedEstateObj = model.estates.firstWhere(
                  //           (estate) => estate.estateName == selectedEstate,
                  //       orElse: () => Estate(estateName: "Estate not found"), // Returns null if no match is found
                  //     );
                  //
                  //     model.selectedEstateId = selectedEstateObj.id ?? "";
                  //     model.getApartments(model.selectedEstateId);
                  //   },
                  //   fieldViewBuilder:
                  //       (context, textEditingController, focusNode, onFieldSubmitted) {
                  //     return TextFieldWidget(
                  //       hint: "Select Estate",
                  //       controller: textEditingController,  // Use textEditingController
                  //       focusNode: focusNode,               // Use focusNode to manage dropdown
                  //       validator: (value) =>
                  //       value.isEmpty ? 'Estate selection is required' : null,
                  //       onChanged: (text) {
                  //         // if (!model.estates
                  //         //     .map((estate) => estate.estateName)
                  //         //     .contains(text)) {
                  //         //   focusNode.unfocus(); // Close dropdown if no match
                  //         // }
                  //       },
                  //     );
                  //   },
                  //   optionsViewBuilder: (context, onSelected, options) {
                  //     return Align(
                  //       alignment: Alignment.topLeft,
                  //       child: Material(
                  //         elevation: 4.0,
                  //         borderRadius: BorderRadius.circular(10),
                  //         child: SizedBox(
                  //           width: MediaQuery.of(context).size.width - 50,
                  //           child: ListView.builder(
                  //             padding: EdgeInsets.zero,
                  //             itemCount: options.length,
                  //             itemBuilder: (context, index) {
                  //               final String option = options.elementAt(index);
                  //               return ListTile(
                  //                 title: Text(option),
                  //                 onTap: () => onSelected(option),
                  //               );
                  //             },
                  //           ),
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                  // verticalSpaceSmall,
                  // DropdownButtonFormField<Apartment>(
                  //   decoration: InputDecoration(
                  //     labelText: "Select Apartment",
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //   ),
                  //   value: model.selectedApartment,
                  //   onChanged: (Apartment? newValue) {
                  //     if (newValue != null) {
                  //       setState(() {
                  //         model.selectedApartment = newValue;
                  //       });
                  //     }
                  //   },
                  //   items: model.apartments.map<DropdownMenuItem<Apartment>>((Apartment value) {
                  //     return DropdownMenuItem<Apartment>(
                  //       value: value,
                  //       child: Text("${value.apartmentNumber} - ${value.apartmentAddress}"),
                  //     );
                  //   }).toList(),
                  //   validator: (value) => value == null ? 'Apartment selection is required' : null,
                  // ),
                  verticalSpaceSmall,
                  TextFieldWidget(
                    inputType: TextInputType.visiblePassword,
                    hint: "Password",
                    controller: model.password,
                    obscureText: model.obscure,
                    suffix: InkWell(
                      onTap: () {
                        model.toggleObscure();
                      },
                      child:
                      Icon(model.obscure ? Icons.visibility_off : Icons.visibility),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters long';
                      }
                      if (!RegExp(r'[A-Z]').hasMatch(value)) {
                        return 'Password must contain at least one uppercase letter';
                      }
                      if (!RegExp(r'[a-z]').hasMatch(value)) {
                        return 'Password must contain at least one lowercase letter';
                      }
                      if (!RegExp(r'[0-9]').hasMatch(value)) {
                        return 'Password must contain at least one digit';
                      }
                      if (!RegExp(r'[!@#$%^&*]').hasMatch(value)) {
                        return 'Password must contain at least one special character';
                      }
                      return null; // Return null to indicate no validation error
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text( style: TextStyle(
                      fontSize: 11,
                    ),
                        "At least 8 characters, including letters and numbers"),
                  ),
                  verticalSpaceSmall,
                  TextFieldWidget(
                    hint: "Confirm password",
                    controller: model.cPassword,
                    obscureText: model.obscure,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Password confirmation is required';
                      }
                      if (value != model.password.text) {
                        return 'Passwords do not match';
                      }
                      return null; // Return null to indicate no validation error
                    },
                    suffix: InkWell(
                      onTap: () {
                        model.toggleObscure();
                      },
                      child:
                      Icon(model.obscure ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                  verticalSpaceSmall,
                  SubmitButton(
                    isLoading: model.isBusy,
                    label: "Next",
                    submit: ()  {
                      //
                      // if (_formKey.currentState!.validate()) {
                      //   await model.register(widget.onSwitch);
                      //
                      // }

                    },
                    color: kcPrimaryColor,
                    boldText: true,
                  ),
                  verticalSpaceSmall,
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:  [
                        const Text(
                          "Have an account? ",
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => widget.onSwitch(AuthType.login),
                          child: const Text(
                            "login here",
                            style: TextStyle(
                              fontSize: 16,
                              color: kcPrimaryColor,
                            ),
                          ),
                        )
                      ]
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
