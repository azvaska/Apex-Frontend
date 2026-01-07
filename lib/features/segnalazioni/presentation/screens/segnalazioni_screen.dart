import 'package:flutter/material.dart';

import 'package:apex/features/segnalazioni/data/report_repository.dart';
import 'package:apex/features/segnalazioni/models/report_models.dart';
import 'package:apex/features/segnalazioni/presentation/widgets/report_card.dart';
import 'package:apex/features/segnalazioni/presentation/widgets/report_create_sheet.dart';
import 'package:apex/features/segnalazioni/presentation/widgets/report_detail_sheet.dart';
import 'package:apex/features/segnalazioni/presentation/widgets/report_tag.dart';

class SegnalazioniScreen extends StatefulWidget {
  const SegnalazioniScreen({super.key});

  @override
  State<SegnalazioniScreen> createState() => _SegnalazioniScreenState();
}

class _SegnalazioniScreenState extends State<SegnalazioniScreen> {
  final ReportRepository _repository = ReportRepository();
  late Future<List<Report>> _reportsFuture;
  String _selectedFilter = 'Tutte';

  @override
  void initState() {
    super.initState();
    _reportsFuture = _repository.fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreate(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Report>>(
          future: _reportsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                child: Text('Errore nel caricamento delle segnalazioni.'),
              );
            }
            final reports = _filteredReports(snapshot.data!);
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                Text(
                  'Segnalazioni',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                _FilterChips(
                  selected: _selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ...reports.map(
                  (report) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ReportCard(
                      report: report,
                      onTap: () => _openDetail(context, report),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Report> _filteredReports(List<Report> reports) {
    if (_selectedFilter == 'Tutte') {
      return reports;
    }
    const filterMap = {
      'Frane': 'frana',
      'Valanghe': 'valanga',
      'Meteo': 'meteo',
      'Sentieri': 'sentiero',
    };
    final target = filterMap[_selectedFilter];
    return reports.where((report) {
      return deriveReportTag(report).label == target;
    }).toList();
  }

  void _openDetail(BuildContext context, Report report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ReportDetailSheet(report: report, repository: _repository),
    );
  }

  Future<void> _openCreate(BuildContext context) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportCreateSheet(
        repository: _repository,
        onCreated: _refreshReports,
      ),
    );
    if (created == true && mounted) {
      _refreshReports();
    }
  }

  Future<void> _refreshReports() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _reportsFuture = _repository.fetchReports();
    });
  }
}

class _FilterChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _FilterChips({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = const ['Tutte', 'Frane', 'Valanghe', 'Meteo', 'Sentieri'];
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) => onChanged(filter),
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              selectedColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surfaceVariant,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
