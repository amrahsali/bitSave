import 'package:estate360Security/state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'app/app.dialogs.dart';
import 'app/app.locator.dart';
import 'app/app.router.dart';
import 'core/utils/local_store_dir.dart';
import 'core/utils/local_stotage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();
  setupDialogUi();
  FirebaseMessaging.instance.requestPermission();
  FlutterError.onError = (errorDetails) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  };
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    fetchUiState();
    super.initState();
  }

  void fetchUiState() async {
    String? savedMode =
    await locator<LocalStorage>().fetch(LocalStorageDir.uiMode);
    if (savedMode != null) {
      switch (savedMode) {
        case "light":
          uiMode.value = AppUiModes.light;
          break;
        case "dark":
          uiMode.value = AppUiModes.dark;
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUiModes>(
      valueListenable: uiMode,
      builder: (context, value, child) => MaterialApp(
        title: 'Estate360 Security',
        // theme: value == AppUiModes.dark ? darkTheme() : lightTheme(),
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(),
        themeMode: value == AppUiModes.dark ? ThemeMode.dark : ThemeMode.light,
        initialRoute: Routes.startupView,
        onGenerateRoute: StackedRouter().onGenerateRoute,
        navigatorKey: StackedService.navigatorKey,
        debugShowCheckedModeBanner: false,
        navigatorObservers: [
          StackedService.routeObserver,
        ],
      ),
    );
  }
}
