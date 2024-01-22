class ExportStudentSchedule {
  final String formattedName;
  final String school;
  final List<ExportStudentSession> sessions;

  ExportStudentSchedule({
    required this.formattedName,
    required this.school,
    required this.sessions,
  });

  Map<String, dynamic> toJson() {
    return {
      'Name': formattedName,
      'School': school,
      'Sessions': sessions.map((session) => session.toJson()).toList(),
    };
  }
}

class ExportStudentSession {
  final String time;
  final String roomName;
  final String careerName;

  ExportStudentSession({
    required this.time,
    required this.roomName,
    required this.careerName,
  });

  Map<String, dynamic> toJson() {
    return {
      'Time': time,
      'Room': roomName,
      'Career': careerName,
    };
  }
}
