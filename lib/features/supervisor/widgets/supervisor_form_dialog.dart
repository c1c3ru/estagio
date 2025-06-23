import 'package:flutter/material.dart';
import '../../../../domain/entities/supervisor_entity.dart';

class SupervisorFormDialog extends StatefulWidget {
  final SupervisorEntity? initialSupervisor;
  final void Function(
      SupervisorEntity supervisor, String email, String? password) onSubmit;
  final bool isEdit;

  const SupervisorFormDialog({
    super.key,
    this.initialSupervisor,
    required this.onSubmit,
    this.isEdit = false,
  });

  @override
  State<SupervisorFormDialog> createState() => _SupervisorFormDialogState();
}

class _SupervisorFormDialogState extends State<SupervisorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _departmentController;
  late TextEditingController _positionController;
  late TextEditingController _specializationController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    final s = widget.initialSupervisor;
    _departmentController = TextEditingController(text: s?.department ?? '');
    _positionController = TextEditingController(text: s?.position ?? '');
    _specializationController =
        TextEditingController(text: s?.specialization ?? '');
    _phoneController = TextEditingController(text: s?.phone ?? '');
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _departmentController.dispose();
    _positionController.dispose();
    _specializationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEdit ? 'Editar Supervisor' : 'Novo Supervisor'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(labelText: 'Departamento'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o departamento' : null,
              ),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(labelText: 'Cargo'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o cargo' : null,
              ),
              TextFormField(
                controller: _specializationController,
                decoration: const InputDecoration(labelText: 'Especialização'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe a especialização' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
              ),
              if (!widget.isEdit)
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
              final supervisor = (widget.initialSupervisor ??
                      SupervisorEntity(
                        id: '',
                        userId: '',
                        department: _departmentController.text.trim(),
                        position: _positionController.text.trim(),
                        specialization: _specializationController.text.trim(),
                        phone: _phoneController.text.trim(),
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ))
                  .copyWith(
                department: _departmentController.text.trim(),
                position: _positionController.text.trim(),
                specialization: _specializationController.text.trim(),
                phone: _phoneController.text.trim(),
              );
              widget.onSubmit(
                supervisor,
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
