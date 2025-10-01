import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_colors.dart';
import '../../components/submit_button.dart';
import '../../views/dashboard/dashboard_viewmodel.dart';
import '../../views/home/home_viewmodel.dart';

class CreateEmergencySheet extends StatefulWidget {
  const CreateEmergencySheet({super.key});

  @override
  State<CreateEmergencySheet> createState() => _CreateEmergencySheetState();
}

class _CreateEmergencySheetState extends State<CreateEmergencySheet> {

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
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
                    "What's the emergency?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: kcPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: viewModel.emergencyOptions.map((option) {
                      final bool isSelected = viewModel.selectedEmergencyLabel == option['label'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            viewModel.selectedEmergencyLabel = option['label'];
                          });
                        },
                        child: Container(
                          width: 85,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected ? kcPrimaryColor.withOpacity(0.1) : Colors.grey.shade100,
                            border: Border.all(
                              color: isSelected ? kcPrimaryColor : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                option['icon'],
                                color: isSelected ? kcPrimaryColor : Colors.black87,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                option['label'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: isSelected ? kcPrimaryColor : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: viewModel.notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Optional notes (e.g. location, more details)...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ///TODO extend this feature to include call in app vai firebase
                  SubmitButton(
                    isLoading: viewModel.isCreateEmergencyLoading,
                    boldText: true,
                    label: "Create Emergency",
                    submit: () async {
                      // await viewModel.createEmergency(viewModel.selectedEmergencyLabel, context);
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
