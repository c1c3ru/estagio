import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/supervisor_entity.dart';
import '../bloc/supervisor_bloc.dart';
import '../bloc/supervisor_event.dart';
import '../bloc/supervisor_state.dart';

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
    Modular.get<SupervisorBloc>().add(LoadSupervisorDashboardDataEvent());
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
        if (state is SupervisorLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        SupervisorEntity? supervisor;
        if (state is SupervisorDashboardLoadSuccess &&
            state.supervisorProfile != null) {
          supervisor = state.supervisorProfile;
          _supervisor = supervisor;
        }
        if (supervisor == null) {
          return const Center(
              child: Text('Dados do supervisor não encontrados.'));
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Perfil do Supervisor'),
            actions: [
              if (!_isEditMode)
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
                  _buildHeader(supervisor),
                  const SizedBox(height: 24),
                  _isEditMode
                      ? _buildEditableFields()
                      : _buildReadOnlyFields(supervisor),
                  const SizedBox(height: 24),
                  if (_isEditMode) _buildActionButtons(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(SupervisorEntity supervisor) {
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
            supervisor.position ?? '',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: 4),
          Text(
            supervisor.department ?? '',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
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
