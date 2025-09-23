import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stacked/stacked.dart';

import 'startup_viewmodel.dart';

class StartupView extends StackedView<StartupViewModel> {
  const StartupView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context,
      StartupViewModel viewModel,
      Widget? child,
      ) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/LoadPage.png",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Image.asset('assets/images/escure.png'),
          ),
        ],
      ),
    );

  }

  @override
  StartupViewModel viewModelBuilder(BuildContext context) =>
      StartupViewModel();

  @override
  void onViewModelReady(StartupViewModel viewModel) =>
      SchedulerBinding.instance.addPostFrameCallback(
              (timeStamp) => viewModel.runStartupLogic());
}
