import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestao_de_estagio/core/enums/student_status.dart';
import 'package:gestao_de_estagio/domain/entities/filter_students_params.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/supervisor_bloc.dart';
import '../bloc/supervisor_event.dart';
import '../bloc/supervisor_state.dart';

class DashboardSummaryCards extends StatelessWidget {
  final SupervisorDashboardStats stats;

  const DashboardSummaryCards({
    super.key,
    required this.stats,
  });

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required int count,
    required IconData icon,
    required Color iconColor,
    Color? backgroundColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        color: backgroundColor ?? theme.cardColor,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 28, color: iconColor),
                const SizedBox(height: 8),
                Text(
                  count.toString(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: onTap != null ? theme.colorScheme.primary : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.hintColor),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool useRow = constraints.maxWidth > 500;

        final cards = [
          _buildStatCard(
            context: context,
            title: AppStrings.totalStudents,
            count: stats.totalStudents,
            icon: Icons.people_alt_outlined,
            iconColor: AppColors.primary,
            onTap: () {
              context.read<SupervisorBloc>().add(
                  const FilterStudentsEvent(params: FilterStudentsParams()));
            },
          ),
          _buildStatCard(
            context: context,
            title: AppStrings.activeStudents,
            count: stats.activeStudents,
            icon: Icons.check_circle_outline,
            iconColor: AppColors.statusActive,
            onTap: () {
              context.read<SupervisorBloc>().add(const FilterStudentsEvent(
                  params: FilterStudentsParams(status: StudentStatus.active)));
            },
          ),
          _buildStatCard(
            context: context,
            title: AppStrings.inactiveStudents,
            count: stats.inactiveStudents,
            icon: Icons.pause_circle_outline_outlined,
            iconColor: AppColors.statusInactive,
            onTap: () {
              context.read<SupervisorBloc>().add(const FilterStudentsEvent(
                  params:
                      FilterStudentsParams(status: StudentStatus.inactive)));
            },
          ),
          _buildStatCard(
            context: context,
            title: AppStrings.expiringContracts,
            count: stats.expiringContractsSoon,
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.statusPending,
            onTap: () {
              context.read<SupervisorBloc>().add(FilterStudentsEvent(
                  params: FilterStudentsParams(
                      contractEndDateTo:
                          DateTime.now().add(const Duration(days: 30)))));
            },
          ),
        ];

        if (useRow) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cards
                .expand((card) => [card, const SizedBox(width: 12)])
                .toList()
              ..removeLast(),
          );
        } else {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: cards,
          );
        }
      },
    );
  }
}
