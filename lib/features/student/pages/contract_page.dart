import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestao_de_estagio/core/constants/app_colors.dart';
import 'package:gestao_de_estagio/core/theme/app_text_styles.dart';
import 'package:gestao_de_estagio/features/shared/bloc/contract_bloc.dart';

class ContractPage extends StatefulWidget {
  final String studentId;

  const ContractPage({
    super.key,
    required this.studentId,
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
    context.read<ContractBloc>().add(
          ContractLoadByStudentRequested(studentId: widget.studentId),
        );
  }

  void _loadActiveContract() {
    context.read<ContractBloc>().add(
          ContractGetActiveByStudentRequested(studentId: widget.studentId),
        );
  }

  @override
  Widget build(BuildContext context) {
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
                          'ATIVO',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.business,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    activeContract.company,
                    style: AppTextStyles.h5,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activeContract.position,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          'Horas/Semana',
                          '${activeContract.weeklyHoursTarget}h',
                          Icons.schedule,
                        ),
                      ),
                      if (activeContract.salary != null)
                        Expanded(
                          child: _buildInfoItem(
                            'Salário',
                            'R\$ ${activeContract.salary!.toStringAsFixed(2)}',
                            Icons.attach_money,
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
              child: CircularProgressIndicator(),
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
                child: CircularProgressIndicator(),
              );
            }

            if (state is ContractLoadByStudentSuccess) {
              if (state.contracts.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum contrato encontrado',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(contract.status.value);
    final statusText = _getStatusText(contract.status.value);

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
                    contract.company,
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
            const SizedBox(height: 4),
            Text(
              contract.position,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
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
                const Spacer(),
                const Icon(
                  Icons.schedule,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${contract.weeklyHoursTarget}h/sem',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            if (contract.salary != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.attach_money,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'R\$ ${contract.salary!.toStringAsFixed(2)}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
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
      case 'suspended':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'ATIVO';
      case 'completed':
        return 'CONCLUÍDO';
      case 'suspended':
        return 'SUSPENSO';
      case 'cancelled':
        return 'CANCELADO';
      default:
        return 'DESCONHECIDO';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
