// lib/features/shared/widgets/enhanced_data_table.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Configuração de coluna para a tabela
class DataTableColumn {
  final String key;
  final String label;
  final bool sortable;
  final bool filterable;
  final double? width;
  final Widget Function(dynamic value, Map<String, dynamic> row)? customRenderer;
  final String Function(dynamic value)? valueFormatter;

  const DataTableColumn({
    required this.key,
    required this.label,
    this.sortable = true,
    this.filterable = true,
    this.width,
    this.customRenderer,
    this.valueFormatter,
  });
}

/// Configuração de ação em lote
class BatchAction {
  final String key;
  final String label;
  final IconData icon;
  final Color? color;
  final Future<void> Function(List<Map<String, dynamic>> selectedItems) onExecute;

  const BatchAction({
    required this.key,
    required this.label,
    required this.icon,
    required this.onExecute,
    this.color,
  });
}

/// Widget de tabela de dados aprimorada
class EnhancedDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<DataTableColumn> columns;
  final List<BatchAction> batchActions;
  final int itemsPerPage;
  final bool showSearch;
  final bool showPagination;
  final bool allowSelection;
  final bool allowMultiSelection;
  final String? emptyMessage;
  final Widget? emptyWidget;
  final Function(Map<String, dynamic>)? onRowTap;
  final Function(List<Map<String, dynamic>>)? onSelectionChanged;

  const EnhancedDataTable({
    super.key,
    required this.data,
    required this.columns,
    this.batchActions = const [],
    this.itemsPerPage = 10,
    this.showSearch = true,
    this.showPagination = true,
    this.allowSelection = false,
    this.allowMultiSelection = false,
    this.emptyMessage,
    this.emptyWidget,
    this.onRowTap,
    this.onSelectionChanged,
  });

  @override
  State<EnhancedDataTable> createState() => _EnhancedDataTableState();
}

class _EnhancedDataTableState extends State<EnhancedDataTable> {
  List<Map<String, dynamic>> _filteredData = [];
  List<Map<String, dynamic>> _selectedItems = [];
  String _searchQuery = '';
  String? _sortColumn;
  bool _sortAscending = true;
  int _currentPage = 0;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredData = List.from(widget.data);
    _applyFilters();
  }

  @override
  void didUpdateWidget(EnhancedDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _filteredData = List.from(widget.data);
      _selectedItems.clear();
      _currentPage = 0;
      _applyFilters();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredData = widget.data.where((item) {
        if (_searchQuery.isEmpty) return true;
        
        return widget.columns.any((column) {
          if (!column.filterable) return false;
          
          final value = item[column.key];
          if (value == null) return false;
          
          final searchText = value.toString().toLowerCase();
          return searchText.contains(_searchQuery.toLowerCase());
        });
      }).toList();

      // Aplicar ordenação
      if (_sortColumn != null) {
        _filteredData.sort((a, b) {
          final aValue = a[_sortColumn!];
          final bValue = b[_sortColumn!];
          
          if (aValue == null && bValue == null) return 0;
          if (aValue == null) return _sortAscending ? -1 : 1;
          if (bValue == null) return _sortAscending ? 1 : -1;
          
          int comparison;
          if (aValue is num && bValue is num) {
            comparison = aValue.compareTo(bValue);
          } else if (aValue is DateTime && bValue is DateTime) {
            comparison = aValue.compareTo(bValue);
          } else {
            comparison = aValue.toString().compareTo(bValue.toString());
          }
          
          return _sortAscending ? comparison : -comparison;
        });
      }

      // Resetar página se necessário
      final maxPage = (_filteredData.length / widget.itemsPerPage).ceil() - 1;
      if (_currentPage > maxPage && maxPage >= 0) {
        _currentPage = maxPage;
      }
    });
  }

  void _onSearch(String query) {
    _searchQuery = query;
    _currentPage = 0;
    _applyFilters();
  }

  void _onSort(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }
    });
    _applyFilters();
  }

  void _onSelectItem(Map<String, dynamic> item, bool selected) {
    setState(() {
      if (selected) {
        if (widget.allowMultiSelection) {
          _selectedItems.add(item);
        } else {
          _selectedItems = [item];
        }
      } else {
        _selectedItems.removeWhere((selectedItem) => 
            selectedItem.hashCode == item.hashCode);
      }
    });
    widget.onSelectionChanged?.call(_selectedItems);
  }

  void _onSelectAll(bool selected) {
    setState(() {
      if (selected) {
        _selectedItems = List.from(_getCurrentPageData());
      } else {
        _selectedItems.clear();
      }
    });
    widget.onSelectionChanged?.call(_selectedItems);
  }

  List<Map<String, dynamic>> _getCurrentPageData() {
    if (!widget.showPagination) return _filteredData;
    
    final startIndex = _currentPage * widget.itemsPerPage;
    final endIndex = (startIndex + widget.itemsPerPage).clamp(0, _filteredData.length);
    
    return _filteredData.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    final currentPageData = _getCurrentPageData();
    final totalPages = widget.showPagination 
        ? (_filteredData.length / widget.itemsPerPage).ceil()
        : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra de ferramentas
        _buildToolbar(),
        
        const SizedBox(height: 16),

        // Ações em lote
        if (_selectedItems.isNotEmpty && widget.batchActions.isNotEmpty)
          _buildBatchActions(),

        // Tabela
        Expanded(
          child: _filteredData.isEmpty 
              ? _buildEmptyState()
              : _buildDataTable(currentPageData),
        ),

        // Paginação
        if (widget.showPagination && totalPages > 1)
          _buildPagination(totalPages),
      ],
    );
  }

  Widget _buildToolbar() {
    return Row(
      children: [
        // Busca
        if (widget.showSearch)
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onChanged: _onSearch,
            ),
          ),

        const SizedBox(width: 16),

        // Informações
        Text(
          '${_filteredData.length} ${_filteredData.length == 1 ? 'item' : 'itens'}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),

        if (_selectedItems.isNotEmpty) ...[
          const SizedBox(width: 16),
          Text(
            '${_selectedItems.length} selecionado${_selectedItems.length == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBatchActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            '${_selectedItems.length} item${_selectedItems.length == 1 ? '' : 's'} selecionado${_selectedItems.length == 1 ? '' : 's'}',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          ...widget.batchActions.map((action) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ElevatedButton.icon(
              onPressed: () => action.onExecute(_selectedItems),
              icon: Icon(action.icon),
              label: Text(action.label),
              style: ElevatedButton.styleFrom(
                backgroundColor: action.color,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<Map<String, dynamic>> data) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 32,
        ),
        child: DataTable(
          showCheckboxColumn: widget.allowSelection,
          sortColumnIndex: _sortColumn != null 
              ? widget.columns.indexWhere((col) => col.key == _sortColumn)
              : null,
          sortAscending: _sortAscending,
          columns: [
            if (widget.allowSelection && widget.allowMultiSelection)
              DataColumn(
                label: Checkbox(
                  value: _selectedItems.length == data.length && data.isNotEmpty,
                  tristate: true,
                  onChanged: (value) => _onSelectAll(value ?? false),
                ),
              ),
            ...widget.columns.map((column) => DataColumn(
              label: Text(
                column.label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: column.sortable ? (_, __) => _onSort(column.key) : null,
            )),
          ],
          rows: data.map((item) {
            final isSelected = _selectedItems.any((selected) => 
                selected.hashCode == item.hashCode);

            return DataRow(
              selected: isSelected,
              onSelectChanged: widget.allowSelection 
                  ? (selected) => _onSelectItem(item, selected ?? false)
                  : null,
              cells: [
                ...widget.columns.map((column) {
                  final value = item[column.key];
                  
                  Widget cellContent;
                  if (column.customRenderer != null) {
                    cellContent = column.customRenderer!(value, item);
                  } else if (column.valueFormatter != null) {
                    cellContent = Text(column.valueFormatter!(value));
                  } else {
                    cellContent = Text(value?.toString() ?? '');
                  }

                  return DataCell(
                    cellContent,
                    onTap: widget.onRowTap != null 
                        ? () => widget.onRowTap!(item)
                        : null,
                  );
                }),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (widget.emptyWidget != null) {
      return Center(child: widget.emptyWidget!);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            widget.emptyMessage ?? 'Nenhum dado encontrado',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Tente ajustar os filtros de busca',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                _onSearch('');
              },
              icon: const Icon(Icons.clear),
              label: const Text('Limpar busca'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Informações da página
          Text(
            'Página ${_currentPage + 1} de $totalPages',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),

          // Controles de paginação
          Row(
            children: [
              IconButton(
                onPressed: _currentPage > 0 
                    ? () => setState(() => _currentPage = 0)
                    : null,
                icon: const Icon(Icons.first_page),
                tooltip: 'Primeira página',
              ),
              IconButton(
                onPressed: _currentPage > 0 
                    ? () => setState(() => _currentPage--)
                    : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Página anterior',
              ),
              
              // Seletor de página
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButton<int>(
                  value: _currentPage,
                  underline: const SizedBox(),
                  items: List.generate(totalPages, (index) => 
                    DropdownMenuItem(
                      value: index,
                      child: Text('${index + 1}'),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _currentPage = value);
                    }
                  },
                ),
              ),

              IconButton(
                onPressed: _currentPage < totalPages - 1 
                    ? () => setState(() => _currentPage++)
                    : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Próxima página',
              ),
              IconButton(
                onPressed: _currentPage < totalPages - 1 
                    ? () => setState(() => _currentPage = totalPages - 1)
                    : null,
                icon: const Icon(Icons.last_page),
                tooltip: 'Última página',
              ),
            ],
          ),

          // Itens por página
          Row(
            children: [
              const Text('Itens por página: '),
              DropdownButton<int>(
                value: widget.itemsPerPage,
                underline: const SizedBox(),
                items: [5, 10, 25, 50, 100].map((count) => 
                  DropdownMenuItem(
                    value: count,
                    child: Text('$count'),
                  ),
                ).toList(),
                onChanged: (value) {
                  // Esta funcionalidade seria implementada através de um callback
                  // para permitir que o widget pai atualize o itemsPerPage
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Extensões úteis para formatação de valores
extension DataTableFormatters on DataTableColumn {
  static String formatDate(dynamic value) {
    if (value == null) return '';
    if (value is DateTime) {
      return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
    }
    if (value is String) {
      try {
        final date = DateTime.parse(value);
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      } catch (e) {
        return value;
      }
    }
    return value.toString();
  }

  static String formatDateTime(dynamic value) {
    if (value == null) return '';
    if (value is DateTime) {
      return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    }
    if (value is String) {
      try {
        final date = DateTime.parse(value);
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        return value;
      }
    }
    return value.toString();
  }

  static String formatHours(dynamic value) {
    if (value == null) return '0h';
    if (value is num) {
      return '${value.toStringAsFixed(1)}h';
    }
    return value.toString();
  }

  static Widget statusBadge(dynamic value, Map<String, dynamic> row) {
    if (value == null) return const Text('');
    
    Color color;
    String text;
    
    switch (value.toString().toLowerCase()) {
      case 'approved':
        color = Colors.green;
        text = 'Aprovado';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Rejeitado';
        break;
      case 'pending':
        color = Colors.orange;
        text = 'Pendente';
        break;
      case 'in_review':
        color = Colors.blue;
        text = 'Em análise';
        break;
      default:
        color = Colors.grey;
        text = value.toString();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
