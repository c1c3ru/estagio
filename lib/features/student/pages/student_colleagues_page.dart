import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/online_colleagues_widget.dart';
import '../widgets/time_tracker_widget.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_state.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme_extensions.dart';

class StudentColleaguesPage extends StatefulWidget {
  const StudentColleaguesPage({super.key});

  @override
  State<StudentColleaguesPage> createState() => _StudentColleaguesPageState();
}

class _StudentColleaguesPageState extends State<StudentColleaguesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Colegas Online'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.tokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card com informações gerais
            Card(
              child: Padding(
                padding: EdgeInsets.all(context.tokens.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people, color: AppColors.primary),
                        SizedBox(width: context.tokens.spaceSm),
                        Expanded(
                          child: Text(
                            'Comunidade de Estagiários',
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.tokens.spaceSm),
                    Text(
                      'Conecte-se com seus colegas e acompanhe quem está trabalhando agora.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: context.tokens.spaceLg),

            // Time Tracker Widget
            const TimeTrackerWidget(),

            SizedBox(height: context.tokens.spaceLg),

            // Online Colleagues Widget
            const OnlineColleaguesWidget(),

            SizedBox(height: context.tokens.spaceXl),

            // Informações sobre status
            Card(
              child: Padding(
                padding: EdgeInsets.all(context.tokens.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Legenda',
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.tokens.spaceLg),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: context.tokens.spaceSm),
                        const Text(
                          'Online - Trabalhando agora',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                    SizedBox(height: context.tokens.spaceSm),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: context.tokens.spaceSm),
                        Text(
                          'Offline - Não está trabalhando',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: context.tokens.spaceXl),

            // Ações rápidas
            Card(
              child: Padding(
                padding: EdgeInsets.all(context.tokens.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ações Rápidas',
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.tokens.spaceLg),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Modular.to.pushNamed('/student/time-log');
                            },
                            icon: const Icon(Icons.access_time),
                            label: const Text('Registrar Horário'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: AppColors.white,
                              padding: EdgeInsets.symmetric(vertical: context.tokens.spaceMd),
                            ),
                          ),
                        ),
                        SizedBox(width: context.tokens.spaceMd),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final authState =
                                  Provider.of<AuthBloc>(context, listen: false)
                                      .state;
                              if (authState is AuthSuccess) {
                                final studentId = authState.user.id;
                                Modular.to.pushNamed(
                                  '/student/contracts',
                                  arguments: {'studentId': studentId},
                                );
                              }
                            },
                            icon: const Icon(Icons.description),
                            label: const Text('Ver Contratos'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              padding: EdgeInsets.symmetric(vertical: context.tokens.spaceMd),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
