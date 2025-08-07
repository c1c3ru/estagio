import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestao_de_estagio/core/widgets/empty_data_widget.dart';
import '../bloc/supervisor_bloc.dart';
import '../bloc/supervisor_event.dart';
import '../bloc/supervisor_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/student_entity.dart';

class ContractPage extends StatefulWidget {
  const ContractPage({super.key});

  @override
  State<ContractPage> createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage> {
  String _search = '';
  String? _statusFilter;
  final _searchController = TextEditingController();
  
  // Mapeamento de status
  final Map<String, String> _statusMap = {
    'active': 'Ativo',
    'pending_approval': 'Pendente de Aprovação',
    'expired': 'Expirado',
    'terminated': 'Encerrado',
    'completed': 'Concluído',
  };
  
  final Map<String, String> _reverseStatusMap = {
    'Ativo': 'active',
    'Pendente de Aprovação': 'pending_approval',
    'Expirado': 'expired',
    'Encerrado': 'terminated',
    'Concluído': 'completed',
  };

  @override
  void initState() {
    super.initState();
    // Carregar dados do dashboard se não estiverem carregados
    final bloc = BlocProvider.of<SupervisorBloc>(context, listen: false);
    if (bloc.state is! SupervisorDashboardLoadSuccess) {
      bloc.add(LoadSupervisorDashboardDataEvent());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contratos do Supervisor')),
      body: BlocListener<SupervisorBloc, SupervisorState>(
        listener: (context, state) {
          if (state is SupervisorOperationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro: ${state.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is SupervisorOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        child: BlocBuilder<SupervisorBloc, SupervisorState>(
          builder: (context, state) {
            if (state is SupervisorLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SupervisorDashboardLoadSuccess) {
              final contracts = state.contracts;
              final students = state.students;
              // Filtro por busca e status
              final filtered = contracts.where((c) {
                final student = _findStudent(students, c.studentId);
                final studentName = student?.fullName ?? c.studentId;
                final matchesSearch = _search.isEmpty ||
                    (c.description
                            ?.toLowerCase()
                            .contains(_search.toLowerCase()) ??
                        false) ||
                    studentName.toLowerCase().contains(_search.toLowerCase());
                final matchesStatus = _statusFilter == null ||
                    _statusFilter!.isEmpty ||
                    c.status == _statusFilter;
                return matchesSearch && matchesStatus;
              }).toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              labelText: 'Buscar por estudante ou descrição',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) => setState(() => _search = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: _statusFilter,
                          hint: const Text('Status'),
                          items: [
                            null,
                            'active',
                            'pending_approval',
                            'expired',
                            'terminated',
                            'completed'
                          ]
                              .map((status) => DropdownMenuItem<String>(
                                    value: status,
                                    child: Text(status ?? 'Todos'),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _statusFilter = v),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? const EmptyDataWidget(
                            message:
                                'Nenhum contrato corresponde aos filtros selecionados.',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final contract = filtered[index];
                              final student =
                                  _findStudent(students, contract.studentId);
                              final studentName =
                                  student?.fullName ?? contract.studentId;
                              return Card(
                                child: ListTile(
                                  title: Text(
                                    contract.description ??
                                        'Contrato de Estágio',
                                    style: AppTextStyles.bodyLarge,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Estudante: $studentName'),
                                      Text('Status: ${_statusMap[contract.status] ?? contract.status}'),
                                      Text(
                                          'Início: ${_formatDate(contract.startDate)}'),
                                      Text(
                                          'Fim: ${_formatDate(contract.endDate)}'),
                                      Text('Tipo: ${contract.contractType}'),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: AppColors.primary),
                                        tooltip: 'Editar',
                                        onPressed: () =>
                                            _editContract(context, contract),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.cancel,
                                            color: AppColors.error),
                                        tooltip: 'Encerrar',
                                        onPressed: () => _terminateContract(
                                            context, contract),
                                      ),
                                      const Icon(Icons.arrow_forward_ios),
                                    ],
                                  ),
                                  onTap: () {
                                    _showContractDetails(
                                        context, contract, studentName);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            }
            return const Center(child: Text('Carregando contratos...'));
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showContractDetails(
      BuildContext context, dynamic contract, String studentName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes do Contrato'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${contract.id}'),
            Text('Estudante: $studentName'),
            Text('Status: ${_statusMap[contract.status] ?? contract.status}'),
            Text('Início: ${_formatDate(contract.startDate)}'),
            Text('Fim: ${_formatDate(contract.endDate)}'),
            Text('Tipo: ${contract.contractType}'),
            if (contract.description != null)
              Text('Descrição: ${contract.description}'),
            if (contract.documentUrl != null)
              Text('Documento: ${contract.documentUrl}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _editContract(BuildContext context, dynamic contract) async {
    final formKey = GlobalKey<FormState>();
    final descriptionController =
        TextEditingController(text: contract.description ?? '');
    String contractType = contract.contractType;
    String status = contract.status;
    DateTime startDate = contract.startDate;
    DateTime endDate = contract.endDate;
    final bloc = BlocProvider.of<SupervisorBloc>(context, listen: false);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Contrato'),
        content: StatefulBuilder(
          builder: (context, setState) => Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: 'internship',
                    decoration: const InputDecoration(labelText: 'Tipo'),
                    items: const [
                      DropdownMenuItem(value: 'internship', child: Text('Estágio')),
                      DropdownMenuItem(value: 'mandatory_internship', child: Text('Estágio Obrigatório')),
                    ],
                    onChanged: (v) => setState(() => contractType = v ?? 'internship'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _statusMap.containsKey(status) ? _statusMap[status] : 'Ativo',
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'Ativo', child: Text('Ativo')),
                      DropdownMenuItem(value: 'Pendente de Aprovação', child: Text('Pendente de Aprovação')),
                      DropdownMenuItem(value: 'Expirado', child: Text('Expirado')),
                      DropdownMenuItem(value: 'Encerrado', child: Text('Encerrado')),
                      DropdownMenuItem(value: 'Concluído', child: Text('Concluído')),
                    ],
                    onChanged: (v) => setState(() => status = _reverseStatusMap[v] ?? 'active'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration:
                              const InputDecoration(labelText: 'Início'),
                          controller: TextEditingController(
                              text: _formatDate(startDate)),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (!mounted) return;
                            if (picked != null) {
                              setState(() => startDate = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration: const InputDecoration(labelText: 'Fim'),
                          controller:
                              TextEditingController(text: _formatDate(endDate)),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: endDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (!mounted) return;
                            if (picked != null) {
                              setState(() => endDate = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              bloc.add(
                UpdateContractBySupervisorEvent(
                  contract: contract.copyWith(
                    description: descriptionController.text.trim(),
                    contractType: contractType,
                    status: status,
                    startDate: startDate,
                    endDate: endDate,
                  ),
                ),
              );
              Navigator.of(context).pop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contrato atualizado!')),
                );
              }
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  void _terminateContract(BuildContext context, dynamic contract) async {
    final bloc = BlocProvider.of<SupervisorBloc>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Encerrar Contrato'),
        content: const Text('Tem certeza que deseja encerrar este contrato?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Encerrar',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      bloc.add(
        UpdateContractBySupervisorEvent(
          contract: contract.copyWith(status: 'terminated'),
        ),
      );
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Contrato encerrado!')),
      );
    }
  }

  StudentEntity? _findStudent(List students, String id) {
    try {
      return students.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
