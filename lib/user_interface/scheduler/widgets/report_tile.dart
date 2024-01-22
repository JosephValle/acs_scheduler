import 'package:adams_county_scheduler/objects/report.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class ReportTile extends StatelessWidget {
  final ReportLink report;

  const ReportTile({required this.report, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.list_alt),
      title: Text(
        report.filename,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      trailing: IconButton(
        tooltip: 'Download ${report.filename}',
        onPressed: () => _handleDownload(),
        icon: const Icon(Icons.download),
      ),
    );
  }

  void _handleDownload() {
    html.AnchorElement(href: report.downloadUrl)
      ..setAttribute('download', report.filename)
      ..click();
    html.Url.revokeObjectUrl(report.downloadUrl);
  }
}
