class DashboardModel {
  final String lastLoggedIn;
  final int totalVisitors;
  final int totalApartmentVisited;

  DashboardModel({
    required this.lastLoggedIn,
    required this.totalVisitors,
    required this.totalApartmentVisited,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      lastLoggedIn: json['lastLoggedIn'] ?? "",
      totalVisitors: json['totalVisitors'] ?? 0,
      totalApartmentVisited: json['totalApartmentVisited'] ?? 0,
    );
  }
}
