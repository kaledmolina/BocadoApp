class WaiterModel {
  final int id;
  final String name;
  final String email;
  final bool isActive;
  final int experienceHours;
  final double averageRating;
  final bool isShiftActive;
  final String? phone;
  final String? city;
  final String? birthday;
  final String? bio;
  final String? skills;
  final String? experienceDescription;

  WaiterModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isActive,
    required this.experienceHours,
    required this.averageRating,
    required this.isShiftActive,
    this.phone,
    this.city,
    this.birthday,
    this.bio,
    this.skills,
    this.experienceDescription,
  });

  factory WaiterModel.fromJson(Map<String, dynamic> json) {
    bool isShiftActive = false;
    if (json['shifts'] != null && (json['shifts'] as List).isNotEmpty) {
      isShiftActive = true;
    }

    return WaiterModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      experienceHours: json['experience_hours'] ?? 0,
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      isShiftActive: isShiftActive,
      phone: json['phone'],
      city: json['city'],
      birthday: json['birthday'],
      bio: json['bio'],
      skills: json['skills'],
      experienceDescription: json['experience_description'],
    );
  }
}

class ApplicationModel {
  final int id;
  final String status;
  final WaiterModel user;

  ApplicationModel({
    required this.id,
    required this.status,
    required this.user,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'],
      status: json['status'],
      user: WaiterModel.fromJson(json['user']),
    );
  }
}

class AvailableWaiterModel {
  final int id;
  final String name;
  final String email;
  final int experienceHours;
  final double averageRating;
  final String? phone;
  final String? city;
  final String? birthday;
  final String? bio;
  final String? skills;
  final String? experienceDescription;
  final String? status;

  AvailableWaiterModel({
    required this.id,
    required this.name,
    required this.email,
    required this.experienceHours,
    required this.averageRating,
    this.phone,
    this.city,
    this.birthday,
    this.bio,
    this.skills,
    this.experienceDescription,
    this.status,
  });

  factory AvailableWaiterModel.fromJson(Map<String, dynamic> json) {
    String? applicationStatus;
    if (json['applications'] != null && (json['applications'] as List).isNotEmpty) {
      applicationStatus = json['applications'][0]['status'];
    }

    return AvailableWaiterModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      experienceHours: json['experience_hours'] ?? 0,
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      phone: json['phone'],
      city: json['city'],
      birthday: json['birthday'],
      bio: json['bio'],
      skills: json['skills'],
      experienceDescription: json['experience_description'],
      status: applicationStatus,
    );
  }
}
