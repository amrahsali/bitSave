import '../../network/api_response.dart';

abstract class IRepository {

  Future<ApiResponse> generatePaystackAccessCode( {
    required String email,
    required int amount,
  String currency,
  String reference});

  Future<ApiResponse> login(Map<String, dynamic> req);

  Future<ApiResponse> createEmergency(Map<String, dynamic> req);

  Future<ApiResponse> validateGatePass(String gatepass);

  Future<ApiResponse> logOut();

  Future<ApiResponse> refresh(Map<String, dynamic> req);

  Future<ApiResponse> register(Map<String, dynamic> req);

  Future<ApiResponse> updateDeviceId(Map<String, dynamic> req);

  Future<ApiResponse> createFacility(Map<String, dynamic> req);

  Future<ApiResponse> createGuestInvite(Map<String, dynamic> req);

  Future<ApiResponse> updateInviteStatus(Map<String, dynamic> req);

  Future<ApiResponse> verify(Map<String, dynamic> req);

  Future<ApiResponse> updateUser(Map<String, dynamic> req, String userId);

  Future<ApiResponse> sendOtp(Map<String, dynamic> req);

  Future<ApiResponse> getEstates();

  Future<ApiResponse> getDashboardData();

  Future<ApiResponse> getResidents();

  Future<ApiResponse> getApartments(String estateId);

  Future<ApiResponse> getProfile();

  Future<ApiResponse> resetPasswordRequest(Map<String, dynamic> req);

  Future<ApiResponse> forgotPassword(Map<String, dynamic> req);

  Future<ApiResponse> deleteAccount(Map<String, dynamic> req);

  Future<ApiResponse> updateProfilePicture(Map<String, dynamic> req);

  Future<ApiResponse> updateMedia(Map<String, dynamic> req);

  Future<ApiResponse> getNotifications();

  Future<ApiResponse> escalateNotifications(int trackerId);

  Future<ApiResponse> changePassword(Map<String, String> map);

  Future<ApiResponse> updateProfilePictureMultipart(Map<String, dynamic> req, String userId);

    Future<ApiResponse> verifyPasswordResetCode({
        required String email,
        required String code,
        required String newPassword,
    });
}
