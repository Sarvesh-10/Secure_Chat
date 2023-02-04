class Messages {
  final String sentBy;
  final String message;
  final DateTime  time; 
  Messages({required this.sentBy, required this.message ,required this.time});

  static Messages fromJson(Map<String, dynamic> map) {
    return Messages(sentBy: map['sentBy'], message: map['message'],time: map['time']);
  }
}
