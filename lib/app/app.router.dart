// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:flutter/foundation.dart' as _i23;
import 'package:flutter/material.dart' as _i21;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i27;

import '../core/data/models/invite_model.dart';
import '../ui/views/Profile/profile_view.dart' as _i8;
import '../ui/views/auth/auth_view.dart' as _i5;
import '../ui/views/auth/auth_view.dart';
import '../ui/views/dashboard/dashboard_view.dart' as _i6;
// import '../ui/views/guest/code_view.dart' as _i7;
import '../ui/views/home/home_view.dart' as _i2;
import '../ui/views/reports/reports.dart' as _i7;
import '../ui/views/reports/savings.dart' as _i9;
import '../ui/views/startup/startup_view.dart' as _i3;


/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///

class Routes {
  static const homeView = '/home-view';

  static const startupView = '/startup-view';

  static const codeView = '/code-view';

  static const onboardingView = '/onboarding-view';

  static const authView = '/auth-view';

  static const dashboardView = '/dashboard-view';

  static const reportsView = '/reports-view';

  static const notificationView = '/notification-view';

  static const registerView = '/register-view';

  static const profileView = '/profile-view';

  static const successView = '/success-view';

  static const saving = '/savings-view';

  static const all = <String>{
    homeView,
    startupView,
    onboardingView,
    authView,
    codeView,
    dashboardView,
    notificationView,
    registerView,
    successView,
    reportsView,
    profileView,
    saving,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      Routes.homeView,
      page: _i2.HomeView,
    ),
    _i1.RouteDef(
      Routes.startupView,
      page: _i3.StartupView,
    ),
    _i1.RouteDef(
      Routes.reportsView,
      page: _i7.Reports,
    ),
    _i1.RouteDef(
      Routes.authView,
      page: _i5.AuthView,
    ),
    _i1.RouteDef(
      Routes.dashboardView,
      page: _i6.DashboardView,
    ),
    _i1.RouteDef(
      Routes.profileView,
      page: _i8.UserProfilePage,
    ),

    _i1.RouteDef(
      Routes.saving,
      page: _i9.Savings,
    ),
    // _i1.RouteDef(
    //   Routes.profileView,
    //   page: _i10.ProfileView,
    // ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.HomeView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i2.HomeView(),
        settings: data,
      );
    },

    _i3.StartupView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i3.StartupView(),
        settings: data,
      );
    },

    _i7.Reports: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i7.Reports(),
        settings: data,
      );
    },
    _i8.UserProfilePage: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => _i8.UserProfilePage(),
        settings: data,
      );
    },
    _i5.AuthView: (data) {
      final args = data.getArgs<AuthViewArguments>(nullOk: false);
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => _i5.AuthView(authType: args.authType),
        settings: data,
      );
    },
    // _i12.RaffleDetail: (data) {
    //   final args = data.getArgs<RaffleDetailArguments>(nullOk: false);
    //   return _i21.MaterialPageRoute<dynamic>(
    //     builder: (context) =>
    //         _i12.RaffleDetail(raffle: args.raffle, key: args.key),
    //     settings: data,
    //   );
    // },
    _i6.DashboardView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) =>  _i6.DashboardView(),
        settings: data,
      );
    },
    //
    _i9.Savings: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i9.Savings(),
        settings: data,
      );
    },
    // _i10.ProfileView: (data) {
    //   return _i21.MaterialPageRoute<dynamic>(
    //     builder: (context) => const _i10.ProfileView(),
    //     settings: data,
    //   );
    // },

    // _i16.OtpView: (data) {
    //   final args = data.getArgs<OtpViewArguments>(nullOk: false);
    //   return _i21.MaterialPageRoute<dynamic>(
    //     builder: (context) => _i16.OtpView(email: args.email, key: args.key),
    //     settings: data,
    //   );
    // },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;
  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class CodeViewArguments {
  const CodeViewArguments({
    required this.invite,
  });

  final GuestInviteModel invite;

  @override
  String toString() {
    return '{"invite": "$invite"}';
  }

  @override
  bool operator ==(covariant CodeViewArguments other) {
    if (identical(this, other)) return true;
    return other.invite == invite;
  }

  @override
  int get hashCode {
    return invite.hashCode;
  }
}

class AuthViewArguments {
  const AuthViewArguments({
    required this.authType,
    this.key,
  });

  final AuthType authType;

  final _i23.Key? key;

  @override
  String toString() {
    return '{"authType": "$authType", "key": "$key"}';
  }

  @override
  bool operator ==(covariant AuthViewArguments other) {
    if (identical(this, other)) return true;
    return other.authType == authType && other.key == key;
  }

  @override
  int get hashCode {
    return authType.hashCode ^ key.hashCode;
  }
}

extension NavigatorStateExtension on _i27.NavigationService {
  Future<dynamic> navigateToHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }


  Future<dynamic> navigateToOnboardingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return navigateTo<dynamic>(Routes.onboardingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToProfileView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return navigateTo<dynamic>(Routes.profileView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAuthView({
    _i23.Key? key,
    required AuthType authType,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(Routes.authView,
        arguments: AuthViewArguments(authType: authType, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }


  Future<dynamic> navigateToRegisterView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return navigateTo<dynamic>(Routes.registerView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToDashboardView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.dashboardView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToNotificationView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.notificationView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  // Future<dynamic> navigateToProfileView([
  //   int? routerId,
  //   bool preventDuplicates = true,
  //   Map<String, String>? parameters,
  //   Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
  //       transition,
  // ]) async {
  //   return navigateTo<dynamic>(Routes.profileView,
  //       id: routerId,
  //       preventDuplicates: preventDuplicates,
  //       parameters: parameters,
  //       transition: transition);
  // }


  Future<dynamic> replaceWithHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }


  Future<dynamic> replaceWithOnboardingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return replaceWith<dynamic>(Routes.onboardingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithProfileView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return replaceWith<dynamic>(Routes.profileView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAuthView({
    _i23.Key? key,
    required AuthType authType,
    int? initialIndex,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(Routes.authView,
        arguments: AuthViewArguments(authType: authType, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithDashboardView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.dashboardView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithNotificationView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.notificationView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  // Future<dynamic> replaceWithProfileView([
  //   int? routerId,
  //   bool preventDuplicates = true,
  //   Map<String, String>? parameters,
  //   Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
  //       transition,
  // ]) async {
  //   return replaceWith<dynamic>(Routes.profileView,
  //       id: routerId,
  //       preventDuplicates: preventDuplicates,
  //       parameters: parameters,
  //       transition: transition);
  // }
}
