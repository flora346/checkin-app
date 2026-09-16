class CheckRecord {
  int? id;
  int taskId;
  String date;
  String status; // complete / miss / none
  String note;

  CheckRecord({
    this.id,
    required this.taskId,
    required this.date,
    required this.status,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'date': date,
      'status': status,
      'note': note,
    };
  }

  static CheckRecord fromMap(Map<String, dynamic> map) {
    return CheckRecord(
      id: map['id'],
      taskId: map['taskId'],
      date: map['date'],
      status: map['status'],
      note: map['note'],
    );
  }
}
