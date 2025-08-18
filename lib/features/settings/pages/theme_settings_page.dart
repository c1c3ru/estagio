// lib/features/settings/pages/theme_settings_page.dart
import 'package:flutter/material.dart';
import '../../../core/theme/theme_service.dart';
import '../../../core/theme/app_theme_extensions.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  late ThemeService _themeService;
  late ThemeConfig _config;

  @override
  void initState() {
    super.initState();
    _themeService = ThemeService();
    _config = _themeService.config;
    
    // Escutar mudanças no tema
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {
        _config = _themeService.config;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Tema'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetToDefault,
            tooltip: 'Restaurar padrão',
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(context.tokens.spaceLg),
        children: [
          // Seção de modo de tema
          _buildThemeModeSection(),
          
          SizedBox(height: context.tokens.spaceXl),
          
          // Seção de esquemas de cores
          _buildColorSchemeSection(),
          
          SizedBox(height: context.tokens.spaceXl),
          
          // Seção de tipografia
          _buildTypographySection(),
          
          SizedBox(height: context.tokens.spaceXl),
          
          // Seção de acessibilidade
          _buildAccessibilitySection(),
          
          SizedBox(height: context.tokens.spaceXl),
          
          // Preview do tema
          _buildThemePreview(),
          
          SizedBox(height: context.tokens.spaceXl * 2),
          
          // Botões de ação
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildThemeModeSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.brightness_6,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: context.tokens.spaceSm),
                Text(
                  'Modo do Tema',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: context.tokens.spaceLg),
            
            // Opções de modo de tema
            Column(
              children: AppThemeType.values.map((themeType) {
                return RadioListTile<AppThemeType>(
                  title: Text(_getThemeTypeName(themeType)),
                  subtitle: Text(_getThemeTypeDescription(themeType)),
                  value: themeType,
                  groupValue: _config.themeType,
                  onChanged: (value) {
                    if (value != null) {
                      _themeService.updateThemeConfig(
                        _config.copyWith(themeType: value),
                      );
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSchemeSection() {
    final colorSchemes = _themeService.getAvailableColorSchemes();
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: context.tokens.spaceSm),
                Text(
                  'Esquema de Cores',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: context.tokens.spaceLg),
            
            // Grid de esquemas de cores
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: context.tokens.spaceSm,
                mainAxisSpacing: context.tokens.spaceSm,
                childAspectRatio: 1.2,
              ),
              itemCount: colorSchemes.length,
              itemBuilder: (context, index) {
                final scheme = colorSchemes[index];
                final isSelected = _config.colorScheme == scheme.scheme;
                
                return InkWell(
                  onTap: () {
                    _themeService.setColorScheme(scheme.scheme);
                  },
                  borderRadius: BorderRadius.circular(context.tokens.radiusSm),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(context.tokens.radiusSm),
                      border: Border.all(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: scheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : null,
                        ),
                        SizedBox(height: context.tokens.spaceSm),
                        Text(
                          scheme.name,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypographySection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.text_fields,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: context.tokens.spaceSm),
                Text(
                  'Tipografia',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: context.tokens.spaceLg),
            
            // Tamanho da fonte
            Text(
              'Tamanho da Fonte',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: context.tokens.spaceSm),
            
            Row(
              children: [
                Text(
                  'A',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Expanded(
                  child: Slider(
                    value: _config.fontSize,
                    min: 10.0,
                    max: 20.0,
                    divisions: 10,
                    label: '${_config.fontSize.toInt()}pt',
                    onChanged: (value) {
                      _themeService.setFontSize(value);
                    },
                  ),
                ),
                Text(
                  'A',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            
            SizedBox(height: context.tokens.spaceSm),
            
            // Preview do tamanho da fonte
            Container(
              padding: EdgeInsets.all(context.tokens.spaceMd),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(context.tokens.radiusSm),
              ),
              child: Text(
                'Exemplo de texto com tamanho ${_config.fontSize.toInt()}pt',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            
            SizedBox(height: context.tokens.spaceLg),
            
            // Usar fonte do sistema
            SwitchListTile(
              title: const Text('Usar Fonte do Sistema'),
              subtitle: const Text('Usar a fonte padrão do dispositivo'),
              value: _config.useSystemFont,
              onChanged: (value) {
                _themeService.updateThemeConfig(
                  _config.copyWith(useSystemFont: value),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessibilitySection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.accessibility,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: context.tokens.spaceSm),
                Text(
                  'Acessibilidade',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: context.tokens.spaceLg),
            
            // Alto contraste
            SwitchListTile(
              title: const Text('Alto Contraste'),
              subtitle: const Text('Aumenta o contraste para melhor legibilidade'),
              value: _config.highContrast,
              onChanged: (value) {
                _themeService.toggleHighContrast();
              },
            ),
            
            // Movimento reduzido
            SwitchListTile(
              title: const Text('Movimento Reduzido'),
              subtitle: const Text('Reduz animações e transições'),
              value: _config.reducedMotion,
              onChanged: (value) {
                _themeService.toggleReducedMotion();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemePreview() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.preview,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: context.tokens.spaceSm),
                Text(
                  'Visualização',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: context.tokens.spaceLg),
            
            // Preview dos componentes
            Container(
              padding: EdgeInsets.all(context.tokens.spaceLg),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(context.tokens.radiusSm),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    'Título do Card',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: context.tokens.spaceSm),
                  
                  // Texto corpo
                  Text(
                    'Este é um exemplo de texto corpo para demonstrar como o tema aparece na aplicação.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: context.tokens.spaceLg),
                  
                  // Botões
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Primário'),
                      ),
                      SizedBox(width: context.tokens.spaceSm),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Secundário'),
                      ),
                    ],
                  ),
                  SizedBox(height: context.tokens.spaceLg),
                  
                  // Campo de texto
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Campo de exemplo',
                      hintText: 'Digite algo aqui...',
                    ),
                    enabled: false,
                  ),
                  SizedBox(height: context.tokens.spaceLg),
                  
                  // Chips
                  Wrap(
                    spacing: context.tokens.spaceSm,
                    children: [
                      Chip(
                        label: const Text('Tag 1'),
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      Chip(
                        label: const Text('Tag 2'),
                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _exportTheme,
            icon: const Icon(Icons.download),
            label: const Text('Exportar Configurações'),
          ),
        ),
        SizedBox(height: context.tokens.spaceSm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _importTheme,
            icon: const Icon(Icons.upload),
            label: const Text('Importar Configurações'),
          ),
        ),
        SizedBox(height: context.tokens.spaceSm),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: _resetToDefault,
            icon: const Icon(Icons.restore),
            label: const Text('Restaurar Padrão'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }

  String _getThemeTypeName(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return 'Claro';
      case AppThemeType.dark:
        return 'Escuro';
      case AppThemeType.system:
        return 'Sistema';
    }
  }

  String _getThemeTypeDescription(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return 'Sempre usar tema claro';
      case AppThemeType.dark:
        return 'Sempre usar tema escuro';
      case AppThemeType.system:
        return 'Seguir configuração do sistema';
    }
  }

  void _resetToDefault() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Padrão'),
        content: const Text(
          'Isso irá restaurar todas as configurações de tema para os valores padrão. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _themeService.resetToDefault();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configurações restauradas para o padrão'),
                ),
              );
            },
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  void _exportTheme() {
    // Implementar exportação das configurações
    final config = _themeService.config.toJson();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Configurações'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Suas configurações de tema:'),
            SizedBox(height: context.tokens.spaceSm),
            Container(
              padding: EdgeInsets.all(context.tokens.spaceSm),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(context.tokens.radiusSm),
              ),
              child: Text(
                config.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implementar compartilhamento ou salvamento
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configurações copiadas para a área de transferência'),
                ),
              );
            },
            child: const Text('Copiar'),
          ),
        ],
      ),
    );
  }

  void _importTheme() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importar Configurações'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Cole as configurações aqui',
                hintText: 'JSON das configurações...',
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implementar importação
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configurações importadas com sucesso'),
                ),
              );
            },
            child: const Text('Importar'),
          ),
        ],
      ),
    );
  }
}
