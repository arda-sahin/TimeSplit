class TimerEntry {
  final int id;
  final String categoryName;
  final int durationInSeconds;
  final bool isProductive;
  final DateTime date;

  TimerEntry({
    required this.id,
    required this.categoryName,
    required this.durationInSeconds,
    required this.isProductive,
    required this.date,
  });

  factory TimerEntry.fromMap(Map<String, dynamic> map) {
    return TimerEntry(
      id: map['id'],
      categoryName: map['categoryName'],
      durationInSeconds: map['durationInSeconds'],
      isProductive: map['isProductive'] == 1,
      date: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryName': categoryName,
      'durationInSeconds': durationInSeconds,
      'isProductive': isProductive ? 1 : 0,
      'date': date.toIso8601String(),
    };
  }
}
