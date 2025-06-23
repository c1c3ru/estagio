import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/student_entity.dart';
import '../../../../core/enums/class_shift.dart';
import '../../../../core/enums/internship_shift.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/enums/student_status.dart';

class StudentFormDialog extends StatefulWidget {
  final StudentEntity? initialStudent;
  final void Function(StudentEntity student, String email, String? password)
      onSubmit;
  final bool isEdit;

  const StudentFormDialog({
    super.key,
    this.initialStudent,
    required this.onSubmit,
    this.isEdit = false,
  });

  @override
  State<StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<StudentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _registrationController;
  late TextEditingController _courseController;
  late TextEditingController _advisorController;
  late TextEditingController _phoneController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _totalHoursController;
  late TextEditingController _weeklyHoursController;
  late TextEditingController _passwordController;
  bool _isMandatoryInternship = false;
  ClassShift _classShift = ClassShift.morning;
  InternshipShift _internshipShift = InternshipShift.morning;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    final s = widget.initialStudent;
    _nameController = TextEditingController(text: s?.fullName ?? '');
    _emailController = TextEditingController(text: s?.email ?? '');
    _registrationController =
        TextEditingController(text: s?.registrationNumber ?? '');
    _courseController = TextEditingController(text: s?.course ?? '');
    _advisorController = TextEditingController(text: s?.advisorName ?? '');
    _phoneController = TextEditingController(text: s?.phoneNumber ?? '');
    _startDate = s?.contractStartDate;
    _endDate = s?.contractEndDate;
    _startDateController = TextEditingController(
        text: s?.contractStartDate != null
            ? DateFormat('dd/MM/yyyy').format(s!.contractStartDate)
            : '');
    _endDateController = TextEditingController(
        text: s?.contractEndDate != null
            ? DateFormat('dd/MM/yyyy').format(s!.contractEndDate)
            : '');
    _totalHoursController =
        TextEditingController(text: s?.totalHoursRequired.toString() ?? '');
    _weeklyHoursController =
        TextEditingController(text: s?.weeklyHoursTarget.toString() ?? '');
    _isMandatoryInternship = s?.isMandatoryInternship ?? false;
    _classShift = s?.classShift ?? ClassShift.morning;
    _internshipShift = s?.internshipShift ?? InternshipShift.morning;
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _registrationController.dispose();
    _courseController.dispose();
    _advisorController.dispose();
    _phoneController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _totalHoursController.dispose();
    _weeklyHoursController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context,
      TextEditingController controller,
      DateTime? initialDate,
      Function(DateTime) onSelected) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(picked);
      onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEdit ? 'Editar Estudante' : 'Novo Estudante'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome completo'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o e-mail' : null,
              ),
              if (!widget.isEdit)
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Senha inicial'),
                  obscureText: true,
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
              TextFormField(
                controller: _registrationController,
                decoration: const InputDecoration(labelText: 'Matrícula'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe a matrícula' : null,
              ),
              TextFormField(
                controller: _courseController,
                decoration: const InputDecoration(labelText: 'Curso'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o curso' : null,
              ),
              TextFormField(
                controller: _advisorController,
                decoration: const InputDecoration(labelText: 'Orientador'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startDateController,
                      decoration: const InputDecoration(
                          labelText: 'Início do contrato'),
                      readOnly: true,
                      onTap: () => _selectDate(context, _startDateController,
                          _startDate, (d) => setState(() => _startDate = d)),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Informe a data' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _endDateController,
                      decoration:
                          const InputDecoration(labelText: 'Fim do contrato'),
                      readOnly: true,
                      onTap: () => _selectDate(context, _endDateController,
                          _endDate, (d) => setState(() => _endDate = d)),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Informe a data' : null,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _totalHoursController,
                      decoration: const InputDecoration(
                          labelText: 'Carga horária total'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty
                          ? 'Informe a carga horária'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _weeklyHoursController,
                      decoration:
                          const InputDecoration(labelText: 'Horas semanais'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty
                          ? 'Informe as horas semanais'
                          : null,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<ClassShift>(
                      value: _classShift,
                      decoration:
                          const InputDecoration(labelText: 'Turno da turma'),
                      items: ClassShift.values
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.displayName),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _classShift = v!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<InternshipShift>(
                      value: _internshipShift,
                      decoration:
                          const InputDecoration(labelText: 'Turno do estágio'),
                      items: InternshipShift.values
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.displayName),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _internshipShift = v!),
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                value: _isMandatoryInternship,
                onChanged: (v) => setState(() => _isMandatoryInternship = v),
                title: const Text('Estágio obrigatório'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final student = (widget.initialStudent ??
                      StudentEntity(
                        id: '',
                        email: _emailController.text.trim(),
                        fullName: _nameController.text.trim(),
                        phoneNumber: _phoneController.text.trim(),
                        profilePictureUrl: null,
                        role: UserRole.student,
                        isActive: true,
                        createdAt: DateTime.now(),
                        updatedAt: null,
                        userId: '',
                        birthDate: null,
                        course: _courseController.text.trim(),
                        advisorName: _advisorController.text.trim(),
                        registrationNumber: _registrationController.text.trim(),
                        isMandatoryInternship: _isMandatoryInternship,
                        classShift: _classShift,
                        internshipShift: _internshipShift,
                        supervisorId: null,
                        totalHoursCompleted: 0.0,
                        totalHoursRequired:
                            double.tryParse(_totalHoursController.text) ?? 0.0,
                        weeklyHoursTarget:
                            double.tryParse(_weeklyHoursController.text) ?? 0.0,
                        contractStartDate: _startDate!,
                        contractEndDate: _endDate!,
                        isOnTrack: true,
                        status: StudentStatus.pending,
                      ))
                  .copyWith(
                fullName: _nameController.text.trim(),
                email: _emailController.text.trim(),
                registrationNumber: _registrationController.text.trim(),
                course: _courseController.text.trim(),
                advisorName: _advisorController.text.trim(),
                phoneNumber: _phoneController.text.trim(),
                contractStartDate: _startDate!,
                contractEndDate: _endDate!,
                totalHoursRequired:
                    double.tryParse(_totalHoursController.text) ?? 0.0,
                weeklyHoursTarget:
                    double.tryParse(_weeklyHoursController.text) ?? 0.0,
                isMandatoryInternship: _isMandatoryInternship,
                classShift: _classShift,
                internshipShift: _internshipShift,
              );
              widget.onSubmit(
                student,
                _emailController.text.trim(),
                widget.isEdit ? null : _passwordController.text.trim(),
              );
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.isEdit ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }
}
