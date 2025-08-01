import 'package:flutter/material.dart';
import '../../../core/widgets/loading_indicator.dart';

class SupervisorReportsPage extends StatefulWidget {
  const SupervisorReportsPage({super.key});

  @override
  State<SupervisorReportsPage> createState() => _SupervisorReportsPageState();
}

class _SupervisorReportsPageState extends State<SupervisorReportsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios de Supervisão'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.batch_prediction),
            onPressed: _generateBulkReports,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Performance'),
            Tab(text: 'Contratos'),
            Tab(text: 'Análises'),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPerformanceTab(),
                _buildContractsTab(),
                _buildAnalysisTab(),
              ],
            ),
    );
  }

  Widget _buildPerformanceTab() {
    return const Center(child: Text('Performance dos Estudantes'));
  }

  Widget _buildContractsTab() {
    return const Center(child: Text('Relatórios de Contratos'));
  }

  Widget _buildAnalysisTab() {
    return const Center(child: Text('Análises Gerais'));
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por Estudante'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('João Silva'),
              onTap: () => Navigator.pop(context, 'João Silva'),
            ),
            ListTile(
              title: const Text('Maria Santos'),
              onTap: () => Navigator.pop(context, 'Maria Santos'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'Aplicar'),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  void _generateBulkReports() async {
    setState(() => _isLoading = true);
    try {
      // Simular geração de relatórios em lote
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Relatórios gerados com sucesso')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar relatórios: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}