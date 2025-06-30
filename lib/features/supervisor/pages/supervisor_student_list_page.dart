import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestao_de_estagio/core/widgets/empty_data_widget.dart';
import '../bloc/supervisor_bloc.dart';
import '../bloc/supervisor_event.dart';
import '../bloc/supervisor_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SupervisorStudentListPage extends StatefulWidget {
  const SupervisorStudentListPage({super.key});

  @override
  State<SupervisorStudentListPage> createState() =>
      _SupervisorStudentListPageState();
}

class _SupervisorStudentListPageState extends State<SupervisorStudentListPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<SupervisorBloc>(context, listen: false)
        .add(LoadSupervisorDashboardDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Estudantes'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: BlocBuilder<SupervisorBloc, SupervisorState>(
        builder: (context, state) {
          if (state is SupervisorLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SupervisorDashboardLoadSuccess) {
            final students = state.students;
            if (students.isEmpty) {
              return const EmptyDataWidget(
                message: 'Nenhum estudante está atualmente sob sua supervisão.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: students.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  child: ListTile(
                    title:
                        Text(student.fullName, style: AppTextStyles.bodyLarge),
                    subtitle: Text(
                        'Matrícula: ${student.registrationNumber}\nCurso: ${student.course}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueGrey),
                          tooltip: 'Editar',
                          onPressed: () async {
                            // Pode abrir um dialog ou navegar para edição
                            Navigator.of(context).pushNamed(
                                '/supervisor/student-edit/${student.id}');
                          },
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.redAccent),
                          tooltip: 'Remover',
                          onPressed: () async {
                            final bloc = BlocProvider.of<SupervisorBloc>(
                                context,
                                listen: false);
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Remover estudante'),
                                content: Text(
                                    'Tem certeza que deseja remover o estudante "${student.fullName}"?'),
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
                            if (confirm == true) {
                              bloc.add(DeleteStudentBySupervisorEvent(
                                  studentId: student.id));
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                          '/supervisor/student-details/${student.id}');
                    },
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
          Navigator.of(context).pushNamed('/supervisor/student-create');
        },
        backgroundColor: AppColors.primary,
        tooltip: 'Adicionar Estudante',
        child: const Icon(Icons.add),
      ),
    );
  }
}
