class ReportLink {
  final String filename;
  final String downloadUrl;

  ReportLink({
    required this.filename,
    required this.downloadUrl,
  });

  // Factory method for creating a ReportLink instance from a JSON map
  factory ReportLink.fromJson(Map<String, dynamic> json) {
    return ReportLink(
      filename: json['filename'],
      downloadUrl: json['downloadUrl'],
    );
  }

  // Method to convert a ReportLink instance into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'downloadUrl': downloadUrl,
    };
  }
}
