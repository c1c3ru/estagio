import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../core/constants/app_colors.dart';
import '../bloc/supervisor_bloc.dart';
import '../bloc/supervisor_event.dart';
import '../bloc/supervisor_state.dart';
import '../widgets/supervisor_form_dialog.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';

class SupervisorListPage extends StatefulWidget {
  const SupervisorListPage({super.key});

  @override
  State<SupervisorListPage> createState() => _SupervisorListPageState();
}

class _SupervisorListPageState extends State<SupervisorListPage> {
  @override
  void initState() {
    super.initState();
    // Carregar lista de supervisores
    Modular.get<SupervisorBloc>().add(LoadAllSupervisorsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SupervisorBloc, SupervisorState>(
      listener: (context, state) {
        if (state is SupervisorOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is SupervisorOperationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gerenciar Supervisores'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Modular.get<AuthBloc>().add(LogoutRequested());
              },
            ),
          ],
        ),
        body: BlocBuilder<SupervisorBloc, SupervisorState>(
          builder: (context, state) {
            if (state is SupervisorLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SupervisorListLoadSuccess) {
              final supervisors = state.supervisors;
              if (supervisors.isEmpty) {
                return const Center(
                    child: Text('Nenhum supervisor cadastrado.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: supervisors.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final supervisor = supervisors[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                          '${supervisor.position} - ${supervisor.department}'),
                      subtitle: Text(
                          'Departamento: ${supervisor.department ?? ''}\nID: ${supervisor.id}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon:
                                const Icon(Icons.edit, color: Colors.blueGrey),
                            tooltip: 'Editar',
                            onPressed: () async {
                              if (!mounted) return;
                              await showDialog(
                                context: context,
                                builder: (context) => SupervisorFormDialog(
                                  isEdit: true,
                                  initialSupervisor: supervisor,
                                  onSubmit: (editedSupervisor, _, __) {
                                    BlocProvider.of<SupervisorBloc>(context)
                                        .add(UpdateSupervisorEvent(
                                            supervisor: editedSupervisor));
                                  },
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            tooltip: 'Remover',
                            onPressed: () async {
                              final bloc =
                                  BlocProvider.of<SupervisorBloc>(context);
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Remover supervisor'),
                                  content: const Text(
                                      'Tem certeza que deseja remover o supervisor?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Remover',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (!mounted) return;
                              if (confirm == true) {
                                bloc.add(DeleteSupervisorEvent(supervisor.id));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            if (state is SupervisorOperationFailure) {
              return Center(child: Text('Erro: ${state.message}'));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (!mounted) return;
            await showDialog(
              context: context,
              builder: (context) => SupervisorFormDialog(
                isEdit: false,
                onSubmit: (supervisor, email, password) {
                  BlocProvider.of<SupervisorBloc>(context).add(
                    CreateSupervisorEvent(
                      supervisor: supervisor,
                      initialEmail: email,
                      initialPassword: password ?? '',
                    ),
                  );
                },
              ),
            );
          },
          backgroundColor: AppColors.primary,
          tooltip: 'Adicionar Supervisor',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
