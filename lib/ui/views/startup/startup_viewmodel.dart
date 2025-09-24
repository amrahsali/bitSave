import 'dart:convert';
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

  // Place anything here that needs to happen before we get into the application
  Future runStartupLogic() async {
    await Future.delayed(const Duration(seconds: 3));

    String? token = await locator<LocalStorage>().fetch(LocalStorageDir.authToken);
    String? user = await locator<LocalStorage>().fetch(LocalStorageDir.authUser);
    bool? onboarded = await locator<LocalStorage>().fetch(LocalStorageDir.onboarded);
    print('value of token is: $token');
    print('value of user is: $user');
    if (token != null && user != null) {
      userLoggedIn.value = true;
      profile.value = User.fromJson(Map<String, dynamic>.from(jsonDecode(user)));
      // getProfile();
      _navigationService.clearStackAndShow(Routes.homeView);
    }
    else{
      _navigationService.replaceWithAuthView(authType: AuthType.adminLogin);
    }

    // if (onboarded == null || onboarded == false) {
    //   _navigationService.replaceWithAuthView(authType: AuthType.selection);
    //   // _navigationService.replaceWithOnboardingView();
    // } else {
    //   if (token != null && user != null) {
    //     userLoggedIn.value = true;
    //     profile.value = User.fromJson(Map<String, dynamic>.from(jsonDecode(user)));
    //     getProfile();
    //      _navigationService.replaceWithHomeView();
    //   }
    //   _navigationService.replaceWithAuthView(authType: AuthType.login);
    // }
  }

  void getProfile() async {
    try {
      ApiResponse res = await repo.getProfile();
      if (res.statusCode == 200) {
        profile.value =
            User.fromJson(Map<String, dynamic>.from(res.data['data']));
        await locator<LocalStorage>().save(LocalStorageDir.profileView, res.data["data"]);
        notifyListeners();
      }
    } catch (e) {
      throw Exception(e);
    }
  }


}
