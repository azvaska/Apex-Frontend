import 'package:flutter/material.dart';

import 'package:apex/features/segnalazioni/models/report_models.dart';

class ReportTag {
  final String label;
  final Color color;

  const ReportTag({required this.label, required this.color});
}

ReportTag deriveReportTag(Report report) {
  final text = '${report.title} ${report.text}'.toLowerCase();
  if (text.contains('valanga')) {
    return const ReportTag(label: 'valanga', color: Color(0xFFD64045));
  }
  if (text.contains('meteo') || text.contains('temporale')) {
    return const ReportTag(label: 'meteo', color: Color(0xFF2D6CDF));
  }
  if (text.contains('sentiero')) {
    return const ReportTag(label: 'sentiero', color: Color(0xFF1D9A6C));
  }
  return const ReportTag(label: 'frana', color: Color(0xFFE03A3E));
}

class ReportTagPill extends StatelessWidget {
  final ReportTag tag;

  const ReportTagPill({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tag.color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              tag.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
