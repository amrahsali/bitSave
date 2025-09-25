import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.2, -0.6), // move this is to remive thet a  zs the center slightly up-left
                  radius: 1.1, // how large the radial gradient spreads
                  colors: [
                    Color(0xFF432E9D),
                    Colors.black,
                  ],
                  stops: [0.0, 1.0],
                  // optionally you can use TileMode.clamp (default)
                ),
              ),
            ),
          ),

          // Center logo/image
          Center(
            child: Image.asset(
              'assets/images/bitsavelogo.png',
              // you can tweak size to taste:
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
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
        (timeStamp) => viewModel.runStartupLogic(),
      );
}
