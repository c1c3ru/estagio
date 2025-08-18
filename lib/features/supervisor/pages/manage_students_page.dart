import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../domain/entities/student_entity.dart';
import '../bloc/supervisor_bloc.dart';
import '../bloc/supervisor_event.dart';
import '../bloc/supervisor_state.dart';
import '../widgets/supervisor_app_drawer.dart';

class ManageStudentsPage extends StatefulWidget {
  const ManageStudentsPage({super.key});

  @override
  State<ManageStudentsPage> createState() => _ManageStudentsPageState();
}

class _ManageStudentsPageState extends State<ManageStudentsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<StudentEntity> _filteredStudents = [];
  List<StudentEntity> _allStudents = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadStudents() {
    BlocProvider.of<SupervisorBloc>(context).add(LoadAllStudentsEvent());
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _allStudents.where((student) {
        return student.fullName.toLowerCase().contains(query) ||
            student.course.toLowerCase().contains(query) ||
            student.registrationNumber.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Estudantes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudents,
          ),
        ],
      ),
      drawer: const SupervisorAppDrawer(currentIndex: 1),
      body: Column(
        children: [
          // Barra de pesquisa
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome, curso ou matrícula...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          // Lista de estudantes
          Expanded(
            child: BlocConsumer<SupervisorBloc, SupervisorState>(
              listener: (context, state) {
                if (state is SupervisorOperationFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is SupervisorLoading) {
                  return const LoadingIndicator();
                }

                if (state is SupervisorStudentsLoadSuccess) {
                  _allStudents = state.students;
                  if (_filteredStudents.isEmpty &&
                      _searchController.text.isEmpty) {
                    _filteredStudents = state.students;
                  }

                  if (_filteredStudents.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Nenhum estudante encontrado'
                                : 'Nenhum resultado para "${_searchController.text}"',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadStudents(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = _filteredStudents[index];
                        return _buildStudentCard(context, student);
                      },
                    ),
                  );
                }

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text('Erro ao carregar estudantes'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStudents,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, StudentEntity student) {
    final theme = Theme.of(context);
    final nameParts = student.fullName.split(' ');
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'
        : student.fullName.substring(0, 2);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navegar para detalhes do estudante
          Modular.to.pushNamed('/supervisor/student-details/${student.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    radius: 24,
                    child: Text(
                      initials.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          student.course,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(student.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(student.status),
                      style: TextStyle(
                        color: _getStatusColor(student.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                        Icons.badge, 'Matrícula', student.registrationNumber),
                    _buildInfoRow(
                        Icons.person, 'Orientador', student.advisorName),
                    _buildInfoRow(Icons.schedule, 'Turno',
                        _getShiftText(student.classShift)),
                    _buildInfoRow(Icons.hourglass_empty, 'Horas Completadas',
                        '${student.totalHoursCompleted.toStringAsFixed(0)}/${student.totalHoursRequired.toStringAsFixed(0)}h'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Contrato: ${DateFormat('dd/MM/yyyy').format(student.contractStartDate)} - ${DateFormat('dd/MM/yyyy').format(student.contractEndDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.hintColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'inactive':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return 'Ativo';
      case 'inactive':
        return 'Inativo';
      case 'pending':
        return 'Pendente';
      default:
        return 'N/A';
    }
  }

  String _getShiftText(String shift) {
    switch (shift.toLowerCase()) {
      case 'morning':
        return 'Manhã';
      case 'afternoon':
        return 'Tarde';
      case 'evening':
        return 'Noite';
      case 'full_time':
        return 'Integral';
      case 'ead':
        return 'EAD';
      default:
        return shift;
    }
  }
}
