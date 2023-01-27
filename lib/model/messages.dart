class Messages {
  String? sentBy;
  String? message;
  Messages({required this.sentBy, required this.message});

  static Messages fromJson(Map<String, dynamic> map) {
    return Messages(sentBy: map['sentBy'], message: map['message']);
  }

}
