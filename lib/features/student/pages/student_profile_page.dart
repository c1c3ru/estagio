// lib/features/student/presentation/pages/student_profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:gestao_de_estagio/core/enums/class_shift.dart';
import 'package:gestao_de_estagio/core/enums/internship_shift.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_bloc.dart';
import 'package:gestao_de_estagio/features/auth/bloc/auth_state.dart'
    as auth_state;
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../domain/entities/student_entity.dart';
import '../../../../domain/entities/contract_entity.dart';
import '../../../../domain/entities/supervisor_entity.dart';
import '../../../../domain/usecases/contract/get_active_contract_by_student_usecase.dart';
import '../../../../domain/usecases/supervisor/get_supervisor_by_id_usecase.dart';
import '../../../../domain/usecases/supervisor/get_all_supervisors_usecase.dart';

import '../bloc/student_bloc.dart' as student_bloc;
import '../bloc/student_event.dart' as student_event;
import '../bloc/student_state.dart' as student_state;
// Importe o enum ClassShift e InternshipShift

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _courseController = TextEditingController();
  final _advisorNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _profilePictureUrlController = TextEditingController();

  DateTime? _selectedBirthDate;
  ClassShift? _selectedClassShift;
  InternshipShift? _selectedInternshipShift;
  bool? _selectedIsMandatoryInternship;
  SupervisorEntity? _selectedSupervisor;
  List<SupervisorEntity> _supervisors = [];
  bool _loadingSupervisors = false;

  bool _isEditMode = false;
  StudentEntity? _currentStudent;
  String? _currentUserId;

  late student_bloc.StudentBloc _studentBloc;
  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _studentBloc = Modular.get<student_bloc.StudentBloc>();
    _authBloc = Modular.get<AuthBloc>();

    // Obter o ID do usuário atual
    final authState = _authBloc.state;
    if (authState is auth_state.AuthSuccess) {
      _currentUserId = authState.user.id;
    }

    _loadStudentData();
  }

  void _loadStudentData() {
    if (_currentUserId != null) {
      final currentStudentState = _studentBloc.state;
      if (currentStudentState is student_state.StudentDashboardLoadSuccess &&
          currentStudentState.student.id == _currentUserId) {
        _currentStudent = currentStudentState.student;
        _populateFields(currentStudentState.student);
      } else {
        _studentBloc.add(student_event.LoadStudentDashboardDataEvent(
            userId: _currentUserId!));
      }
    }
  }

  void _populateFields(StudentEntity student) {
    _fullNameController.text = student.fullName;
    _registrationNumberController.text = student.registrationNumber;
    _courseController.text = student.course;
    _advisorNameController.text = student.advisorName;
    _phoneNumberController.text = student.phoneNumber ?? '';
    _profilePictureUrlController.text = student.profilePictureUrl ?? '';

    _selectedBirthDate = student.birthDate;
    _birthDateController.text =
        DateFormat('dd/MM/yyyy').format(student.birthDate);

    _selectedClassShift = ClassShift.values.firstWhere(
      (e) => e.name == student.classShift,
      orElse: () => ClassShift.morning,
    );
    _selectedIsMandatoryInternship = student.isMandatoryInternship;
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (_isEditMode) {
        _loadSupervisors();
        if (_currentStudent != null) {
          _populateFields(_currentStudent!);
        } else {
          // Se não há dados do estudante, preencher com dados básicos do usuário
          final authState = _authBloc.state;
          if (authState is auth_state.AuthSuccess) {
            _fullNameController.text = authState.user.fullName;
            _registrationNumberController.text = '';
            _courseController.text = '';
            _advisorNameController.text = '';
            _phoneNumberController.text = authState.user.phoneNumber ?? '';
            _profilePictureUrlController.text =
                authState.user.profilePictureUrl ?? '';
            _selectedBirthDate = null;
            _selectedClassShift = null;
            _selectedInternshipShift = null;
            _selectedIsMandatoryInternship = false;
            _selectedSupervisor = null;
          }
        }
      }
    });
  }

  Future<void> _loadSupervisors() async {
    setState(() => _loadingSupervisors = true);
    final usecase = Modular.get<GetAllSupervisorsUsecase>();
    final result = await usecase();
    result.fold(
      (failure) {
        setState(() => _supervisors = []);
      },
      (supervisors) {
        setState(() => _supervisors = supervisors);
        // Se o estudante já tem supervisor, selecionar
        if (_currentStudent?.supervisorId != null) {
          _selectedSupervisor = supervisors.firstWhere(
            (s) => s.id == _currentStudent!.supervisorId,
            orElse: () => supervisors.first,
          );
        }
      },
    );
    setState(() => _loadingSupervisors = false);
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_currentUserId != null) {
        if (_currentStudent != null) {
          // Atualizar perfil existente
          _studentBloc.add(student_event.UpdateStudentProfileInfoEvent(
            userId: _currentUserId!,
            params: student_event.UpdateStudentProfileEventParams(
              fullName: _fullNameController.text.trim(),
              registrationNumber: _registrationNumberController.text.trim(),
              course: _courseController.text.trim(),
              advisorName: _advisorNameController.text.trim(),
              phoneNumber: _phoneNumberController.text.trim().isEmpty
                  ? null
                  : _phoneNumberController.text.trim(),
              profilePictureUrl:
                  _profilePictureUrlController.text.trim().isEmpty
                      ? null
                      : _profilePictureUrlController.text.trim(),
              birthDate: _selectedBirthDate,
              classShift: _selectedClassShift,
              internshipShift: _selectedInternshipShift,
              isMandatoryInternship: _selectedIsMandatoryInternship ?? false,
            ),
          ));
        } else {
          // Criar novo perfil via BLoC para manter padrão
          final params = student_event.UpdateStudentProfileEventParams(
            fullName: _fullNameController.text.trim(),
            registrationNumber: _registrationNumberController.text.trim(),
            course: _courseController.text.trim(),
            advisorName: _advisorNameController.text.trim(),
            phoneNumber: _phoneNumberController.text.trim().isEmpty
                ? null
                : _phoneNumberController.text.trim(),
            profilePictureUrl: _profilePictureUrlController.text.trim().isEmpty
                ? null
                : _profilePictureUrlController.text.trim(),
            birthDate: _selectedBirthDate ?? DateTime(2000, 1, 1),
            classShift: _selectedClassShift ?? ClassShift.morning,
            internshipShift: _selectedInternshipShift ?? InternshipShift.morning,
            isMandatoryInternship: _selectedIsMandatoryInternship ?? false,
          );
          _studentBloc.add(student_event.UpdateStudentProfileInfoEvent(
            userId: _currentUserId!,
            params: params,
          ));
        }
      }

      setState(() {
        _isEditMode = false;
      });
    }
  }

  void _cancelEdit() {
    if (_currentStudent != null) {
      _populateFields(_currentStudent!);
    } else {
      // Se não há dados, limpar os campos
      _fullNameController.clear();
      _registrationNumberController.clear();
      _courseController.clear();
      _advisorNameController.clear();
      _phoneNumberController.clear();
      _birthDateController.clear();
      _profilePictureUrlController.clear();
      _selectedBirthDate = null;
      _selectedClassShift = null;
      _selectedInternshipShift = null;
      _selectedIsMandatoryInternship = false;
    }
    setState(() {
      _isEditMode = false;
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _registrationNumberController.dispose();
    _courseController.dispose();
    _advisorNameController.dispose();
    _phoneNumberController.dispose();
    _birthDateController.dispose();
    _profilePictureUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditMode,
            ),
        ],
      ),
      body: BlocConsumer<student_bloc.StudentBloc, student_state.StudentState>(
        bloc: _studentBloc,
        listener: (context, state) {
          if (state is student_state.StudentOperationFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
          } else if (state is student_state.StudentProfileUpdateSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
            setState(() {
              _currentStudent = state.updatedStudent;
              _isEditMode = false;
            });
          } else if (state is student_state.StudentDashboardLoadSuccess) {
            setState(() {
              _currentStudent = state.student;
              if (!_isEditMode) {
                _populateFields(state.student);
              }
            });
          }
        },
        builder: (context, state) {
          if (state is student_state.StudentLoading &&
              _currentStudent == null) {
            return const LoadingIndicator();
          }

          if (state is student_state.StudentOperationFailure &&
              _currentStudent == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 64,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.incompleteProfile,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Para continuar usando o aplicativo, precisamos de algumas informações adicionais. Clique em "${AppStrings.completeProfile}" para adicionar seus dados.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    AppButton(
                      text: AppStrings.completeProfile,
                      onPressed: _toggleEditMode,
                      icon: Icons.edit,
                    ),
                  ],
                ),
              ),
            );
          }

          final student = _currentStudent;
          if (student == null) {
            if (_currentUserId != null &&
                state is! student_state.StudentLoading) {
              _studentBloc.add(student_event.LoadStudentDashboardDataEvent(
                  userId: _currentUserId!));
              return const LoadingIndicator();
            }

            // Mostrar mensagem informativa quando não há dados do estudante
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 64,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.incompleteProfile,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Para continuar usando o aplicativo, precisamos de algumas informações adicionais. Clique em "${AppStrings.completeProfile}" para adicionar seus dados.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    AppButton(
                      text: AppStrings.completeProfile,
                      onPressed: _toggleEditMode,
                      icon: Icons.edit,
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isEditMode) ...[
                    _buildEditableFields(context),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Cancelar',
                            onPressed: _cancelEdit,
                            type: AppButtonType.outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: BlocBuilder<student_bloc.StudentBloc,
                              student_state.StudentState>(
                            bloc: _studentBloc,
                            builder: (context, state) {
                              return AppButton(
                                text: AppStrings.save,
                                isLoading:
                                    state is student_state.StudentLoading,
                                onPressed: _saveChanges,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    _buildReadOnlyProfile(context, student),
                    const SizedBox(height: 24),
                    AppButton(
                      text: AppStrings.editProfile,
                      onPressed: _toggleEditMode,
                      icon: Icons.edit,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.supervisor_account),
                      label: const Text('Ver Supervisores'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        Modular.to.pushNamed('/supervisor/students');
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReadOnlyProfile(BuildContext context, StudentEntity student) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Foto de perfil
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            backgroundImage: student.profilePictureUrl != null
                ? NetworkImage(student.profilePictureUrl!)
                : null,
            child: student.profilePictureUrl == null
                ? Icon(Icons.person,
                    size: 40,
                    color: Theme.of(context).colorScheme.onPrimaryContainer)
                : null,
          ),
        ),
        const SizedBox(height: 24),

        // Informações do estudante
        _buildReadOnlyInfo(context, 'Nome Completo', student.fullName,
            icon: Icons.person_outline),
        _buildReadOnlyInfo(
            context, 'Nº de Matrícula', student.registrationNumber,
            icon: Icons.badge_outlined),
        _buildReadOnlyInfo(context, 'Curso', student.course,
            icon: Icons.school_outlined),
        _buildReadOnlyInfo(context, 'Orientador(a)', student.advisorName,
            icon: Icons.supervisor_account_outlined),
        if (student.phoneNumber != null)
          _buildReadOnlyInfo(context, 'Telefone', student.phoneNumber!,
              icon: Icons.phone_outlined),
        _buildReadOnlyInfo(context, 'Data de Nascimento',
            DateFormat('dd/MM/yyyy').format(student.birthDate),
            icon: Icons.cake_outlined),
        _buildReadOnlyInfo(context, 'Turno das Aulas', student.classShift,
            icon: Icons.schedule_outlined),
        _buildReadOnlyInfo(context, 'Estágio Obrigatório',
            student.isMandatoryInternship ? 'Sim' : 'Não',
            icon: Icons.star_outline),

        const SizedBox(height: 24),

        // Supervisor do contrato ativo (com cache para evitar loop infinito)
        _buildSupervisorInfoWithCache(context, student.id),

        // Informações do contrato
        Text(
          'Informações do Contrato',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildReadOnlyInfo(context, 'Início do Contrato',
            DateFormat('dd/MM/yyyy').format(student.contractStartDate),
            icon: Icons.calendar_today_outlined),
        _buildReadOnlyInfo(context, 'Fim do Contrato',
            DateFormat('dd/MM/yyyy').format(student.contractEndDate),
            icon: Icons.calendar_today_outlined),
        _buildReadOnlyInfo(context, 'Horas Necessárias',
            '${student.totalHoursRequired.toStringAsFixed(1)}h',
            icon: Icons.hourglass_empty_outlined),
        _buildReadOnlyInfo(context, 'Horas Completas',
            '${student.totalHoursCompleted.toStringAsFixed(1)}h',
            icon: Icons.hourglass_full_outlined),
      ],
    );
  }

  Widget _buildEditableFields(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Center(
            child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: _profilePictureUrlController.text.isNotEmpty
                  ? NetworkImage(_profilePictureUrlController.text)
                  : null,
              child: _profilePictureUrlController.text.isEmpty
                  ? Icon(Icons.person_add,
                      size: 40,
                      color: Theme.of(context).colorScheme.onPrimaryContainer)
                  : null,
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _profilePictureUrlController,
              labelText: 'URL da Foto de Perfil (Opcional)',
              hintText: 'https://exemplo.com/sua-foto.jpg',
              prefixIcon: Icons.link_outlined,
              keyboardType: TextInputType.url,
              onChanged: (value) =>
                  setState(() {}), // Para atualizar a prévia da imagem
            ),
          ],
        )),
        const SizedBox(height: 20),
        AppTextField(
          controller: _fullNameController,
          labelText: 'Nome Completo',
          prefixIcon: Icons.person_outline,
          validator: (value) =>
              Validators.required(value, fieldName: 'Nome Completo'),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _registrationNumberController,
          labelText: 'Nº de Matrícula',
          prefixIcon: Icons.badge_outlined,
          validator: Validators.studentRegistration,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _courseController,
          labelText: 'Curso',
          prefixIcon: Icons.school_outlined,
          validator: (value) => Validators.required(value, fieldName: 'Curso'),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _advisorNameController,
          labelText: 'Nome do Orientador(a)',
          prefixIcon: Icons.supervisor_account_outlined,
          validator: (value) =>
              Validators.required(value, fieldName: 'Orientador(a)'),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _phoneNumberController,
          labelText: 'Telefone (Opcional)',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        // Data de Nascimento
        Builder(
          builder: (BuildContext context) {
            return AppTextField(
              controller: _birthDateController,
              labelText: 'Data de Nascimento',
              prefixIcon: Icons.cake_outlined,
              readOnly: true,
              validator: (v) => _selectedBirthDate == null
                  ? 'Campo obrigatório'
                  : Validators.dateNotFuture(_selectedBirthDate,
                      fieldName: 'Data de Nascimento'),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedBirthDate ??
                      DateTime.now().subtract(
                          const Duration(days: 365 * 18)), // Ex: 18 anos atrás
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                  locale: const Locale('pt', 'BR'),
                );
                if (picked != null && picked != _selectedBirthDate) {
                  setState(() {
                    _selectedBirthDate = picked;
                    _birthDateController.text =
                        DateFormat('dd/MM/yyyy').format(picked);
                  });
                }
              },
            );
          },
        ),
        const SizedBox(height: 16),
        // Turno das Aulas
        DropdownButtonFormField<ClassShift>(
          value: _selectedClassShift,
          decoration: InputDecoration(
            labelText: 'Turno das Aulas',
            prefixIcon: Icon(Icons.schedule_outlined,
                color: theme.inputDecorationTheme.prefixIconColor),
            border: theme.inputDecorationTheme.border,
          ),
          items: ClassShift.values.map((ClassShift shift) {
            return DropdownMenuItem<ClassShift>(
              value: shift,
              child: Text(shift.displayName),
            );
          }).toList(),
          onChanged: (ClassShift? newValue) {
            setState(() {
              _selectedClassShift = newValue;
            });
          },
          validator: (value) =>
              value == null ? 'Selecione um turno válido' : null,
        ),
        const SizedBox(height: 16),
        // Estágio Obrigatório
        SwitchListTile(
          title: const Text('Estágio Obrigatório?'),
          value: _selectedIsMandatoryInternship ?? false,
          onChanged: (bool value) {
            setState(() {
              _selectedIsMandatoryInternship = value;
            });
          },
          secondary: Icon(Icons.star_border_outlined,
              color: theme.colorScheme.primary),
          activeColor: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        // Supervisor
        if (_loadingSupervisors)
          const Center(child: CircularProgressIndicator())
        else
          DropdownButtonFormField<SupervisorEntity>(
            value: _selectedSupervisor,
            decoration: InputDecoration(
              labelText: 'Supervisor (Opcional)',
              prefixIcon: Icon(Icons.supervisor_account,
                  color: theme.inputDecorationTheme.prefixIconColor),
              border: theme.inputDecorationTheme.border,
            ),
            items: [
              const DropdownMenuItem<SupervisorEntity>(
                value: null,
                child: Text('Nenhum supervisor selecionado'),
              ),
              ..._supervisors.map((SupervisorEntity supervisor) {
                return DropdownMenuItem<SupervisorEntity>(
                  value: supervisor,
                  child: Text(
                    supervisor.position != null && supervisor.position!.isNotEmpty
                        ? '${supervisor.fullName} - ${supervisor.position}'
                        : supervisor.fullName,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
            ],
            onChanged: (SupervisorEntity? newValue) {
              setState(() {
                _selectedSupervisor = newValue;
              });
            },
          ),
        const SizedBox(height: 16),
        DropdownButtonFormField<InternshipShift>(
          value: _selectedInternshipShift,
          decoration: InputDecoration(
            labelText: 'Turno do Estágio',
            prefixIcon: Icon(Icons.work_outline,
                color: theme.inputDecorationTheme.prefixIconColor),
            border: theme.inputDecorationTheme.border,
          ),
          items: InternshipShift.values.map((InternshipShift shift) {
            return DropdownMenuItem<InternshipShift>(
              value: shift,
              child: Text(shift.displayName),
            );
          }).toList(),
          onChanged: (InternshipShift? newValue) {
            setState(() {
              _selectedInternshipShift = newValue;
            });
          },
        ),
      ],
    );
  }

  Widget _buildReadOnlyInfo(BuildContext context, String label, String value,
      {IconData? icon}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 22, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
          ] else ...[
            const SizedBox(width: 38),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.hintColor, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  // Cache para evitar rebuilds infinitos
  ContractEntity? _cachedContract;
  SupervisorEntity? _cachedSupervisor;
  String? _lastStudentId;
  bool _isLoadingContract = false;
  bool _isLoadingSupervisor = false;

  /// Versão inteligente com cache que preserva funcionalidade mas evita loop infinito
  Widget _buildSupervisorInfoWithCache(BuildContext context, String studentId) {
    // Se mudou o estudante, limpa o cache
    if (_lastStudentId != studentId) {
      _cachedContract = null;
      _cachedSupervisor = null;
      _lastStudentId = studentId;
      _isLoadingContract = false;
      _isLoadingSupervisor = false;
    }

    // Se já tem dados em cache, usa eles
    if (_cachedContract != null && _cachedSupervisor != null) {
      return _buildReadOnlyInfo(
        context,
        'Supervisor do Contrato Ativo',
        '${_cachedSupervisor!.position} - ${_cachedSupervisor!.department}',
        icon: Icons.verified_user_outlined,
      );
    }

    // Se não tem contrato em cache e não está carregando, inicia carregamento
    if (_cachedContract == null && !_isLoadingContract) {
      _isLoadingContract = true;
      _loadContractAndSupervisor(studentId);
    }

    // Enquanto carrega, mostra indicador
    if (_isLoadingContract || _isLoadingSupervisor) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: LinearProgressIndicator(),
      );
    }

    // Se não encontrou contrato
    if (_cachedContract == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'Nenhum supervisor associado. A associação é feita ao criar um contrato.',
          style: TextStyle(color: Colors.orange[800]),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Se não encontrou supervisor
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        'Supervisor não encontrado. Verifique com o suporte.',
        style: TextStyle(color: Colors.red[800]),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Carrega contrato e supervisor de forma assíncrona mas controlada
  Future<void> _loadContractAndSupervisor(String studentId) async {
    try {
      // Carrega contrato
      final contract = await _getActiveContract(studentId);
      if (mounted) {
        setState(() {
          _cachedContract = contract;
          _isLoadingContract = false;
        });

        // Se tem contrato, carrega supervisor
        if (contract != null && (contract.supervisorId ?? '').isNotEmpty) {
          _isLoadingSupervisor = true;
          final supervisor = await _getSupervisorById(contract.supervisorId!);
          if (mounted) {
            setState(() {
              _cachedSupervisor = supervisor;
              _isLoadingSupervisor = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingContract = false;
          _isLoadingSupervisor = false;
        });
      }
    }
  }

  Future<ContractEntity?> _getActiveContract(String studentId) async {
    final usecase = Modular.get<GetActiveContractByStudentUsecase>();
    final result = await usecase(studentId);
    return result.fold((_) => null, (c) => c);
  }

  Future<SupervisorEntity?> _getSupervisorById(String supervisorId) async {
    final usecase = Modular.get<GetSupervisorByIdUsecase>();
    final result = await usecase(supervisorId);
    return result.fold((_) => null, (s) => s);
  }
}
