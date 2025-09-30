import 'package:bip39/bip39.dart' as bip39;
import 'package:bitSave/state.dart';
import 'package:bitSave/ui/common/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'app/app.dialogs.dart';
import 'app/app.locator.dart';
import 'app/app.router.dart';
import 'core/network/noodless_sdk.dart';
import 'core/utils/config.dart';
import 'core/utils/constant.dart';
import 'core/utils/local_store_dir.dart';
import 'core/utils/local_stotage.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initialize();
  final NodelessSdk sdk = NodelessSdk();
  const secureStorage = FlutterSecureStorage();
  var mnemonic = await secureStorage.read(key: "mnemonic");
  if (mnemonic == null) {
    mnemonic = bip39.generateMnemonic();
    secureStorage.write(key: "mnemonic", value: mnemonic);
  }
   setupLocator();

  await reconnect(sdk: sdk, mnemonic: mnemonic);

  runApp( MyApp(sdk: sdk));
}
Future<void> reconnect({
  required NodelessSdk sdk,
  required String mnemonic,
  LiquidNetwork network = LiquidNetwork.mainnet,
}) async {
  final config = await getConfig(
    network: network,
    breezApiKey: breezApiKey,
  );
  final req = ConnectRequest(
    mnemonic: mnemonic,
    config: config,
  );
  await sdk.connect(req: req);
}


class MyApp extends StatefulWidget {
  final NodelessSdk sdk;

  const MyApp({Key? key, required this.sdk}) : super(key: key);


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
  BoxDecoration _getBackgroundDecoration(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? kcDarkBackgroundDecoration
        : kcLightBackgroundDecoration;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUiModes>(
      valueListenable: uiMode,
      builder: (context, value, child) => MaterialApp(
        title: 'bitSave',
        // theme: value == AppUiModes.dark ? darkTheme() : lightTheme(),
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: value == AppUiModes.dark ? ThemeMode.dark : ThemeMode.light,
        initialRoute: Routes.startupView,
        onGenerateRoute: StackedRouter().onGenerateRoute,
        navigatorKey: StackedService.navigatorKey,
        debugShowCheckedModeBanner: false,
        navigatorObservers: [
          StackedService.routeObserver,
        ],
        builder: (context, child) {
          return Container(
            decoration: _getBackgroundDecoration(context),
            child: child!,
          );
        },
      ),
    );
  }

ThemeData _buildLightTheme() {
  return ThemeData.light(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: Colors.transparent, // Make scaffold transparent
    appBarTheme: AppBarTheme(
      backgroundColor: kcWhiteColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: kcBlackColor),
      titleTextStyle: GoogleFonts.redHatDisplay(
        color: kcBlackColor,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: kcWhiteColor,
      selectedItemColor: kcPrimaryColor,
      unselectedItemColor: Colors.grey,
    ),
  );
}

ThemeData _buildDarkTheme() {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: kcWhiteColor),
      titleTextStyle: GoogleFonts.redHatDisplay(
        color: kcWhiteColor,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: kcWhiteColor,
      unselectedItemColor: kcWhiteColor.withOpacity(0.5),
    ),
  );
}
}
