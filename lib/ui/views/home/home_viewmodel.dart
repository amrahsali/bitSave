
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
    DashboardView( ), // Dashboard
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

}
