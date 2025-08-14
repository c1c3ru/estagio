import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestao_de_estagio/core/constants/app_colors.dart';
import 'package:gestao_de_estagio/core/theme/app_text_styles.dart';
import 'package:gestao_de_estagio/features/shared/bloc/contract_bloc.dart';
import 'package:gestao_de_estagio/domain/entities/contract_entity.dart';
import 'package:gestao_de_estagio/features/shared/animations/lottie_animations.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:gestao_de_estagio/domain/usecases/supervisor/get_all_supervisors_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:gestao_de_estagio/core/enums/contract_status.dart';

class ContractPage extends StatefulWidget {
  final String? studentId;

  const ContractPage({
    super.key,
    this.studentId,
  });

  @override
  State<ContractPage> createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage> {
  @override
  void initState() {
    super.initState();
    _loadContracts();
    _loadActiveContract();
  }

  void _loadContracts() {
    if (widget.studentId != null) {
      flutter_bloc.ReadContext(context).read<ContractBloc>().add(
            ContractLoadByStudentRequested(studentId: widget.studentId!),
          );
    }
  }

  void _loadActiveContract() {
    if (widget.studentId != null) {
      flutter_bloc.ReadContext(context).read<ContractBloc>().add(
            ContractGetActiveByStudentRequested(studentId: widget.studentId!),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.studentId == null || widget.studentId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Contratos')),
        body: const Center(
          child: Text(
            'ID do estudante não informado. Não é possível exibir contratos.',
            style: TextStyle(color: Colors.red, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contratos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadContracts();
              _loadActiveContract();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadContracts();
          _loadActiveContract();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildActiveContractCard(),
              const SizedBox(height: 24),
              _buildContractsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveContractCard() {
    return BlocBuilder<ContractBloc, ContractState>(
      builder: (context, state) {
        if (state is ContractGetActiveByStudentSuccess) {
          final activeContract = state.contract;

          if (activeContract == null) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum contrato ativo',
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Você não possui um contrato ativo no momento',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showEditContractModal(),
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar Contrato'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          ContractStatus.fromString(activeContract.status)
                              .displayName
                              .toUpperCase(),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Botão de edição removido para estudantes - apenas supervisores podem editar contratos
                      const Icon(
                        Icons.business,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          'Início',
                          _formatDate(activeContract.startDate),
                          Icons.calendar_today,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'Fim',
                          _formatDate(activeContract.endDate),
                          Icons.event,
                        ),
                      ),
                    ],
                  ),
                  if (activeContract.description != null &&
                      activeContract.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Descrição',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeContract.description!,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: AppLottieAnimation(
                assetPath: 'assets/animations/Formulario_animation.json',
                height: 120,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditContractModal({dynamic contract}) {
    String? supervisorId = contract?.supervisorId;
    final contractBloc = flutter_bloc.ReadContext(context).read<ContractBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return BlocProvider.value(
          value: contractBloc,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 24,
            ),
            child: _ContractEditForm(
              studentId: widget.studentId!,
              contract: contract,
              supervisorId: supervisorId,
              onContractSaved: () {
                _loadContracts();
                _loadActiveContract();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption,
              ),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContractsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Histórico de Contratos',
          style: AppTextStyles.h6,
        ),
        const SizedBox(height: 16),
        BlocBuilder<ContractBloc, ContractState>(
          builder: (context, state) {
            if (state is ContractSelecting) {
              return const Center(
                child: AppLottieAnimation(
                  assetPath: 'assets/animations/Formulario_animation.json',
                  height: 120,
                ),
              );
            }

            if (state is ContractLoadByStudentSuccess) {
              if (state.contracts.isEmpty) {
                return const Center(
                  child: LottieEmptyStateWidget(
                    message: 'Nenhum contrato encontrado',
                    size: 150,
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.contracts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final contract = state.contracts[index];
                  return _ContractCard(contract: contract);
                },
              );
            }

            if (state is ContractSelectError) {
              return Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar contratos',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadContracts,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _ContractCard extends StatelessWidget {
  final dynamic contract;

  const _ContractCard({required this.contract});

  String _getContractTypeDisplay(String type) {
    switch (type) {
      case 'mandatory_internship':
        return 'Estágio Obrigatório';
      case 'voluntary_internship':
        return 'Estágio Não Obrigatório';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(contract.status);
    final statusText =
        ContractStatus.fromString(contract.status).displayName.toUpperCase();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _getContractTypeDisplay(contract.contractType),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_formatDate(contract.startDate)} - ${_formatDate(contract.endDate)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            if (contract.description != null &&
                contract.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                contract.description,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.success;
      case 'completed':
        return AppColors.info;
      case 'expired':
        return AppColors.error;
      case 'terminated':
        return AppColors.error;
      case 'pending_approval':
        return AppColors.warning;
      default:
        return AppColors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _ContractEditForm extends StatefulWidget {
  final String studentId;
  final dynamic contract;
  final String? supervisorId;
  final VoidCallback? onContractSaved;

  const _ContractEditForm({
    required this.studentId,
    this.contract,
    this.supervisorId,
    this.onContractSaved,
  });

  @override
  State<_ContractEditForm> createState() => _ContractEditFormState();
}

class _ContractEditFormState extends State<_ContractEditForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String? _contractType;
  String? _status;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSaving = false;
  String? _weeklyHours;

  List<dynamic> _supervisores = [];
  String? _supervisorId;
  bool _loadingSupervisores = true;

  final List<String> _contractTypes = [
    'mandatory_internship',
    'voluntary_internship',
  ];

  String _getContractTypeDisplay(String type) {
    switch (type) {
      case 'mandatory_internship':
        return 'Obrigatório';
      case 'voluntary_internship':
        return 'Não obrigatório';
      default:
        return type;
    }
  }

  final List<String> _statusOptions = [
    'active',
    'pending_approval',
    'expired',
    'terminated',
    'completed',
  ];

  @override
  void initState() {
    super.initState();
    _loadSupervisores();
    if (widget.contract != null) {
      _contractType = _contractTypes.contains(widget.contract.contractType)
          ? widget.contract.contractType
          : _contractTypes.first;
      _status = _statusOptions.contains(widget.contract.status)
          ? widget.contract.status
          : _statusOptions.first;
      _descriptionController.text = widget.contract.description ?? '';
      _startDate = widget.contract.startDate;
      _endDate = widget.contract.endDate;
      _supervisorId = widget.contract.supervisorId;
      _weeklyHours = '30';
    } else {
      _supervisorId = widget.supervisorId;
      _weeklyHours = '30';
    }
  }

  Future<void> _loadSupervisores() async {
    setState(() => _loadingSupervisores = true);
    try {
      final usecase = Modular.get<GetAllSupervisorsUsecase>();
      final result = await usecase();
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Erro ao buscar supervisores: ${failure.message}'),
                backgroundColor: Colors.red),
          );
          setState(() => _supervisores = []);
        },
        (list) => setState(() => _supervisores = list),
      );
    } catch (e) {
      setState(() => _supervisores = []);
    } finally {
      setState(() => _loadingSupervisores = false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContractBloc, ContractState>(
      listener: (context, state) {
        if (state is ContractCreateSuccess || state is ContractUpdateSuccess) {
          // Capturar contexto antes do Future.delayed
          final navigator = Navigator.of(context);
          // Mostrar SnackBar antes de fechar o modal
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contrato salvo com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );
          
          // Recarregar os dados automaticamente
          widget.onContractSaved?.call();
          
          // Fechar modal após um pequeno delay para garantir que o SnackBar seja exibido
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              navigator.pop();
            }
          });
        } else if (state is ContractInsertError ||
            state is ContractUpdateError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Erro ao salvar contrato: ${(state as dynamic).message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: AppLottieAnimation(
                  assetPath: 'assets/animations/Formulario_animation.json',
                  height: 140,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.contract == null
                    ? 'Adicionar Contrato'
                    : 'Editar Contrato',
                style: AppTextStyles.h6,
              ),
              const SizedBox(height: 16),
              if (_loadingSupervisores)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                DropdownButtonFormField<String>(
                  value: _supervisorId,
                  decoration: const InputDecoration(
                    labelText: 'Supervisor',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  items: _supervisores
                      .map<DropdownMenuItem<String>>(
                          (s) => DropdownMenuItem<String>(
                                value: s.id,
                                child: Text(s.fullName),
                              ))
                      .toList(),
                  onChanged: (value) => setState(() => _supervisorId = value),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Obrigatório' : null,
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _contractType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Contrato',
                  prefixIcon: Icon(Icons.assignment),
                  border: OutlineInputBorder(),
                ),
                items: _contractTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(_getContractTypeDisplay(type)),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _contractType = value),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.flag),
                  border: OutlineInputBorder(),
                ),
                items: _statusOptions
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(
                            ContractStatus.fromString(status).displayName,
                          ),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _status = value),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text:
                            _startDate != null ? _formatDate(_startDate!) : '',
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Início',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          locale: const Locale('pt', 'BR'),
                        );
                        if (picked != null) setState(() => _startDate = picked);
                      },
                      validator: (v) =>
                          _startDate == null ? 'Obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: _endDate != null ? _formatDate(_endDate!) : '',
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Fim',
                        prefixIcon: Icon(Icons.event),
                        border: OutlineInputBorder(),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          locale: const Locale('pt', 'BR'),
                        );
                        if (picked != null) setState(() => _endDate = picked);
                      },
                      validator: (v) {
                        if (_endDate == null) return 'Obrigatório';
                        if (_startDate != null &&
                            _endDate!.isBefore(_startDate!)) {
                          return 'Data fim deve ser posterior à data início';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _weeklyHours,
                decoration: const InputDecoration(
                  labelText: 'Carga Horária Semanal',
                  prefixIcon: Icon(Icons.schedule),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: '20',
                    child:
                        Text('20 horas/semana (Educação Especial/Fundamental)'),
                  ),
                  DropdownMenuItem(
                    value: '30',
                    child: Text('30 horas/semana (Ensino Superior/Médio)'),
                  ),
                ],
                onChanged: (value) => setState(() => _weeklyHours = value),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Limites Legais (Lei 11.788/2008):',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• Ensino Superior/Médio: até 30h semanais\n'
                      '• Educação Especial/Fundamental: até 20h semanais\n'
                      '• Diário: mínimo 4h, máximo 6h\n'
                      '• Redução permitida em períodos de prova',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _onSave,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save),
                  label: Text(widget.contract == null ? 'Salvar' : 'Atualizar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    String? supervisorId = _supervisorId;
    if (supervisorId == null || supervisorId.isEmpty) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Supervisor não encontrado para este estudante.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final contract = ContractEntity(
      id: widget.contract?.id ?? '',
      studentId: widget.studentId,
      supervisorId: supervisorId,
      contractType: _contractType!,
      status: _status!,
      startDate: _startDate!,
      endDate: _endDate!,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      documentUrl: widget.contract?.documentUrl,
      createdBy: widget.contract?.createdBy,
      createdAt: widget.contract?.createdAt ?? DateTime.now(),
      updatedAt: widget.contract != null ? DateTime.now() : null,
    );

    final bloc = flutter_bloc.ReadContext(context).read<ContractBloc>();
    if (widget.contract == null) {
      bloc.add(ContractCreateRequested(contract: contract));
    } else {
      bloc.add(ContractUpdateRequested(contract: contract));
    }
  }
}
