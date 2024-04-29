class Profile {
  Profile();

  String? name;
  String? address;
  String? email;
  String? phone;

  Profile.fromMap(Map<String, dynamic> body) {
    name = body['name'];
    address = body['address'];
    email = body['email'];
    phone = body['phone'];
  }

  @override
  String toString() {
    return '$name\n$address\n$email\n$phone';
  }

  Map<String, dynamic> toMap() {
    return {"name": name, "address": address, "email": email, "phone": phone};
  }
}