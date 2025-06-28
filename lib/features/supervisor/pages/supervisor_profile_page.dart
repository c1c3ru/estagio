import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/supervisor_entity.dart';
import '../bloc/supervisor_bloc.dart';
import '../bloc/supervisor_event.dart';
import '../bloc/supervisor_state.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart' as auth_state;
import 'package:flutter/foundation.dart';

class SupervisorProfilePage extends StatefulWidget {
  const SupervisorProfilePage({super.key});

  @override
  State<SupervisorProfilePage> createState() => _SupervisorProfilePageState();
}

class _SupervisorProfilePageState extends State<SupervisorProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditMode = false;
  SupervisorEntity? _supervisor;

  // Controllers
  final _departmentController = TextEditingController();
  final _positionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carregar dados do dashboard com timeout
    Modular.get<SupervisorBloc>().add(LoadSupervisorDashboardDataEvent());

    // Timeout de segurança para evitar loading infinito
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          // Força a atualização da UI mesmo se o loading continuar
        });
      }
    });
  }

  @override
  void dispose() {
    _departmentController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _populateFields(SupervisorEntity supervisor) {
    _departmentController.text = supervisor.department ?? '';
    _positionController.text = supervisor.position ?? '';
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (_isEditMode && _supervisor != null) {
        _populateFields(_supervisor!);
      }
    });
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_supervisor != null) {
        final updated = _supervisor!.copyWith(
          department: _departmentController.text.trim(),
          position: _positionController.text.trim(),
        );
        Modular.get<SupervisorBloc>()
            .add(UpdateSupervisorEvent(supervisor: updated));
      }
      setState(() => _isEditMode = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SupervisorBloc, SupervisorState>(
      bloc: Modular.get<SupervisorBloc>(),
      listener: (context, state) {
        if (state is SupervisorOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success),
          );
        } else if (state is SupervisorOperationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        // Debug: Log do estado atual
        if (kDebugMode) {
          print('🟡 SupervisorProfilePage: Estado atual: ${state.runtimeType}');
        }

        // Obter dados do usuário autenticado
        final authState = Modular.get<AuthBloc>().state;
        String userName = 'Supervisor';
        String userEmail = '';

        if (authState is auth_state.AuthSuccess) {
          userName = authState.user.fullName;
          userEmail = authState.user.email;
        }

        // Mostrar loading apenas se estiver realmente carregando E não tivermos dados
        if (state is SupervisorLoading) {
          // Se já temos dados do supervisor, não mostrar loading
          if (_supervisor != null) {
            if (kDebugMode) {
              print(
                  '🟡 SupervisorProfilePage: Loading mas já temos dados, mostrando UI');
            }
          } else {
            if (kDebugMode) {
              print('🟡 SupervisorProfilePage: Mostrando loading...');
            }
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        }

        // Tentar obter dados do supervisor
        SupervisorEntity? supervisor;
        if (state is SupervisorDashboardLoadSuccess) {
          supervisor = state.supervisorProfile;
          _supervisor = supervisor;
          if (kDebugMode) {
            print(
                '🟡 SupervisorProfilePage: Supervisor carregado: ${supervisor?.fullName ?? 'null'}');
          }
        }

        // Se não temos dados do supervisor mas não estamos carregando, mostrar mensagem
        if (supervisor == null && state is! SupervisorLoading) {
          if (kDebugMode) {
            print(
                '🟡 SupervisorProfilePage: Nenhum supervisor encontrado, mostrando mensagem');
          }
        }

        // Sempre mostrar a UI, mesmo sem dados completos
        return Scaffold(
          appBar: AppBar(
            title: const Text('Perfil do Supervisor'),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            actions: [
              if (!_isEditMode && supervisor != null)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _toggleEditMode,
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(userName, userEmail, supervisor),
                  const SizedBox(height: 24),
                  if (supervisor != null) ...[
                    _isEditMode
                        ? _buildEditableFields()
                        : _buildReadOnlyFields(supervisor),
                    const SizedBox(height: 24),
                    if (_isEditMode) _buildActionButtons(),
                  ] else ...[
                    _buildNoProfileMessage(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      String userName, String userEmail, SupervisorEntity? supervisor) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.person, size: 50, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: 4),
          Text(
            userEmail,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          if (supervisor != null) ...[
            const SizedBox(height: 8),
            Text(
              supervisor.position ?? '',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              supervisor.department ?? '',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoProfileMessage() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.info_outline,
              size: 48,
              color: AppColors.warning,
            ),
            const SizedBox(height: 16),
            const Text(
              'Perfil do Supervisor não encontrado',
              style: AppTextStyles.h6,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Os dados do perfil do supervisor não foram carregados. Tente recarregar a página ou entre em contato com o suporte.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Modular.get<SupervisorBloc>()
                    .add(LoadSupervisorDashboardDataEvent());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Recarregar'),
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

  Widget _buildReadOnlyFields(SupervisorEntity supervisor) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
                'Departamento', supervisor.department ?? '', Icons.business),
            _buildInfoRow('Cargo', supervisor.position ?? '', Icons.work),
            _buildInfoRow('ID', supervisor.id, Icons.badge),
            _buildInfoRow('Criado em', supervisor.createdAt.toString(),
                Icons.calendar_today),
            _buildInfoRow('Atualizado em',
                supervisor.updatedAt?.toString() ?? '', Icons.update),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableFields() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _departmentController,
              decoration: const InputDecoration(
                labelText: 'Departamento',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _positionController,
              decoration: const InputDecoration(
                labelText: 'Cargo',
                prefixIcon: Icon(Icons.work),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Campo obrigatório' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _toggleEditMode,
            icon: const Icon(Icons.cancel),
            label: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveChanges,
            icon: const Icon(Icons.save),
            label: const Text('Salvar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
