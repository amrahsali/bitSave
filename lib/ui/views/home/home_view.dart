import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../state.dart';
import '../../../app/app.router.dart';
import '../../../app/app.locator.dart';
import '../../common/app_colors.dart';
import '../../components/submit_button.dart';
import '../../dialogs/bottom_sheets/emergency_bottom_sheet.dart';
import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, viewModel),
      body: PageView(
        controller: viewModel.pageController,
        physics: const NeverScrollableScrollPhysics(), // Prevent swipe navigation
        children: viewModel.pages, // Pages controlled by BottomNav
      ),
      bottomNavigationBar: _buildBottomNavigationBar(viewModel),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, HomeViewModel viewModel) {
    return AppBar(
      toolbarHeight: 50,
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // SvgPicture.asset(
          //   'assets/icons/esures_logo.svg',
          //   height: 40,
          //   width: 40,
          // ),
          Text(
            'BitSave',
            style: GoogleFonts.redHatDisplay(
              color: kcPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                builder: (context) => const CreateEmergencySheet(),
              );
            },
            child: SvgPicture.asset(
              'assets/svg_icons/ph_bell-simple.svg',
              height: 35,
              width: 35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(HomeViewModel viewModel) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: viewModel.selectedIndex,
      onTap: (index) => viewModel.changeSelectedPage(index),
      selectedItemColor:kcPrimaryColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.savings),
          label: 'Savings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.insights),
          label: 'Insights',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Invite',
        ),
      ],
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}