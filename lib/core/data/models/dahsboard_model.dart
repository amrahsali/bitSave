class DashboardModel {
  final String lastLoggedIn;


  DashboardModel({
    required this.lastLoggedIn,

  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      lastLoggedIn: json['lastLoggedIn'] ?? "",
    );
  }
}
