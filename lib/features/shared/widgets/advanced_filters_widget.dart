// lib/features/shared/widgets/advanced_filters_widget.dart
import 'package:flutter/material.dart';

/// Modelo para configuração de filtros avançados
class AdvancedFilters {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? studentId;
  final String? supervisorId;
  final List<String> statuses;
  final double? minHours;
  final double? maxHours;
  final String sortBy;
  final bool sortAscending;
  final String groupBy;

  const AdvancedFilters({
    this.startDate,
    this.endDate,
    this.studentId,
    this.supervisorId,
    this.statuses = const [],
    this.minHours,
    this.maxHours,
    this.sortBy = 'date',
    this.sortAscending = false,
    this.groupBy = 'none',
  });

  AdvancedFilters copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? studentId,
    String? supervisorId,
    List<String>? statuses,
    double? minHours,
    double? maxHours,
    String? sortBy,
    bool? sortAscending,
    String? groupBy,
  }) {
    return AdvancedFilters(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      studentId: studentId ?? this.studentId,
      supervisorId: supervisorId ?? this.supervisorId,
      statuses: statuses ?? this.statuses,
      minHours: minHours ?? this.minHours,
      maxHours: maxHours ?? this.maxHours,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      groupBy: groupBy ?? this.groupBy,
    );
  }

  Map<String, dynamic> toJson() => {
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'studentId': studentId,
    'supervisorId': supervisorId,
    'statuses': statuses,
    'minHours': minHours,
    'maxHours': maxHours,
    'sortBy': sortBy,
    'sortAscending': sortAscending,
    'groupBy': groupBy,
  };
}

/// Widget de filtros avançados para relatórios
class AdvancedFiltersWidget extends StatefulWidget {
  final AdvancedFilters initialFilters;
  final List<Map<String, dynamic>> students;
  final List<Map<String, dynamic>> supervisors;
  final bool showStudentFilter;
  final bool showSupervisorFilter;
  final bool showStatusFilter;
  final bool showHoursFilter;
  final Function(AdvancedFilters) onFiltersChanged;
  final VoidCallback? onReset;

  const AdvancedFiltersWidget({
    super.key,
    required this.initialFilters,
    required this.onFiltersChanged,
    this.students = const [],
    this.supervisors = const [],
    this.showStudentFilter = true,
    this.showSupervisorFilter = false,
    this.showStatusFilter = true,
    this.showHoursFilter = true,
    this.onReset,
  });

  @override
  State<AdvancedFiltersWidget> createState() => _AdvancedFiltersWidgetState();
}

class _AdvancedFiltersWidgetState extends State<AdvancedFiltersWidget> {
  late AdvancedFilters _filters;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  void _updateFilters(AdvancedFilters newFilters) {
    setState(() {
      _filters = newFilters;
    });
    widget.onFiltersChanged(newFilters);
  }

  void _resetFilters() {
    final resetFilters = AdvancedFilters();
    _updateFilters(resetFilters);
    widget.onReset?.call();
  }

  void _applyPreset(String preset) {
    final now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate = now;

    switch (preset) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case 'quarter':
        startDate = now.subtract(const Duration(days: 90));
        break;
      case 'year':
        startDate = now.subtract(const Duration(days: 365));
        break;
      case 'current_month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'last_month':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        startDate = lastMonth;
        endDate = DateTime(now.year, now.month, 0);
        break;
    }

    if (startDate != null) {
      _updateFilters(_filters.copyWith(
        startDate: startDate,
        endDate: endDate,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = _filters.startDate != null ||
        _filters.endDate != null ||
        _filters.studentId != null ||
        _filters.supervisorId != null ||
        _filters.statuses.isNotEmpty ||
        _filters.minHours != null ||
        _filters.maxHours != null ||
        _filters.sortBy != 'date' ||
        _filters.groupBy != 'none';

    return Card(
      elevation: 2,
      child: Column(
        children: [
          // Cabeçalho do filtro
          ListTile(
            leading: Icon(
              Icons.filter_list,
              color: hasActiveFilters ? Theme.of(context).primaryColor : null,
            ),
            title: Text(
              'Filtros Avançados',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: hasActiveFilters ? Theme.of(context).primaryColor : null,
              ),
            ),
            subtitle: hasActiveFilters
                ? Text(
                    _getActiveFiltersDescription(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasActiveFilters)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _resetFilters,
                    tooltip: 'Limpar filtros',
                  ),
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  tooltip: _isExpanded ? 'Recolher' : 'Expandir',
                ),
              ],
            ),
          ),

          // Conteúdo expandido
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Presets de período
                  Text(
                    'Períodos Predefinidos',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildPresetChip('Hoje', 'today'),
                      _buildPresetChip('7 dias', 'week'),
                      _buildPresetChip('30 dias', 'month'),
                      _buildPresetChip('3 meses', 'quarter'),
                      _buildPresetChip('1 ano', 'year'),
                      _buildPresetChip('Mês atual', 'current_month'),
                      _buildPresetChip('Mês passado', 'last_month'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Período customizado
                  Text(
                    'Período Personalizado',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          label: 'Data inicial',
                          date: _filters.startDate,
                          onChanged: (date) {
                            _updateFilters(_filters.copyWith(startDate: date));
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateField(
                          label: 'Data final',
                          date: _filters.endDate,
                          onChanged: (date) {
                            _updateFilters(_filters.copyWith(endDate: date));
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Filtros por pessoa
                  if (widget.showStudentFilter && widget.students.isNotEmpty) ...[
                    Text(
                      'Estudante',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _filters.studentId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      hint: const Text('Todos os estudantes'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Todos os estudantes'),
                        ),
                        ...widget.students.map((student) => DropdownMenuItem<String>(
                          value: student['id'],
                          child: Text(student['name'] ?? 'Sem nome'),
                        )),
                      ],
                      onChanged: (value) {
                        _updateFilters(_filters.copyWith(studentId: value));
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (widget.showSupervisorFilter && widget.supervisors.isNotEmpty) ...[
                    Text(
                      'Supervisor',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _filters.supervisorId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      hint: const Text('Todos os supervisores'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Todos os supervisores'),
                        ),
                        ...widget.supervisors.map((supervisor) => DropdownMenuItem<String>(
                          value: supervisor['id'],
                          child: Text(supervisor['name'] ?? 'Sem nome'),
                        )),
                      ],
                      onChanged: (value) {
                        _updateFilters(_filters.copyWith(supervisorId: value));
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Filtro por status
                  if (widget.showStatusFilter) ...[
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildStatusChip('Pendente', 'pending'),
                        _buildStatusChip('Aprovado', 'approved'),
                        _buildStatusChip('Rejeitado', 'rejected'),
                        _buildStatusChip('Em análise', 'in_review'),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Filtro por horas
                  if (widget.showHoursFilter) ...[
                    Text(
                      'Filtro por Horas',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Horas mínimas',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: _filters.minHours?.toString(),
                            onChanged: (value) {
                              final hours = double.tryParse(value);
                              _updateFilters(_filters.copyWith(minHours: hours));
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Horas máximas',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: _filters.maxHours?.toString(),
                            onChanged: (value) {
                              final hours = double.tryParse(value);
                              _updateFilters(_filters.copyWith(maxHours: hours));
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Ordenação e agrupamento
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ordenar por',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _filters.sortBy,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'date', child: Text('Data')),
                                DropdownMenuItem(value: 'hours', child: Text('Horas')),
                                DropdownMenuItem(value: 'student', child: Text('Estudante')),
                                DropdownMenuItem(value: 'status', child: Text('Status')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  _updateFilters(_filters.copyWith(sortBy: value));
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Agrupar por',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _filters.groupBy,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'none', child: Text('Nenhum')),
                                DropdownMenuItem(value: 'day', child: Text('Dia')),
                                DropdownMenuItem(value: 'week', child: Text('Semana')),
                                DropdownMenuItem(value: 'month', child: Text('Mês')),
                                DropdownMenuItem(value: 'student', child: Text('Estudante')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  _updateFilters(_filters.copyWith(groupBy: value));
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Ordem crescente/decrescente
                  CheckboxListTile(
                    title: const Text('Ordem crescente'),
                    subtitle: Text(
                      _filters.sortAscending ? 'Menor para maior' : 'Maior para menor',
                    ),
                    value: _filters.sortAscending,
                    onChanged: (value) {
                      _updateFilters(_filters.copyWith(sortAscending: value ?? false));
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, String preset) {
    return FilterChip(
      label: Text(label),
      onSelected: (_) => _applyPreset(preset),
      selected: false,
    );
  }

  Widget _buildStatusChip(String label, String status) {
    final isSelected = _filters.statuses.contains(status);
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        final newStatuses = List<String>.from(_filters.statuses);
        if (selected) {
          newStatuses.add(status);
        } else {
          newStatuses.remove(status);
        }
        _updateFilters(_filters.copyWith(statuses: newStatuses));
      },
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required Function(DateTime?) onChanged,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: date != null
            ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
            : '',
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
    );
  }

  String _getActiveFiltersDescription() {
    final descriptions = <String>[];
    
    if (_filters.startDate != null || _filters.endDate != null) {
      descriptions.add('Período personalizado');
    }
    
    if (_filters.studentId != null) {
      descriptions.add('Estudante específico');
    }
    
    if (_filters.supervisorId != null) {
      descriptions.add('Supervisor específico');
    }
    
    if (_filters.statuses.isNotEmpty) {
      descriptions.add('${_filters.statuses.length} status');
    }
    
    if (_filters.minHours != null || _filters.maxHours != null) {
      descriptions.add('Filtro de horas');
    }
    
    if (_filters.sortBy != 'date') {
      descriptions.add('Ordenação: ${_filters.sortBy}');
    }
    
    if (_filters.groupBy != 'none') {
      descriptions.add('Agrupamento: ${_filters.groupBy}');
    }
    
    return descriptions.join(' • ');
  }
}
