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
      if (_isEditMode && _currentStudent != null) {
        _populateFields(_currentStudent!);
      }
    });
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_currentStudent != null && _currentUserId != null) {
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
            profilePictureUrl: _profilePictureUrlController.text.trim().isEmpty
                ? null
                : _profilePictureUrlController.text.trim(),
            birthDate: _selectedBirthDate,
            classShift: _selectedClassShift,
            internshipShift: _selectedInternshipShift,
            isMandatoryInternship: _selectedIsMandatoryInternship,
          ),
        ));
      }

      setState(() {
        _isEditMode = false;
      });
    }
  }

  void _cancelEdit() {
    if (_currentStudent != null) {
      _populateFields(_currentStudent!);
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar dados',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Tentar Novamente',
                      onPressed: () {
                        if (_currentUserId != null) {
                          _studentBloc.add(
                              student_event.LoadStudentDashboardDataEvent(
                                  userId: _currentUserId!));
                        }
                      },
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
            return const Center(child: Text('Nenhum estudante encontrado'));
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
                      text: 'Editar Perfil',
                      onPressed: _toggleEditMode,
                      icon: Icons.edit,
                    ),
                  ],
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

        // Supervisor do contrato ativo
        FutureBuilder<ContractEntity?>(
          future: _getActiveContract(student.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: LinearProgressIndicator(),
              );
            }
            final contract = snapshot.data;
            if (contract == null || (contract.supervisorId ?? '').isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Nenhum supervisor associado. A associação é feita ao criar um contrato. Caso não tenha contrato ativo, crie um novo contrato para associar um supervisor.',
                  style: TextStyle(color: Colors.orange[800]),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return FutureBuilder<SupervisorEntity?>(
              future: _getSupervisorById(contract.supervisorId ?? ''),
              builder: (context, supSnapshot) {
                if (supSnapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: LinearProgressIndicator(),
                  );
                }
                if (!supSnapshot.hasData || supSnapshot.data == null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Supervisor não encontrado. Verifique com o suporte.',
                      style: TextStyle(color: Colors.red[800]),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                final supervisor = supSnapshot.data!;
                return _buildReadOnlyInfo(
                  context,
                  'Supervisor do Contrato Ativo',
                  '${supervisor.position} - ${supervisor.department}',
                  icon: Icons.verified_user_outlined,
                );
              },
            );
          },
        ),

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
          validator: (value) =>
              Validators.required(value, fieldName: 'Nº de Matrícula'),
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
        AppTextField(
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
              child: Text(shift.name),
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
        _buildSectionTitle('Informações do Estágio'),
        const SizedBox(height: 16),
        DropdownButtonFormField<InternshipShift>(
          value: _selectedInternshipShift,
          onChanged: _isEditMode
              ? (newValue) {
                  setState(() {
                    _selectedInternshipShift = newValue;
                  });
                }
              : null,
          items: InternshipShift.values
              .map((shift) => DropdownMenuItem(
                    value: shift,
                    child: Text(shift.name),
                  ))
              .toList(),
          decoration: const InputDecoration(
            labelText: 'Turno do Estágio',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyInfo(BuildContext context, String label, String value,
      {IconData? icon}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 10.0), // Aumentado o padding vertical
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: 22,
                color: theme.colorScheme.primary), // Ícone um pouco maior
            const SizedBox(width: 16), // Espaçamento aumentado
          ] else ...[
            const SizedBox(width: 38),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                      fontSize: 12), // Fonte menor para o label
                ),
                const SizedBox(height: 3), // Espaçamento ajustado
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 15), // Fonte um pouco menor para o valor
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
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
