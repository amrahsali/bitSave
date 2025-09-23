class FacilityCategory {
  String? id;
  String name;
  String description;
  String icon;

  FacilityCategory({
    this.id,
    required this.name,
    this.description = '',
    this.icon = '🏋🏾‍♂️',
  });

  factory FacilityCategory.fromJson(Map<String, dynamic> json) {
    return FacilityCategory(
      id: json['_id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🏋🏾‍♂️',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'icon': icon,
    };
  }
}
