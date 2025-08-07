// lib/features/shared/widgets/export_options_widget.dart
import 'package:flutter/material.dart';
import 'dart:convert';

/// Configurações de exportação
class ExportConfig {
  final String format;
  final String fileName;
  final bool includeHeaders;
  final bool includeMetadata;
  final String dateFormat;
  final String encoding;
  final String delimiter;
  final List<String> selectedFields;
  final bool compressFile;
  final String compressionFormat;

  const ExportConfig({
    this.format = 'CSV',
    this.fileName = '',
    this.includeHeaders = true,
    this.includeMetadata = false,
    this.dateFormat = 'dd/MM/yyyy',
    this.encoding = 'UTF-8',
    this.delimiter = ',',
    this.selectedFields = const [],
    this.compressFile = false,
    this.compressionFormat = 'ZIP',
  });

  ExportConfig copyWith({
    String? format,
    String? fileName,
    bool? includeHeaders,
    bool? includeMetadata,
    String? dateFormat,
    String? encoding,
    String? delimiter,
    List<String>? selectedFields,
    bool? compressFile,
    String? compressionFormat,
  }) {
    return ExportConfig(
      format: format ?? this.format,
      fileName: fileName ?? this.fileName,
      includeHeaders: includeHeaders ?? this.includeHeaders,
      includeMetadata: includeMetadata ?? this.includeMetadata,
      dateFormat: dateFormat ?? this.dateFormat,
      encoding: encoding ?? this.encoding,
      delimiter: delimiter ?? this.delimiter,
      selectedFields: selectedFields ?? this.selectedFields,
      compressFile: compressFile ?? this.compressFile,
      compressionFormat: compressionFormat ?? this.compressionFormat,
    );
  }

  Map<String, dynamic> toJson() => {
    'format': format,
    'fileName': fileName,
    'includeHeaders': includeHeaders,
    'includeMetadata': includeMetadata,
    'dateFormat': dateFormat,
    'encoding': encoding,
    'delimiter': delimiter,
    'selectedFields': selectedFields,
    'compressFile': compressFile,
    'compressionFormat': compressionFormat,
  };
}

/// Widget de opções de exportação avançadas
class ExportOptionsWidget extends StatefulWidget {
  final ExportConfig initialConfig;
  final List<String> availableFields;
  final Map<String, dynamic>? previewData;
  final Function(ExportConfig) onConfigChanged;
  final Future<void> Function(ExportConfig) onExport;
  final VoidCallback? onCancel;

  const ExportOptionsWidget({
    super.key,
    required this.initialConfig,
    required this.availableFields,
    required this.onConfigChanged,
    required this.onExport,
    this.previewData,
    this.onCancel,
  });

  @override
  State<ExportOptionsWidget> createState() => _ExportOptionsWidgetState();
}

class _ExportOptionsWidgetState extends State<ExportOptionsWidget>
    with SingleTickerProviderStateMixin {
  late ExportConfig _config;
  late TabController _tabController;
  final _fileNameController = TextEditingController();
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig;
    _tabController = TabController(length: 3, vsync: this);
    _fileNameController.text = _config.fileName;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  void _updateConfig(ExportConfig newConfig) {
    setState(() {
      _config = newConfig;
    });
    widget.onConfigChanged(newConfig);
  }

  Future<void> _handleExport() async {
    if (_config.fileName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira um nome para o arquivo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      await widget.onExport(_config);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Arquivo exportado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              children: [
                const Icon(Icons.download, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Opções de Exportação',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onCancel ?? () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Abas
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.settings), text: 'Configurações'),
                Tab(icon: Icon(Icons.view_column), text: 'Campos'),
                Tab(icon: Icon(Icons.preview), text: 'Preview'),
              ],
            ),

            const SizedBox(height: 16),

            // Conteúdo das abas
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildConfigTab(),
                  _buildFieldsTab(),
                  _buildPreviewTab(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Botões de ação
            Row(
              children: [
                TextButton(
                  onPressed: widget.onCancel ?? () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isExporting ? null : _handleExport,
                  icon: _isExporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  label: Text(_isExporting ? 'Exportando...' : 'Exportar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Formato do arquivo
          Text(
            'Formato do Arquivo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFormatChip('CSV', Icons.table_chart),
              _buildFormatChip('JSON', Icons.code),
              _buildFormatChip('Excel', Icons.grid_on),
              _buildFormatChip('PDF', Icons.picture_as_pdf),
            ],
          ),

          const SizedBox(height: 24),

          // Nome do arquivo
          Text(
            'Nome do Arquivo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _fileNameController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'relatorio_${DateTime.now().millisecondsSinceEpoch}',
              suffixText: '.${_config.format.toLowerCase()}',
            ),
            onChanged: (value) {
              _updateConfig(_config.copyWith(fileName: value));
            },
          ),

          const SizedBox(height: 24),

          // Configurações específicas do formato
          if (_config.format == 'CSV') ..._buildCSVConfig(),
          if (_config.format == 'JSON') ..._buildJSONConfig(),
          if (_config.format == 'Excel') ..._buildExcelConfig(),
          if (_config.format == 'PDF') ..._buildPDFConfig(),

          const SizedBox(height: 24),

          // Opções gerais
          Text(
            'Opções Gerais',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          CheckboxListTile(
            title: const Text('Incluir cabeçalhos'),
            subtitle: const Text('Adicionar nomes das colunas na primeira linha'),
            value: _config.includeHeaders,
            onChanged: (value) {
              _updateConfig(_config.copyWith(includeHeaders: value ?? true));
            },
          ),

          CheckboxListTile(
            title: const Text('Incluir metadados'),
            subtitle: const Text('Adicionar informações sobre a geração do relatório'),
            value: _config.includeMetadata,
            onChanged: (value) {
              _updateConfig(_config.copyWith(includeMetadata: value ?? false));
            },
          ),

          CheckboxListTile(
            title: const Text('Comprimir arquivo'),
            subtitle: const Text('Criar arquivo compactado (ZIP)'),
            value: _config.compressFile,
            onChanged: (value) {
              _updateConfig(_config.copyWith(compressFile: value ?? false));
            },
          ),

          const SizedBox(height: 16),

          // Formato de data
          Text(
            'Formato de Data',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _config.dateFormat,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'dd/MM/yyyy', child: Text('DD/MM/AAAA')),
              DropdownMenuItem(value: 'MM/dd/yyyy', child: Text('MM/DD/AAAA')),
              DropdownMenuItem(value: 'yyyy-MM-dd', child: Text('AAAA-MM-DD')),
              DropdownMenuItem(value: 'dd-MM-yyyy HH:mm', child: Text('DD-MM-AAAA HH:MM')),
            ],
            onChanged: (value) {
              if (value != null) {
                _updateConfig(_config.copyWith(dateFormat: value));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFieldsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecionar Campos para Exportação',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Escolha quais campos deseja incluir no arquivo exportado',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                _updateConfig(_config.copyWith(selectedFields: widget.availableFields));
              },
              icon: const Icon(Icons.select_all),
              label: const Text('Selecionar Todos'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {
                _updateConfig(_config.copyWith(selectedFields: []));
              },
              icon: const Icon(Icons.deselect),
              label: const Text('Desmarcar Todos'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Expanded(
          child: ListView.builder(
            itemCount: widget.availableFields.length,
            itemBuilder: (context, index) {
              final field = widget.availableFields[index];
              final isSelected = _config.selectedFields.isEmpty || 
                                _config.selectedFields.contains(field);

              return CheckboxListTile(
                title: Text(_getFieldDisplayName(field)),
                subtitle: Text(_getFieldDescription(field)),
                value: isSelected,
                onChanged: (value) {
                  final newFields = List<String>.from(_config.selectedFields.isEmpty 
                      ? widget.availableFields 
                      : _config.selectedFields);
                  
                  if (value == true) {
                    if (!newFields.contains(field)) {
                      newFields.add(field);
                    }
                  } else {
                    newFields.remove(field);
                  }
                  
                  _updateConfig(_config.copyWith(selectedFields: newFields));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewTab() {
    if (widget.previewData == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.preview, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Preview não disponível'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview dos Dados',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Visualização de como os dados serão exportados',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),

        const SizedBox(height: 16),

        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: _buildPreviewContent(),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Este é apenas um preview. O arquivo final pode ter formatação diferente.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreviewContent() {
    switch (_config.format) {
      case 'CSV':
        return _buildCSVPreview();
      case 'JSON':
        return _buildJSONPreview();
      default:
        return Text(
          'Preview não disponível para o formato ${_config.format}',
          style: const TextStyle(fontStyle: FontStyle.italic),
        );
    }
  }

  Widget _buildCSVPreview() {
    final lines = <String>[];
    
    if (_config.includeHeaders) {
      final headers = _config.selectedFields.isEmpty 
          ? widget.availableFields 
          : _config.selectedFields;
      lines.add(headers.join(_config.delimiter));
    }
    
    // Adicionar algumas linhas de exemplo
    for (int i = 0; i < 3; i++) {
      final fields = _config.selectedFields.isEmpty 
          ? widget.availableFields 
          : _config.selectedFields;
      final values = fields.map((field) => 'Exemplo $field $i').toList();
      lines.add(values.join(_config.delimiter));
    }
    
    return SelectableText(
      lines.join('\n'),
      style: const TextStyle(fontFamily: 'monospace'),
    );
  }

  Widget _buildJSONPreview() {
    final preview = {
      if (_config.includeMetadata) ...{
        'metadata': {
          'generated_at': DateTime.now().toIso8601String(),
          'format': _config.format,
          'total_records': 'N',
        }
      },
      'data': [
        for (int i = 0; i < 2; i++)
          Map.fromEntries(
            (_config.selectedFields.isEmpty 
                ? widget.availableFields 
                : _config.selectedFields)
            .map((field) => MapEntry(field, 'Exemplo $field $i')),
          ),
      ],
    };
    
    return SelectableText(
      const JsonEncoder.withIndent('  ').convert(preview),
      style: const TextStyle(fontFamily: 'monospace'),
    );
  }

  Widget _buildFormatChip(String format, IconData icon) {
    final isSelected = _config.format == format;
    
    return FilterChip(
      avatar: Icon(icon, size: 18),
      label: Text(format),
      selected: isSelected,
      onSelected: (_) {
        _updateConfig(_config.copyWith(format: format));
      },
    );
  }

  List<Widget> _buildCSVConfig() {
    return [
      Text(
        'Configurações CSV',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      
      DropdownButtonFormField<String>(
        value: _config.delimiter,
        decoration: const InputDecoration(
          labelText: 'Separador',
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(value: ',', child: Text('Vírgula (,)')),
          DropdownMenuItem(value: ';', child: Text('Ponto e vírgula (;)')),
          DropdownMenuItem(value: '\t', child: Text('Tab')),
          DropdownMenuItem(value: '|', child: Text('Pipe (|)')),
        ],
        onChanged: (value) {
          if (value != null) {
            _updateConfig(_config.copyWith(delimiter: value));
          }
        },
      ),
      
      const SizedBox(height: 16),
      
      DropdownButtonFormField<String>(
        value: _config.encoding,
        decoration: const InputDecoration(
          labelText: 'Codificação',
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(value: 'UTF-8', child: Text('UTF-8')),
          DropdownMenuItem(value: 'ISO-8859-1', child: Text('ISO-8859-1')),
          DropdownMenuItem(value: 'Windows-1252', child: Text('Windows-1252')),
        ],
        onChanged: (value) {
          if (value != null) {
            _updateConfig(_config.copyWith(encoding: value));
          }
        },
      ),
    ];
  }

  List<Widget> _buildJSONConfig() {
    return [
      Text(
        'Configurações JSON',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      const Text('Arquivo JSON será formatado com indentação para melhor legibilidade.'),
    ];
  }

  List<Widget> _buildExcelConfig() {
    return [
      Text(
        'Configurações Excel',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      const Text('Arquivo Excel (.xlsx) com formatação automática de colunas.'),
    ];
  }

  List<Widget> _buildPDFConfig() {
    return [
      Text(
        'Configurações PDF',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      const Text('Documento PDF com layout otimizado para impressão.'),
    ];
  }

  String _getFieldDisplayName(String field) {
    final displayNames = {
      'id': 'ID',
      'student_id': 'ID do Estudante',
      'supervisor_id': 'ID do Supervisor',
      'created_at': 'Data de Criação',
      'updated_at': 'Data de Atualização',
      'clock_in_time': 'Horário de Entrada',
      'clock_out_time': 'Horário de Saída',
      'total_hours': 'Total de Horas',
      'description': 'Descrição',
      'status': 'Status',
      'student_name': 'Nome do Estudante',
      'supervisor_name': 'Nome do Supervisor',
    };
    
    return displayNames[field] ?? field.replaceAll('_', ' ').toUpperCase();
  }

  String _getFieldDescription(String field) {
    final descriptions = {
      'id': 'Identificador único do registro',
      'student_id': 'Identificador do estudante',
      'supervisor_id': 'Identificador do supervisor',
      'created_at': 'Data e hora de criação do registro',
      'updated_at': 'Data e hora da última atualização',
      'clock_in_time': 'Horário de entrada/check-in',
      'clock_out_time': 'Horário de saída/check-out',
      'total_hours': 'Total de horas trabalhadas',
      'description': 'Descrição das atividades realizadas',
      'status': 'Status atual do registro',
      'student_name': 'Nome completo do estudante',
      'supervisor_name': 'Nome completo do supervisor',
    };
    
    return descriptions[field] ?? 'Campo de dados';
  }
}
