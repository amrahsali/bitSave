import 'dart:ffi';

import 'package:estate360Security/core/data/repositories/repository_interface.dart';
import 'package:dio/dio.dart';

import '../../../app/app.locator.dart';
import '../../../state.dart';
import '../../network/api_response.dart';
import '../../network/api_service.dart';
import '../models/user_model.dart';
import 'dart:io';

class Repository extends IRepository {
  final api = locator<ApiService>();

  @override
  Future<ApiResponse> generatePaystackAccessCode({
    required String email,
    required int amount,
    String currency = "NGN",
    String reference = "",
  }) async {
    // const String secretKey = AppConfig.PAYSTACK_SECRET_KEY;
    final String apiUrl = "https://api.paystack.co/transaction/initialize";

    try {
      Dio dio = Dio();
      //dio.options.headers["Authorization"] = "Bearer $secretKey";
      dio.options.headers["Content-Type"] = "application/json";

      Response response = await dio.post(apiUrl, data: {
        "email": email,
        "amount": amount * 100, // Convert amount to kobo
        "currency": currency,
        "reference": reference.isNotEmpty
            ? reference
            : "afriprize_${DateTime.now().millisecondsSinceEpoch}"
      });

      if (response.statusCode == 200 && response.data['status'] == true) {
        return ApiResponse(response);
      } else {
        return ApiResponse(Response(
          requestOptions: RequestOptions(path: apiUrl),
          statusCode: response.statusCode ?? 400,
          data: {"message": response.data["message"] ?? "Unknown error"},
        ));
      }
    } catch (e) {
      print("Failed to generate access code: $e");
      return ApiResponse(Response(
        requestOptions: RequestOptions(path: apiUrl),
        statusCode: 500,
        data: {"message": "Failed to generate access code: $e"},
      ));
    }
  }

  @override
  Future<ApiResponse> login(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "auth/login",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> createEmergency(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "emergency/create",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> validateGatePass(String gatepass) async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "visitors/validate-gatepass?gatePassCode=$gatepass",
    );

    return response;
  }

  @override
  Future<ApiResponse> logOut() async {
    ApiResponse response =
        await api.call(method: HttpMethod.post, endpoint: "auth/logout");

    return response;
  }

  @override
  Future<ApiResponse> refresh(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
        method: HttpMethod.postRefresh,
        endpoint: "auth/refresh_tokens",
        reqBody: req);
    return response;
  }

  @override
  Future<ApiResponse> register(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "auth/signup/with_email",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> updateDeviceId(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "auth/user/${profile.value.id}/update-device",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> createFacility(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "facility/booking",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> createGuestInvite(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "invite/new",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> updateInviteStatus(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "visit-record/action",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> verify(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "/auth/verifycode",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> updateUser(
      Map<String, dynamic> req, String userId) async {
    ApiResponse response = await api.call(
      method: HttpMethod.put,
      endpoint: "user/$userId",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> sendOtp(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "auth/send_otp",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> getEstates() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "estate",
    );

    return response;
  }

  @override
  Future<ApiResponse> getDashboardData() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "estate/security-dashboard",
    );

    return response;
  }

  @override
  Future<ApiResponse> getResidents() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "user/all",
    );
    return response;
  }

  @override
  Future<ApiResponse> getApartments(String estateId) async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "estate/apartments?estate=$estateId",
    );

    return response;
  }

  @override
  Future<ApiResponse> getProfile() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "/auth/user/${profile.value.id}",
    );

    return response;
  }

  @override
  Future<ApiResponse> resetPasswordRequest(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "auth/resetpassword",
      reqBody: req,
    );
    return response;
  }

  @override
  Future<ApiResponse> verifyPasswordResetCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final Map<String, dynamic> reqBody = {
      'email': email,
      'code': code,
      'newPassword': newPassword,
    };

    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "auth/verifycode",
      reqBody: reqBody,
    );

    return response;
  }

  Future<ApiResponse> forgotPassword(Map<String, dynamic> data) async {
    return await api.call(
      method: HttpMethod.post,
      endpoint: "/auth/resetpassword",
      reqBody: data,
      protected: false,
    );

  }

  @override
  Future<ApiResponse> deleteAccount(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "user/delete",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> updateMedia(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "media/upload",
      useFormData: true,
      formData: FormData.fromMap(req),
    );

    return response;
  }

  @override
  Future<ApiResponse> updateProfilePicture(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "auth/${profile.value.id}/profile-picture",
      reqBody: req,
    );

    return response;
  }

  @override
  Future<ApiResponse> getNotifications() async {
    ApiResponse response = await api.call(
      method: HttpMethod.get,
      endpoint: "notifications/my-notifications",
    );

    return response;
  }

  //repo for mark as read on notification
  @override
  Future<ApiResponse> markNotificationAsRead() async {
    ApiResponse response = await api.call(
      method: HttpMethod.put,
      endpoint: "notifications/read",
    );

    return response;
  }

  @override
  Future<ApiResponse> escalateNotifications(int trackerId) async {
    ApiResponse response = await api.call(
      method: HttpMethod.patch,
      endpoint: "/notifications/$trackerId/approve",
    );
    return response;
  }

  @override
  Future<ApiResponse> changePassword(Map<String, String> map) async {
    ApiResponse response = await api.call(
        method: HttpMethod.post,
        endpoint: "/auth/${profile.value.id}/change-password",
        reqBody: map);
    return response;
  }

  Future<ApiResponse> updateProfile(Map<String, dynamic> req) async {
    ApiResponse response = await api.call(
      method: HttpMethod.post,
      endpoint: "/auth/update-bio-data",
      useFormData: true,
      formData: FormData.fromMap(req),
    );

    return response;
  }

  @override
  Future<ApiResponse> updateProfilePictureMultipart(Map<String, dynamic> req, String userId) async {
    return await api.call(
      method: HttpMethod.post,
      endpoint: 'auth/$userId/profile-picture',
      formData: FormData.fromMap(req),
      useFormData: true,
    );
  }

}
