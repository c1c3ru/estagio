import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/enums/class_shift.dart';
import '../../../core/enums/internship_shift.dart';
import '../../../domain/entities/user_entity.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../shared/widgets/user_avatar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditMode = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers para campos editáveis
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _profilePictureController = TextEditingController();
  final _registrationController = TextEditingController();
  final _courseController = TextEditingController();
  final _advisorController = TextEditingController();
  final _departmentController = TextEditingController();
  final _positionController = TextEditingController();
  final _specializationController = TextEditingController();

  // Valores selecionados
  DateTime? _selectedBirthDate;
  ClassShift? _selectedClassShift;
  InternshipShift? _selectedInternshipShift;
  bool _isMandatoryInternship = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      _populateFields(authState.user);
    }
  }

  void _populateFields(UserEntity user) {
    _fullNameController.text = user.fullName;
    _emailController.text = user.email;
    _phoneController.text = user.phoneNumber ?? '';
    _profilePictureController.text = user.profilePictureUrl ?? '';

    // Se for estudante, preencher campos específicos
    if (user.role == UserRole.student) {
      // Aqui você precisaria carregar os dados específicos do estudante
      // através do BLoC correspondente
    }

    // Se for supervisor, preencher campos específicos
    if (user.role == UserRole.supervisor) {
      // Aqui você precisaria carregar os dados específicos do supervisor
      // através do BLoC correspondente
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (_isEditMode) {
        _loadUserData();
      }
    });
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      // Implementar lógica de salvamento
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
      setState(() {
        _isEditMode = false;
      });
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
    });
    _loadUserData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _profilePictureController.dispose();
    _registrationController.dispose();
    _courseController.dispose();
    _advisorController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditMode,
            ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AuthFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  const Text('Erro ao carregar perfil',
                      style: AppTextStyles.h6),
                  const SizedBox(height: 8),
                  Text(state.message, style: AppTextStyles.bodyMedium),
                ],
              ),
            );
          }

          if (state is AuthSuccess) {
            return _buildProfileContent(state.user);
          }

          return const Center(child: Text('Usuário não autenticado'));
        },
      ),
    );
  }

  Widget _buildProfileContent(UserEntity user) {
    // Exemplo de checagem de dados obrigatórios (ajuste conforme seu model real)
    final bool dadosIncompletos = user.fullName.isEmpty || user.email.isEmpty;

    if (dadosIncompletos) {
      // Força modo de edição ao entrar na tela se dados estão incompletos
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isEditMode) setState(() => _isEditMode = true);
      });
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64, color: AppColors.warning),
            const SizedBox(height: 16),
            const Text(
              'Seu perfil está incompleto!',
              style: AppTextStyles.h6,
            ),
            const SizedBox(height: 8),
            const Text(
              'Por favor, preencha seus dados de perfil para continuar usando o app.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _isEditMode = true);
              },
              icon: const Icon(Icons.edit),
              label: const Text('Preencher Perfil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(user),
            const SizedBox(height: 24),
            if (_isEditMode) ...[
              _buildEditableFields(user),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ] else ...[
              _buildReadOnlySections(user),
              const SizedBox(height: 24),
              _buildEditButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(UserEntity user) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            UserAvatar(
              imageUrl: user.profilePictureUrl,
              name: user.fullName,
              radius: 50,
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getRoleColor(user.role)),
              ),
              child: Text(
                _getRoleDisplayName(user.role),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _getRoleColor(user.role),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (user.emailConfirmed) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified,
                      size: 16, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(
                    'Email verificado',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlySections(UserEntity user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPersonalInfoSection(user),
        const SizedBox(height: 16),
        if (user.role == UserRole.student) ...[
          _buildStudentInfoSection(),
          const SizedBox(height: 16),
          _buildContractInfoSection(),
          const SizedBox(height: 16),
          _buildProgressSection(),
        ],
        if (user.role == UserRole.supervisor) ...[
          _buildSupervisorInfoSection(),
        ],
        _buildAccountInfoSection(user),
      ],
    );
  }

  Widget _buildPersonalInfoSection(UserEntity user) {
    return _buildInfoCard(
      title: 'Informações Pessoais',
      icon: Icons.person_outline,
      children: [
        _buildInfoRow('Nome Completo', user.fullName, Icons.person),
        if (user.phoneNumber != null)
          _buildInfoRow('Telefone', user.phoneNumber!, Icons.phone),
        _buildInfoRow('Email', user.email, Icons.email),
        _buildInfoRow(
            'Membro desde',
            DateFormat('dd/MM/yyyy').format(user.createdAt),
            Icons.calendar_today),
      ],
    );
  }

  Widget _buildStudentInfoSection() {
    // Mock data - substituir por dados reais do estudante
    return _buildInfoCard(
      title: 'Informações Acadêmicas',
      icon: Icons.school_outlined,
      children: [
        _buildInfoRow('Matrícula', '2023001234', Icons.badge),
        _buildInfoRow('Curso', 'Engenharia de Software', Icons.school),
        _buildInfoRow(
            'Orientador', 'Prof. Dr. João Silva', Icons.supervisor_account),
        _buildInfoRow('Data de Nascimento', '15/03/2000', Icons.cake),
        _buildInfoRow('Turno das Aulas', 'Matutino', Icons.schedule),
        _buildInfoRow('Estágio Obrigatório', 'Sim', Icons.star),
        _buildInfoRow('Turno do Estágio', 'Matutino', Icons.work),
      ],
    );
  }

  Widget _buildContractInfoSection() {
    return _buildInfoCard(
      title: 'Informações do Contrato',
      icon: Icons.description_outlined,
      children: [
        _buildInfoRow('Início do Contrato', '01/03/2024', Icons.calendar_today),
        _buildInfoRow('Fim do Contrato', '31/12/2024', Icons.calendar_today),
        _buildInfoRow('Horas Necessárias', '300h', Icons.hourglass_empty),
        _buildInfoRow('Horas Completas', '150h', Icons.hourglass_full),
        _buildInfoRow('Meta Semanal', '20h', Icons.trending_up),
      ],
    );
  }

  Widget _buildProgressSection() {
    const progress = 150 / 300; // Mock data
    return _buildInfoCard(
      title: 'Progresso do Estágio',
      icon: Icons.analytics_outlined,
      children: [
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Progresso Geral', style: AppTextStyles.bodyMedium),
                Text('${(progress * 100).toInt()}%',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    )),
              ],
            ),
            const SizedBox(height: 8),
            const LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildProgressCard(
                    'Completas',
                    '150h',
                    Icons.check_circle,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProgressCard(
                    'Restantes',
                    '150h',
                    Icons.pending,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSupervisorInfoSection() {
    return _buildInfoCard(
      title: 'Informações Profissionais',
      icon: Icons.work_outline,
      children: [
        _buildInfoRow(
            'Departamento', 'Tecnologia da Informação', Icons.business),
        _buildInfoRow('Cargo', 'Supervisor de Estágio', Icons.work),
        _buildInfoRow(
            'Especialização', 'Desenvolvimento de Software', Icons.science),
        _buildInfoRow('Código Funcional', 'SUP001', Icons.badge),
      ],
    );
  }

  Widget _buildAccountInfoSection(UserEntity user) {
    return _buildInfoCard(
      title: 'Informações da Conta',
      icon: Icons.account_circle_outlined,
      children: [
        _buildInfoRow('ID do Usuário', user.id, Icons.fingerprint),
        _buildInfoRow('Status', user.isActive ? 'Ativo' : 'Inativo',
            user.isActive ? Icons.check_circle : Icons.cancel),
        _buildInfoRow(
            'Última Atualização',
            user.updatedAt != null
                ? DateFormat('dd/MM/yyyy HH:mm').format(user.updatedAt!)
                : 'Nunca',
            Icons.update),
      ],
    );
  }

  Widget _buildEditableFields(UserEntity user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEditableCard(
          title: 'Informações Pessoais',
          icon: Icons.person_outline,
          children: [
            _buildTextField(
              controller: _fullNameController,
              label: 'Nome Completo',
              icon: Icons.person,
              validator: (value) =>
                  value?.isEmpty == true ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Telefone',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _profilePictureController,
              label: 'URL da Foto de Perfil',
              icon: Icons.link,
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        if (user.role == UserRole.student) ...[
          const SizedBox(height: 16),
          _buildEditableCard(
            title: 'Informações Acadêmicas',
            icon: Icons.school_outlined,
            children: [
              _buildTextField(
                controller: _registrationController,
                label: 'Número de Matrícula',
                icon: Icons.badge,
                validator: (value) =>
                    value?.isEmpty == true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _courseController,
                label: 'Curso',
                icon: Icons.school,
                validator: (value) =>
                    value?.isEmpty == true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _advisorController,
                label: 'Orientador',
                icon: Icons.supervisor_account,
                validator: (value) =>
                    value?.isEmpty == true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              _buildDateField(),
              const SizedBox(height: 16),
              _buildDropdownField<ClassShift>(
                label: 'Turno das Aulas',
                icon: Icons.schedule,
                value: _selectedClassShift,
                items: ClassShift.values
                    .map((shift) => DropdownMenuItem(
                        value: shift, child: Text(shift.displayName)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedClassShift = value),
              ),
              const SizedBox(height: 16),
              _buildDropdownField<InternshipShift>(
                label: 'Turno do Estágio',
                icon: Icons.work,
                value: _selectedInternshipShift,
                items: InternshipShift.values
                    .map((shift) => DropdownMenuItem(
                        value: shift, child: Text(shift.displayName)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedInternshipShift = value),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Estágio Obrigatório'),
                value: _isMandatoryInternship,
                onChanged: (value) =>
                    setState(() => _isMandatoryInternship = value),
                secondary: const Icon(Icons.star),
              ),
            ],
          ),
        ],
        if (user.role == UserRole.supervisor) ...[
          const SizedBox(height: 16),
          _buildEditableCard(
            title: 'Informações Profissionais',
            icon: Icons.work_outline,
            children: [
              _buildTextField(
                controller: _departmentController,
                label: 'Departamento',
                icon: Icons.business,
                validator: (value) =>
                    value?.isEmpty == true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _positionController,
                label: 'Cargo',
                icon: Icons.work,
                validator: (value) =>
                    value?.isEmpty == true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _specializationController,
                label: 'Especialização',
                icon: Icons.science,
                validator: (value) =>
                    value?.isEmpty == true ? 'Campo obrigatório' : null,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _cancelEdit,
            icon: const Icon(Icons.cancel),
            label: const Text('Cancelar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
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
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _toggleEditMode,
        icon: const Icon(Icons.edit),
        label: const Text('Editar Perfil'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // Widgets auxiliares
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title, style: AppTextStyles.h6),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildEditableCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title, style: AppTextStyles.h6),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
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

  Widget _buildProgressCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.caption),
          Text(value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              )),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Data de Nascimento',
        prefixIcon: Icon(Icons.cake),
        border: OutlineInputBorder(),
      ),
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedBirthDate ??
              DateTime.now().subtract(const Duration(days: 365 * 18)),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() => _selectedBirthDate = date);
        }
      },
      controller: TextEditingController(
        text: _selectedBirthDate != null
            ? DateFormat('dd/MM/yyyy').format(_selectedBirthDate!)
            : '',
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return AppColors.primary;
      case UserRole.supervisor:
        return AppColors.success;
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Estudante';
      case UserRole.supervisor:
        return 'Supervisor';
    }
  }
}
