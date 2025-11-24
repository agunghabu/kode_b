class User {
  final String fullName;
  final String email;
  final String address;
  final String phoneNumber;
  final String username;
  final String password;

  User({
    required this.fullName,
    required this.email,
    required this.address,
    required this.phoneNumber,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'address': address,
      'phoneNumber': phoneNumber,
      'username': username,
      'password': password,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullName: json['fullName'],
      email: json['email'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      username: json['username'],
      password: json['password'],
    );
  }
}
