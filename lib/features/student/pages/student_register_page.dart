import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_bloc.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_event.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_state.dart'
    as custom_auth;
import 'package:gestao_de_estagio/features/auth/widgets/auth_text_field.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/enums/class_shift.dart';
import '../../../core/enums/internship_shift.dart';
import '../../../core/utils/validators.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/feedback_service.dart';
import 'package:gestao_de_estagio/features/shared/widgets/student_animation.dart';
import '../../../core/theme/app_theme_extensions.dart';

class StudentRegisterPage extends StatefulWidget {
  const StudentRegisterPage({super.key});

  @override
  State<StudentRegisterPage> createState() => _StudentRegisterPageState();
}

class _StudentRegisterPageState extends State<StudentRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _registrationController = TextEditingController();
  final _courseController = TextEditingController();
  final _advisorController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserRole _selectedRole = UserRole.student;

  // Enums e Datas
  ClassShift? _selectedClassShift;
  InternshipShift? _selectedInternshipShift;
  DateTime? _selectedBirthDate;
  DateTime? _selectedContractStartDate;
  DateTime? _selectedContractEndDate;

  // Novos campos para estágio obrigatório e supervisor
  bool _isMandatoryInternship = false;
  bool _receivesScholarship = false;
  String? _selectedSupervisorId;
  List<Map<String, dynamic>> _supervisors = [];
  bool _loadingSupervisors = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = UserRole.student;
    _fetchSupervisors();
  }

  Future<void> _fetchSupervisors() async {
    setState(() => _loadingSupervisors = true);
    try {
      final supabase = Supabase.instance.client;
      if (kDebugMode) {
        print('🔍 Buscando supervisores...');
      }

      // Primeiro, verificar se há dados na tabela
      final allSupervisors = await supabase.from('supervisors').select('id');
      if (kDebugMode) {
        print(
            '📈 Total de registros na tabela supervisors: ${allSupervisors.length}');
      }

      final response = await supabase
          .from('supervisors')
          .select('id, full_name')
          .order('full_name');

      if (kDebugMode) {
        print('📊 Supervisores encontrados: ${response.length}');
      }
      if (kDebugMode) {
        print('📋 Dados: $response');
      }

      setState(() {
        _supervisors = List<Map<String, dynamic>>.from(response);
        _loadingSupervisors = false;
      });

      if (_supervisors.isEmpty) {
        if (!mounted) return;
        FeedbackService.showWarning(context,
            'Nenhum supervisor encontrado. Cadastre um supervisor primeiro.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao buscar supervisores: $e');
      }
      setState(() => _loadingSupervisors = false);
      if (!mounted) return;
      FeedbackService.showError(context, 'Erro ao buscar supervisores: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _registrationController.dispose();
    _courseController.dispose();
    _advisorController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedRole == UserRole.student) {
        // Validação removida pois _isMandatoryInternship agora é bool (não nullable)
        if (_selectedSupervisorId == null) {
          FeedbackService.showWarning(context, 'Selecione um supervisor.');
          return;
        }
      }

      // Validação adicional para os novos campos
      if (_selectedClassShift == null ||
          _selectedInternshipShift == null ||
          _selectedBirthDate == null ||
          _selectedContractStartDate == null ||
          _selectedContractEndDate == null) {
        FeedbackService.showWarning(
            context, 'Preencha todos os campos de data e turno.');
        return;
      }

      BlocProvider.of<AuthBloc>(context).add(
        RegisterRequested(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
          registration: _registrationController.text.trim(),
          isMandatoryInternship: _isMandatoryInternship,
          receivesScholarship: _receivesScholarship,
          supervisorId: _selectedSupervisorId,
          // Novos campos
          course: _courseController.text.trim(),
          advisorName: _advisorController.text.trim(),
          classShift: _selectedClassShift,
          internshipShift: _selectedInternshipShift,
          birthDate: _selectedBirthDate,
          contractStartDate: _selectedContractStartDate,
          contractEndDate: _selectedContractEndDate,
        ),
      );
    }
  }

  void _onLoginPressed() {
    Modular.to.navigate('/login');
  }

  Future<void> _selectDate(
      BuildContext context, void Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2101),
      locale: const Locale('pt', 'BR'),
    );
    await Future.delayed(
        const Duration(milliseconds: 100)); // Evita erro de navigator lock
    if (picked != null && mounted) {
      onDateSelected(picked);
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      border: const OutlineInputBorder(),
      filled: true,
      fillColor: AppColors.surface,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: _buildInputDecoration(label, Icons.calendar_today_outlined),
        child: Text(
          selectedDate != null
              ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
              : 'Selecione a data',
          style: TextStyle(
            color: selectedDate != null
                ? AppColors.textPrimaryDark
                : AppColors.textHint,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Modular.to.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Modular.to.pop(),
          ),
        ),
        body: BlocConsumer<AuthBloc, custom_auth.AuthState>(
          listener: (context, state) {
            if (state is custom_auth.AuthFailure) {
              FeedbackService.showError(context, state.message);
            } else if (state is custom_auth.AuthEmailConfirmationRequired) {
              FeedbackService.showWarning(context, state.message);
              Modular.to.pushNamed('/auth/email-confirmation',
                  arguments: state.email);
            } else if (state is custom_auth.AuthSuccess) {
              FeedbackService.showSuccess(
                  context, 'Cadastro realizado com sucesso!');
              Modular.to.navigate('/login');
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(context.tokens.spaceXl),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Animação de estudante no topo
                        const StudentAnimation(size: 120),
                        SizedBox(height: context.tokens.spaceLg),
                        const Text(
                          'Cadastro de Estudante/Bolsista/Estagiário',
                          style: AppTextStyles.h3,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.tokens.spaceSm),
                        Text(
                          'Preencha os dados para se cadastrar como estudante, bolsista ou estagiário',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.tokens.spaceXl * 2),
                        AuthTextField(
                          controller: _courseController,
                          label: 'Curso',
                          keyboardType: TextInputType.text,
                          prefixIcon: Icons.school_outlined,
                          validator: (value) =>
                              Validators.required(value, fieldName: 'Curso'),
                        ),
                        SizedBox(height: context.tokens.spaceLg),
                        AuthTextField(
                          controller: _advisorController,
                          label: 'Nome do Orientador',
                          keyboardType: TextInputType.name,
                          prefixIcon: Icons.person_search_outlined,
                          validator: (value) => Validators.required(value,
                              fieldName: 'Nome do Orientador'),
                        ),
                        SizedBox(height: context.tokens.spaceLg),
                        AuthTextField(
                          controller: _nameController,
                          label: 'Nome Completo',
                          keyboardType: TextInputType.name,
                          prefixIcon: Icons.person_outlined,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return AppStrings.fieldRequired;
                            }
                            if (value!.length < 2) {
                              return 'Nome deve ter pelo menos 2 caracteres';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: context.tokens.spaceLg),
                        AuthTextField(
                          controller: _emailController,
                          label: AppStrings.email,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: Validators.email,
                        ),
                        SizedBox(height: context.tokens.spaceLg),
                        // Matrícula de estudante/bolsista/estagiário
                        AuthTextField(
                          controller: _registrationController,
                          label: 'Matrícula do estudante/bolsista/estagiário',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.badge_outlined,
                          validator: Validators.studentRegistration,
                        ),
                        SizedBox(height: context.tokens.spaceLg),
                        // Data de Nascimento
                        _buildDateField(
                          context: context,
                          label: 'Data de Nascimento',
                          selectedDate: _selectedBirthDate,
                          onTap: () => _selectDate(context, (date) {
                            setState(() => _selectedBirthDate = date);
                          }),
                        ),
                        SizedBox(height: context.tokens.spaceLg),
                        DropdownButtonFormField<ClassShift>(
                          value: _selectedClassShift,
                          decoration: _buildInputDecoration(
                              'Turno das Aulas', Icons.schedule_outlined),
                          style: const TextStyle(
                              color: AppColors.textPrimaryDark, fontSize: 16),
                          dropdownColor: AppColors.white,
                          iconEnabledColor: AppColors.primary,
                          items: ClassShift.values
                              .map((shift) => DropdownMenuItem(
                                    value: shift,
                                    child: Text(
                                      shift.displayName,
                                      style: const TextStyle(
                                          color: AppColors.textPrimaryDark),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedClassShift = value);
                          },
                          validator: (value) =>
                              value == null ? 'Selecione um turno' : null,
                        ),
                        SizedBox(height: context.tokens.spaceLg),
                        DropdownButtonFormField<InternshipShift>(
                          value: _selectedInternshipShift,
                          decoration: _buildInputDecoration(
                              'Turno do Estágio', Icons.work_history_outlined),
                          style: const TextStyle(
                              color: AppColors.textPrimaryDark, fontSize: 16),
                          dropdownColor: AppColors.white,
                          iconEnabledColor: AppColors.primary,
                          items: InternshipShift.values
                              .map((shift) => DropdownMenuItem(
                                    value: shift,
                                    child: Text(
                                      shift.displayName,
                                      style: const TextStyle(
                                          color: AppColors.textPrimaryDark),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedInternshipShift = value);
                          },
                          validator: (value) =>
                              value == null ? 'Selecione um turno' : null,
                        ),
                        SizedBox(height: context.tokens.spaceLg),
                        // Estágio obrigatório
                        SwitchListTile(
                          title: const Text('Estágio obrigatório?',
                              style:
                                  TextStyle(color: AppColors.textPrimaryDark)),
                          value: _isMandatoryInternship,
                          onChanged: (value) {
                            setState(() => _isMandatoryInternship = value);
                          },
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                        ),
                        SwitchListTile(
                          title: const Text('Recebe bolsa?',
                              style:
                                  TextStyle(color: AppColors.textPrimaryDark)),
                          value: _receivesScholarship,
                          onChanged: (value) {
                            setState(() => _receivesScholarship = value);
                          },
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                        ),
                        SizedBox(height: context.tokens.spaceLg),
                        // Seleção de supervisor
                        _loadingSupervisors
                            ? const Center(child: CircularProgressIndicator())
                            : _supervisors.isEmpty
                                ? Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(context.tokens.spaceLg),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade50,
                                          borderRadius: BorderRadius.circular(context.tokens.radiusSm),
                                          border: Border.all(
                                              color: Colors.orange.shade200),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.warning_amber,
                                                color: Colors.orange.shade600),
                                            SizedBox(width: context.tokens.spaceMd),
                                            Expanded(
                                              child: Text(
                                                'Nenhum supervisor encontrado. É necessário cadastrar um supervisor primeiro.',
                                                style: TextStyle(
                                                    color:
                                                        Colors.orange.shade800),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: context.tokens.spaceSm),
                                      TextButton.icon(
                                        onPressed: _fetchSupervisors,
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Tentar novamente'),
                                      ),
                                    ],
                                  )
                                : DropdownButtonFormField<String>(
                                    value: _selectedSupervisorId,
                                    decoration: _buildInputDecoration(
                                        'Supervisor do Estágio',
                                        Icons.supervisor_account_outlined),
                                    style: const TextStyle(
                                        color: AppColors.textPrimaryDark,
                                        fontSize: 16),
                                    dropdownColor: AppColors.white,
                                    iconEnabledColor: AppColors.primary,
                                    items: _supervisors
                                        .map((supervisor) => DropdownMenuItem(
                                              value: supervisor['id'] as String,
                                              child: Text(
                                                supervisor['full_name']
                                                    as String,
                                                style: const TextStyle(
                                                    color: AppColors
                                                        .textPrimaryDark),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (id) {
                                      setState(
                                          () => _selectedSupervisorId = id);
                                    },
                                    validator: (value) => value == null
                                        ? 'Selecione um supervisor'
                                        : null,
                                  ),
                        SizedBox(height: context.tokens.spaceLg),
                        _buildDateField(
                          context: context,
                          label: 'Data de Início do Contrato',
                          selectedDate: _selectedContractStartDate,
                          onTap: () => _selectDate(context, (date) {
                            setState(() => _selectedContractStartDate = date);
                          }),
                        ),
                        SizedBox(height: context.tokens.spaceLg),
                        _buildDateField(
                          context: context,
                          label: 'Data de Fim do Contrato',
                          selectedDate: _selectedContractEndDate,
                          onTap: () => _selectDate(context, (date) {
                            setState(() => _selectedContractEndDate = date);
                          }),
                        ),
                        SizedBox(height: context.tokens.spaceLg),
                        AuthTextField(
                          controller: _passwordController,
                          label: AppStrings.password,
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock_outline,
                          validator: (value) =>
                              Validators.password(value, minLength: 6),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
                            onPressed: () {
                              setState(
                                  () => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                        SizedBox(height: context.tokens.spaceLg),
                        AuthTextField(
                          controller: _confirmPasswordController,
                          label: AppStrings.confirmPassword,
                          obscureText: _obscureConfirmPassword,
                          prefixIcon: Icons.lock_outline,
                          validator: (value) => Validators.confirmPassword(
                              _passwordController.text, value),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
                            onPressed: () {
                              setState(() => _obscureConfirmPassword =
                                  !_obscureConfirmPassword);
                            },
                          ),
                        ),
                        SizedBox(height: context.tokens.spaceLg),
                        const Text(
                          'Após o cadastro, você receberá um e-mail de confirmação. É necessário confirmar o e-mail para acessar o sistema.',
                          style: TextStyle(color: Colors.orange, fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.tokens.spaceXl),
                        // Botão de cadastro
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.person_add),
                            label: state is custom_auth.AuthLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Cadastrar',
                                    style: TextStyle(fontSize: 17)),
                            onPressed: state is custom_auth.AuthLoading
                                ? null
                                : _onRegisterPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              padding: EdgeInsets.symmetric(vertical: context.tokens.spaceLg),
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(context.tokens.radiusSm),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: context.tokens.spaceLg),
                        TextButton(
                          onPressed: _onLoginPressed,
                          child: const Text('Já tem uma conta? Entrar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
