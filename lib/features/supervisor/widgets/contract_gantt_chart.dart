// lib/features/supervisor/presentation/widgets/contract_gantt_chart.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatação de datas
import 'package:gestao_de_estagio/core/enums/contract_status.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/contract_entity.dart';
import '../../../../domain/entities/student_entity.dart';

class ContractGanttChart extends StatelessWidget {
  final List<ContractEntity> contracts;
  final List<StudentEntity> students; // Para obter nomes dos estudantes

  const ContractGanttChart({
    super.key,
    required this.contracts,
    required this.students,
  });

  // Encontra o nome do estudante pelo ID
  String _getStudentName(String studentId) {
    try {
      return students.firstWhere((s) => s.id == studentId).fullName;
    } catch (e) {
      return 'Estudante ID: ${studentId.substring(0, 6)}...'; // Fallback
    }
  }

  Color _getContractStatusColor(ContractStatus status, BuildContext context) {
    switch (status) {
      case ContractStatus.active:
        return AppColors.statusActive;
      case ContractStatus.pendingApproval:
        return AppColors.statusPending;
      case ContractStatus.expired:
        return AppColors.statusInactive; // Ou uma cor específica para expirado
      case ContractStatus.terminated:
        return AppColors.statusTerminated;
      case ContractStatus.completed:
        return AppColors.statusCompleted;
      case ContractStatus.unknown:
      default:
        return Theme.of(context).disabledColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (contracts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('Nenhum contrato para exibir na visualização Gantt.'),
        ),
      );
    }

    // Determinar a data de início mais cedo e a data de término mais tarde para o eixo X
    DateTime overallStartDate = contracts.isNotEmpty
        ? contracts
            .map((c) => c.startDate)
            .reduce((a, b) => a.isBefore(b) ? a : b)
        : DateTime.now();
    DateTime overallEndDate = contracts.isNotEmpty
        ? contracts.map((c) => c.endDate).reduce((a, b) => a.isAfter(b) ? a : b)
        : DateTime.now().add(const Duration(days: 30));

    // Adicionar uma pequena margem ao final para visualização
    overallEndDate = overallEndDate.add(const Duration(days: 1));
    if (overallStartDate == overallEndDate) {
      // Evitar divisão por zero se todas as datas forem iguais
      overallEndDate = overallEndDate.add(const Duration(days: 1));
    }
    // Se a data de início for depois da data de fim (caso de lista vazia ou dados estranhos)
    if (overallStartDate.isAfter(overallEndDate)) {
      overallStartDate = overallEndDate.subtract(const Duration(days: 30));
    }

    final int totalDurationInDays =
        overallEndDate.difference(overallStartDate).inDays;
    if (totalDurationInDays <= 0) {
      return const Center(
          child: Text("Intervalo de datas inválido para o gráfico Gantt."));
    }

    // Largura total disponível para as barras (excluindo o nome do estudante e paddings)
    // Esta é uma estimativa, pode ser ajustada.
    const double nameColumnWidth = 120.0; // Largura para o nome do estudante
    final double chartAreaWidth = MediaQuery.of(context).size.width -
        nameColumnWidth -
        48; // 48 para paddings gerais

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho do Gráfico (Datas) - Simplificado
        Padding(
          padding: const EdgeInsets.only(
              left: nameColumnWidth + 16.0, right: 16.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('dd/MM/yy').format(overallStartDate),
                  style: theme.textTheme.bodySmall),
              Text('Duração Total: $totalDurationInDays dias',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(
                  DateFormat('dd/MM/yy')
                      .format(overallEndDate.subtract(const Duration(days: 1))),
                  style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          // Para permitir que o ListView ocupe o espaço restante
          child: ListView.builder(
            itemCount: contracts.length,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemBuilder: (context, index) {
              final contract = contracts[index];
              final studentName = _getStudentName(contract.studentId);

              final contractStartOffsetDays =
                  contract.startDate.difference(overallStartDate).inDays;
              final contractDurationDays = contract.endDate
                  .difference(contract.startDate)
                  .inDays
                  .clamp(0, totalDurationInDays); // Clamp para não exceder

              // Calcula as larguras proporcionais para a barra
              final double startPadding =
                  (contractStartOffsetDays / totalDurationInDays) *
                      chartAreaWidth;
              final double barWidth =
                  (contractDurationDays / totalDurationInDays) * chartAreaWidth;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Coluna do Nome do Estudante
                    SizedBox(
                      width: nameColumnWidth,
                      child: Text(
                        studentName,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 8), // Espaço entre nome e barra
                    // Área da Barra de Gantt
                    Expanded(
                      child: Container(
                        height: 28.0, // Altura da barra
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant
                              .withAlpha(80), // Fundo da linha
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: startPadding.isFinite && !startPadding.isNaN
                                  ? startPadding.clamp(0, chartAreaWidth)
                                  : 0,
                              top: 0,
                              bottom: 0,
                              child: Tooltip(
                                message: '$studentName\n'
                                    'Contrato: ${contract.contractType}\n'
                                    'Status: ${contract.status.displayName}\n'
                                    'Início: ${DateFormat('dd/MM/yyyy').format(contract.startDate)}\n'
                                    'Término: ${DateFormat('dd/MM/yyyy').format(contract.endDate)}',
                                child: Container(
                                  width: barWidth.isFinite && !barWidth.isNaN
                                      ? barWidth.clamp(4, chartAreaWidth)
                                      : 4.0, // Mínimo de 4px de largura
                                  decoration: BoxDecoration(
                                      color: _getContractStatusColor(
                                          contract.status, context),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                          color:
                                              theme.dividerColor.withAlpha(100),
                                          width: 0.5)),
                                  // child: Center( // Opcional: mostrar texto dentro da barra
                                  //   child: Text(
                                  //     '${contractDurationDays}d',
                                  //     style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10),
                                  //     overflow: TextOverflow.clip,
                                  //   ),
                                  // ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
