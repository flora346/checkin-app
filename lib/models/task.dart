class Task {
  int? id;
  String name;
  bool enableRemind;
  String remindTime;

  Task({this.id, required this.name, this.enableRemind = false, this.remindTime = "20:00"});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'enableRemind': enableRemind ? 1 : 0,
      'remindTime': remindTime,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      enableRemind: map['enableRemind'] == 1,
      remindTime: map['remindTime'],
    );
  }
}
