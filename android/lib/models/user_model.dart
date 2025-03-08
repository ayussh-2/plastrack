class UserModel {
  final String firebaseId;
  final String email;
  final String name;
  final String? phone;
  final String city;
  final String state;

  UserModel({
    required this.firebaseId,
    required this.email,
    required this.name,
    this.phone,
    required this.city,
    required this.state,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      firebaseId: json['firebaseId'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      city: json['city'],
      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firebaseId': firebaseId,
      'email': email,
      'name': name,
      'phone': phone,
      'city': city,
      'state': state,
    };
  }
}
