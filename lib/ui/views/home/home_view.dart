import 'package:bitSave/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_colors.dart';
import '../../dialogs/bottom_sheets/emergency_bottom_sheet.dart';
import 'home_viewmodel.dart';
import '../../../state.dart';
import '../../../app/app.locator.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../core/utils/local_store_dir.dart';


class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    return Scaffold(
      appBar: _buildAppBar(context, viewModel),
      body: PageView(
        controller: viewModel.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: viewModel.pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(viewModel),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, HomeViewModel viewModel) {
    return AppBar(
      toolbarHeight: 50,
      // backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'BitSave',
            style: GoogleFonts.redHatDisplay(
              color: Theme.of(context).brightness == Brightness.dark ? kcBlackColor : kcPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),

          Row(
            children: [
              // 🌙 Theme Toggle
              ValueListenableBuilder<AppUiModes>(
                valueListenable: uiMode,
                builder: (context, mode, _) {
                  final isDark = mode == AppUiModes.dark;
                  return IconButton(
                    tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
                    onPressed: () async {
                      uiMode.value = isDark ? AppUiModes.light : AppUiModes.dark;

                      // update system UI overlay
                      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                        statusBarColor: Colors.transparent,
                        statusBarIconBrightness: uiMode.value == AppUiModes.dark
                            ? Brightness.light
                            : Brightness.dark,
                        statusBarBrightness: uiMode.value == AppUiModes.dark
                            ? Brightness.dark
                            : Brightness.light,
                      ));

                      try {
                        await locator<LocalStorage>().save(
                          LocalStorageDir.uiMode,
                          uiMode.value == AppUiModes.dark ? 'dark' : 'light',
                        );
                      } catch (e) {
                        // ignore if saving fails
                      }
                    },
                    icon: Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? kcBlackColor
                          : kcPrimaryColor,
                    ),
                  );
                },
              ),
              // 🤖 AI Icon
              IconButton(
                tooltip: 'Ask AI',
                onPressed: () {
                  // TODO: open your AI assistant page or dialog
                },
                icon: Icon(
                  Icons.smart_toy_rounded, // You can also use Icons.auto_awesome
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kcBlackColor
                      : kcPrimaryColor,
                ),
              ),
            ],
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