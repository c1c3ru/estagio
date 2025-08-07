import 'package:flutter/material.dart';
import '../../../core/services/report_service.dart';
import '../../../core/widgets/loading_indicator.dart';

class StudentReportsPage extends StatefulWidget {
  const StudentReportsPage({super.key});

  @override
  State<StudentReportsPage> createState() => _StudentReportsPageState();
}

class _StudentReportsPageState extends State<StudentReportsPage> {
  final ReportService _reportService = ReportService();
  String _selectedPeriod = 'Últimos 7 dias';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareReport,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : Column(
              children: [
                _buildPeriodSelector(),
                Expanded(child: _buildReportContent()),
              ],
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DropdownButton<String>(
        value: _selectedPeriod,
        items: const [
          DropdownMenuItem(value: 'Últimos 7 dias', child: Text('Últimos 7 dias')),
          DropdownMenuItem(value: 'Últimos 30 dias', child: Text('Últimos 30 dias')),
          DropdownMenuItem(value: 'Último mês', child: Text('Último mês')),
        ],
        onChanged: (value) {
          setState(() {
            _selectedPeriod = value!;
          });
        },
      ),
    );
  }

  Widget _buildReportContent() {
    return const Center(
      child: Text('Conteúdo do relatório'),
    );
  }

  void _exportReport() async {
    setState(() => _isLoading = true);
    try {
      await _reportService.exportToCSV(
        reportType: 'time_log',
        reportData: {},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Relatório exportado com sucesso')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _shareReport() {
    // Implementar compartilhamento
  }
}