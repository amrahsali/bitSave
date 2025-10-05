// startup_viewmodel.dart (only showing the class body / imports as needed)
import 'dart:convert';
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/interceptors.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../state.dart';
import '../../../core/network/noodless_sdk.dart';
import '../../../core/utils/config.dart';
import '../../../core/utils/constant.dart';
import '../auth/auth_view.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:breez_liquid/breez_liquid.dart' as breez;


class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _auth = FirebaseAuth.instance;
  final _secureStorage = const FlutterSecureStorage();

  // Place anything here that needs to happen before we get into the application
  Future runStartupLogic() async {
    setBusy(true);
    try {
      // small delay to show splash nicely (optional)
      await Future.delayed(const Duration(seconds: 1));

      // 0) Initialize the rust bridge via the breez_liquid helper BEFORE any rust calls
      try {
        await breez.initialize(); // <-- this calls RustLib.init(...) internally
        print('breez_liquid rust bridge initialized');
      } catch (e, st) {
        print('Failed to initialize breez_liquid rust bridge: $e\n$st');
        // continue but be aware SDK features may not work if init actually failed
      }

      // 1) Secure storage: read / create mnemonic
      final _secureStorage = const FlutterSecureStorage();
      var mnemonic = await _secureStorage.read(key: "mnemonic");
      if (mnemonic == null) {
        mnemonic = bip39.generateMnemonic();
        await _secureStorage.write(key: "mnemonic", value: mnemonic);
      }

      // 2) Create and connect SDK (now safe because rust bridge was initialized)
      final sdk = NodelessSdk();
      // If you want to reuse sdk across app:
      // locator.registerSingleton<NodelessSdk>(sdk);

      // initialize streams that call into rust
      sdk.initializeLogStream();

      final config = await getConfig(
        network: LiquidNetwork.mainnet,
        breezApiKey: breezApiKey,
      );
      final req = ConnectRequest(mnemonic: mnemonic, config: config);
      await sdk.connect(req: req);

      // 3) Proceed with auth/navigation logic
      final user = _auth.currentUser;
      if (user != null) {
        userLoggedIn.value = true;
        String? userJson =
        await locator<LocalStorage>().fetch(LocalStorageDir.authUser);
        if (userJson != null) {
          profile.value =
              User.fromJson(Map<String, dynamic>.from(jsonDecode(userJson)));
        }
        _navigationService.clearStackAndShow(Routes.homeView);
      } else {
        _navigationService.replaceWithAuthView(authType: AuthType.adminLogin);
      }
    } catch (e, st) {
      print('Startup init error: $e\n$st');
      // fallback to auth to avoid blocking the user
      _navigationService.replaceWithAuthView(authType: AuthType.adminLogin);
    } finally {
      setBusy(false);
    }
  }

  void getProfile() async {
    try {
      ApiResponse res = await repo.getProfile();
      if (res.statusCode == 200) {
        profile.value =
            User.fromJson(Map<String, dynamic>.from(res.data['data']));
        await locator<LocalStorage>()
            .save(LocalStorageDir.profileView, res.data["data"]);
        notifyListeners();
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}