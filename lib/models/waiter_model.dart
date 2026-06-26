class RatingModel {
  final int id;
  final int rating;
  final String comment;
  final String restaurantName;
  final String createdAt;

  RatingModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.restaurantName,
    required this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'],
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      restaurantName: json['restaurant'] != null ? json['restaurant']['name'] : 'Restaurante Desconocido',
      createdAt: json['created_at'] ?? '',
    );
  }
}

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
  final List<RatingModel> ratings;

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
    this.ratings = const [],
  });

  factory WaiterModel.fromJson(Map<String, dynamic> json) {
    bool isShiftActive = false;
    if (json['shifts'] != null && (json['shifts'] as List).isNotEmpty) {
      isShiftActive = true;
    }

    List<RatingModel> ratingsList = [];
    if (json['ratings'] != null) {
      ratingsList = (json['ratings'] as List).map((r) => RatingModel.fromJson(r)).toList();
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
      ratings: ratingsList,
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
  final List<RatingModel> ratings;

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
    this.ratings = const [],
  });

  factory AvailableWaiterModel.fromJson(Map<String, dynamic> json) {
    String? applicationStatus;
    if (json['applications'] != null && (json['applications'] as List).isNotEmpty) {
      applicationStatus = json['applications'][0]['status'];
    }

    List<RatingModel> ratingsList = [];
    if (json['ratings'] != null) {
      ratingsList = (json['ratings'] as List).map((r) => RatingModel.fromJson(r)).toList();
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
      ratings: ratingsList,
    );
  }
}
