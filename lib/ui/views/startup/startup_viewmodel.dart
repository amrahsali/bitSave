import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/interceptors.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../state.dart';
import '../auth/auth_view.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _auth = FirebaseAuth.instance;

  // Place anything here that needs to happen before we get into the application
  Future runStartupLogic() async {
    await Future.delayed(const Duration(seconds: 3));

    final user = _auth.currentUser;

    if (user != null) {
      // User is logged in
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
