class USER {
  String? name;
  String? email;

  USER({this.name, this.email});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
    };
  }

  static USER fromJson(Map<String, dynamic> json) {
    return USER(email: json['email'], name: json['name']);
  }
}
