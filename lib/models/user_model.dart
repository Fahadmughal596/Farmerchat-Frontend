class UserModel {
  final String name;
  final String email;
  final String phone;
  final String location;
  final String farmType;

  UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.farmType,
  });

  factory UserModel.fromJson(Map<String,dynamic> json){
    return UserModel(
      name: json["name"],
      email: json["email"],
      phone: json["phone"],
      location: json["location"],
      farmType: json["farm_type"],
    );
  }
}