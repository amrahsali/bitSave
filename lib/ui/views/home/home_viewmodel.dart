
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/interceptors.dart';
import '../../../state.dart';
import '../dashboard/dashboard_view.dart';
import '../profile/profile_view.dart';
import '../reports/reports.dart';
import '../reports/savings.dart';

class HomeViewModel extends BaseViewModel {
  final log = getLogger("HomeViewModel");

  int selectedIndex = 0;
  bool isCreateEmergencyLoading = false;
  CancelableOperation? _emergencyOperation;
  final PageController pageController = PageController();

  final List<Map<String, dynamic>> emergencyOptions = [
    {'label': 'Medical', 'icon': Icons.local_hospital, 'id': 1},
    {'label': 'Fire', 'icon': Icons.local_fire_department, 'id': 2},
    {'label': 'Crime', 'icon': Icons.warning, 'id': 3},
    {'label': 'Noise', 'icon': Icons.noise_control_off, 'id': 4},
    {'label': 'Other', 'icon': Icons.help_outline, 'id': 5},
  ];

  String? selectedEmergencyLabel = "Medical";
  final TextEditingController notesController = TextEditingController();



  final List<Widget> pages = [
    DashboardView(), // Dashboard
    Savings(),// Home
    const Reports(), // Reports
    UserProfilePage(), // Profile
  ];

  void changeSelectedPage(int index) {
    selectedIndex = index;
    pageController.jumpToPage(index);
    rebuildUi();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }


  Future<bool> createEmergency(String? label, BuildContext context) async {
    setBusy(true);
    isCreateEmergencyLoading = true;
    notifyListeners();
    _emergencyOperation?.cancel();

    try {
      _emergencyOperation = CancelableOperation.fromFuture(
        repo.createEmergency(
            {
              "type": label,
              "description": notesController.text,
            }
        ),
        onCancel: () {
          log.i('Emergency creation was cancelled.');
          isCreateEmergencyLoading = false;
        },
      );

      ApiResponse res = await _emergencyOperation!.value;

      print('value of reg response is : ${res.data}');

      if (res.statusCode == 200) {
        locator<SnackbarService>().showSnackbar(
          message: "Emergency successfully, all residents will receive a notification",
          duration: const Duration(seconds: 3),
        );
        Navigator.pop(context);
        return true;
      } else {
        log.e('API request failed with status: ${res.statusCode}');
        return false;
      }
    } catch (e) {
      log.e('Failed to create visitor. Please try again: $e');
      return false;
    } finally {
      setBusy(false);
      isCreateEmergencyLoading = false;
      notifyListeners();
    }
  }
}
