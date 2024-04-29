class Company {
  Company({this.name});

  Company.fromMap(Map<String, dynamic> data) {
    name = data['name'];
  }

  String? name;

  Map<String, dynamic> toMap() => {
    'name': name,
  };
}