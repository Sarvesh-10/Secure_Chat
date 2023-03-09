class Messages {
  final String sentBy;
  final String message;
  final DateTime time;
  final String type;
  Messages(
      {required this.sentBy,
      required this.message,
      required this.time,
      required this.type});

  static Messages fromJson(Map<String, dynamic> map) {
    return Messages(
        sentBy: map['sentBy'],
        message: map['message'],
        time: map['time'],
        type: map['type']);
  }
}
